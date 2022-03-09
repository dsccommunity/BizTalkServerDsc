configuration BtsPatch {
    param(
        [Parameter(Mandatory)]
        [PSCredential]$SetupCredential,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [string]$PatchName,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [string]$PatchId,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [string]$SourcePath,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [string]$PatchLog,
        [string[]]$DependsOnResource
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    $SetupCredentialAccount = $SetupCredential.UserName
    $SetupCredentialPassword = $SetupCredential.GetNetworkCredential().Password

    Script 'BtsPatch' {
        PsDscRunAsCredential = $SetupCredential
        GetScript = {
            $ErrorActionPreference = 'Stop'

            Write-Verbose "Node: $($Env:COMPUTERNAME); Domain: $($Env:USERDOMAIN); Account: $($Env:USERNAME)"

            $getBtsPatchInstalledParams = @{
                Path = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' 
            }
            $btsPatchInstalled = $false

            try {
                $btsPatchRegKey = Get-ItemProperty @getBtsPatchInstalledParams | Where-Object {
                    $_.PSObject.Properties.Name -eq 'DisplayName' -and $_.PSObject.Properties.Value -eq "$using:PatchName" -and
                    $_.PSObject.Properties.Name -eq 'ID' -and $_.PSObject.Properties.Value -eq "$using:PatchId" }
                $btsPatchInstalled = if ($btsPatchRegKey) { $true } else { $false }  
            } catch {
            }

            return @{
                Result = $btsPatchInstalled 
            }
        }
        TestScript = {
            $ErrorActionPreference = 'Stop'

            Write-Verbose "Node: $($Env:COMPUTERNAME); Domain: $($Env:USERDOMAIN); Account: $($Env:USERNAME)"

            $state = [scriptblock]::Create($GetScript).Invoke()

            if ($state.Result) {
                Write-Verbose 'BizTalk is patched'
            } else {
                Write-Verbose 'BizTalk is not patched'
            }

            return $state.Result
        }
        SetScript = {
            $ErrorActionPreference = 'Stop'

            Write-Verbose "Node: '$($Env:COMPUTERNAME)'; Domain: '$($Env:USERDOMAIN)'; Account: '$($Env:USERNAME)'"
    
            $psExecExecutable = "$($Env:ProgramFiles)\PSTools\psexec64.exe"
            $btsWorkingDirectory = "$(${Env:TEMP})"
            $btsPatchExecutable = $ExecutionContext.InvokeCommand.ExpandString($using:SourcePath)

            if (!(Test-Path -Path $psExecExecutable -PathType Leaf -EA Silent)) {
                Write-Verbose ($errorMessage = "File '$psExecExecutable' does not exist")
                
                throw $errorMessage
            }
            if (!(Test-Path -Path $btsWorkingDirectory -PathType Container -EA Silent)) {
                Write-Verbose ($errorMessage = "Folder '$btsWorkingDirectory' does not exist")
                
                throw $errorMessage
            }
            if (!(Test-Path -Path $btsPatchExecutable -PathType Leaf -EA Silent)) {
                Write-Verbose ($errorMessage = "File '$btsPatchExecutable' does not exist")
                
                throw $errorMessage
            }                        

            $processStartInfoArgs = "-u `"$using:SetupCredentialAccount`" -p `"$using:SetupCredentialPassword`"" +
                " -h -i -accepteula `"$btsPatchExecutable`"" + " /quiet /log `"$using:PatchLog`""
            $processStartInfo = New-Object System.Diagnostics.ProcessStartInfo -Property @{
                WorkingDirectory = $btsWorkingDirectory
                FileName = $psExecExecutable
                Arguments = $processStartInfoArgs
                Verb = 'RunAs'
                WindowStyle = 'Hidden'
                CreateNoWindow = $false
                UseShellExecute = $false
                RedirectStandardOutput = $true
                RedirectStandardError = $true
            }
            
            $process = New-Object System.Diagnostics.Process -Property @{ 
                StartInfo = $processStartInfo 
            }    
            
            Write-Verbose ("Starting '$($processStartInfo.FileName)' in '$($processStartInfo.WorkingDirectory)'" + 
                " with arguments '$($processStartInfo.Arguments -replace '-p "(.*?)\s"', '-p ****** "')'")

            $process.Start(); $process.WaitForExit()

            if ($process.ExitCode -eq 0) {
                Write-Verbose $process.StandardOutput.ReadToEnd()
                Write-Verbose "Succeeded to patch BizTalk"
            } else {
                Write-Verbose $process.StandardError.ReadToEnd()

                throw "Did not succeed to patch BizTalk"
            } 
        }
        DependsOn = $DependsOnResource
    }
}