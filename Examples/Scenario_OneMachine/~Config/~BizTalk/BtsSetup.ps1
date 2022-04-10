configuration BtsSetup {
    param(
        [Parameter(Mandatory)]
        [PSCredential]$SetupCredential,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [string]$ProductName,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [string]$ProductId,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [string]$SourcePath,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [string]$AddLocal, 
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [string]$SetupLog,
        [string[]]$DependsOnResource
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    $SetupCredentialAccount = $SetupCredential.UserName
    $SetupCredentialPassword = $SetupCredential.GetNetworkCredential().Password

    Script 'BtsSetup' {
        PsDscRunAsCredential = $SetupCredential        
        GetScript = {
            $ErrorActionPreference = 'Stop'

            $getBtsInstalledParams = @{
                Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$($using:ProductId)" 
                Name = 'DisplayName'
            }
            $btsInstalled = $false

            try {
                $btsProductDisplayName = Get-ItemPropertyValue @getBtsInstalledParams 
                $btsInstalled = $btsProductDisplayName -eq $using:ProductName 
            } catch {
            }

            return @{
                Result = $btsInstalled 
            }
        }
        SetScript = {
            $ErrorActionPreference = 'Stop'

            Write-Verbose "Node: '$($Env:COMPUTERNAME)'; Domain: '$($Env:USERDOMAIN)'; Account: '$($Env:USERNAME)'"
    
            $psExecExecutable = "$($Env:ProgramFiles)\PSTools\psexec64.exe"
            $btsWorkingDirectory = "$(${Env:TEMP})"
            $btsSetupExecutable = $ExecutionContext.InvokeCommand.ExpandString($using:SourcePath)

            if (!(Test-Path -Path $psExecExecutable -PathType Leaf -EA Silent)) {
                Write-Verbose ($errorMessage = "File '$psExecExecutable' does not exist")
                
                throw $errorMessage
            }
            if (!(Test-Path -Path $btsWorkingDirectory -PathType Container -EA Silent)) {
                Write-Verbose ($errorMessage = "Folder '$btsWorkingDirectory' does not exist")
                
                throw $errorMessage
            }
            if (!(Test-Path -Path $btsSetupExecutable -PathType Leaf -EA Silent)) {
                Write-Verbose ($errorMessage = "File '$btsSetupExecutable' does not exist")
                
                throw $errorMessage
            }                        

            $processStartInfoArgs = "-u `"$using:SetupCredentialAccount`" -p `"$using:SetupCredentialPassword`"" +
                " -h -i -accepteula `"$btsSetupExecutable`"" + ' /quiet /ADDLOCAL ' + $using:AddLocal + " /L `"$using:SetupLog`""
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
                Write-Verbose "Succeeded to install BizTalk"
            } else {
                Write-Verbose $process.StandardError.ReadToEnd()

                throw "Did not succeed to install BizTalk"
            } 
        }
        TestScript = {
            $ErrorActionPreference = 'Stop'

            Write-Verbose "Node: $($Env:COMPUTERNAME); Domain: $($Env:USERDOMAIN); Account: $($Env:USERNAME)"

            $state = [scriptblock]::Create($GetScript).Invoke()

            if ($state.Result) {
                Write-Verbose 'BizTalk is installed'
            } else {
                Write-Verbose 'BizTalk is not installed'
            }

            return $state.Result
        }
        DependsOn = $DependsOnResource
    }
}