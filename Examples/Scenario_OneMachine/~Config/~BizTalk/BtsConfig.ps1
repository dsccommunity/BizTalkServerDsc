# TODO: Tokenize Configuration file and copy to MOF-location

configuration BtsConfig {
    param(
        [Parameter(Mandatory)]
        [PSCredential]$SetupCredential,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [string]$ConfigurationFile,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [string]$ConfigurationLog,
        [string]$TmsAccount,
        [string[]]$DependsOnResource
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    $SetupCredentialAccount = $SetupCredential.UserName
    $SetupCredentialPassword = $SetupCredential.GetNetworkCredential().Password

    Script 'BtsConfig' {
        PsDscRunAsCredential = $SetupCredential
        GetScript = {
            $ErrorActionPreference = 'Stop'

            Write-Verbose "Node: $($Env:COMPUTERNAME); Domain: $($Env:USERDOMAIN); Account: $($Env:USERNAME)"

            $getBtsMgmtDbServerSetting = @{
                Path = 'HKLM:\SOFTWARE\Microsoft\BizTalk Server\3.0\Administration' 
                Name = 'MgmtDBServer'
            }
            $mgmtDBServer = $null

            try {
                $mgmtDBServer = Get-ItemPropertyValue @getBtsMgmtDbServerSetting
            } catch {
            }

            return @{
                Result = !([string]::IsNullOrWhiteSpace($mgmtDBServer)) 
            }
        }
        TestScript = {
            $ErrorActionPreference = 'Stop'

            Write-Verbose "Node: $($Env:COMPUTERNAME); Domain: $($Env:USERDOMAIN); Account: $($Env:USERNAME)"

            $state = [scriptblock]::Create($GetScript).Invoke()

            if ($state.Result) {
                Write-Verbose 'BizTalk is configured'
            } else {
                Write-Verbose 'BizTalk is not configured'
            }

            return $state.Result
        }
        SetScript = {
            $ErrorActionPreference = 'Stop'

            Write-Verbose "Node: '$($Env:COMPUTERNAME)'; Domain: '$($Env:USERDOMAIN)'; Account: '$($Env:USERNAME)'"
    
            $psExecExecutable = "$($Env:ProgramFiles)\PSTools\psexec64.exe"
            $btsWorkingDirectory = "$(${Env:ProgramFiles(x86)})\Microsoft BizTalk Server"
            $btsConfigurationExecutable = 'Configuration.exe'
            $btsConfigurationFile = $ExecutionContext.InvokeCommand.ExpandString($using:ConfigurationFile)
            $btsConfigurationLog = $ExecutionContext.InvokeCommand.ExpandString($using:ConfigurationLog)

            if (!(Test-Path -Path $psExecExecutable -PathType Leaf -EA Silent)) {
                Write-Verbose ($errorMessage = "File '$psExecExecutable' does not exist")
                
                throw $errorMessage
            }
            if (!(Test-Path -Path $btsWorkingDirectory -PathType Container -EA Silent)) {
                Write-Verbose ($errorMessage = "Folder '$btsWorkingDirectory' does not exist")
                
                throw $errorMessage
            }
            if (!(Test-Path -Path (Join-Path -Path $btsWorkingDirectory -ChildPath $btsConfigurationExecutable) -PathType Leaf -EA Silent)) {
                Write-Verbose ($errorMessage = "File '$(Join-Path -Path $btsWorkingDirectory -ChildPath $btsConfigurationExecutable)' does not exist")
                
                throw $errorMessage
            }                        
            if (!(Test-Path $btsConfigurationFile -PathType Leaf -EA Silent)) {
                Write-Verbose ($errorMessage = "File '$btsConfigurationFile' does not exist")
                
                throw $errorMessage
            }

            $tmsAccountPushed = if ($using:TmsAccount -and 
                !(Get-LocalGroupMember -Group 'Administrators' -Member $using:TmsAccount -EA Silent)) {
                Write-Verbose ("Temporarily adding TMS Account '$($using:TmsAccount)' to local Administrators group")

                Add-LocalGroupMember -Group 'Administrators' -Member $using:TmsAccount
                
                $true
            } else {
                $false
            }

            $processStartInfoArgs = "-u `"$using:SetupCredentialAccount`" -p `"$using:SetupCredentialPassword`"" +
                " -h -i -accepteula `"$btsConfigurationExecutable`"  /noprogressbar /s `"$btsConfigurationFile`" /l `"$btsConfigurationLog`""
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

            function Remove-TmsAccountFromLocalAdministrators {
                param(
                    [string]$TmsAccount,
                    [bool]$TmsAccountPushed = $tmsAccountPushed
                )
                if ($TmsAccount -and $TmsAccountPushed) {
                    Remove-LocalGroupMember -Group 'Administrators' -Member $TmsAccount 
            
                    Write-Verbose ("Removed TMS Account '$TmsAccount' from local Administrators group")
                }
            }
            
            $removeTmsAccountFromLocalAdministratorsParams = @{
                TmsAccount = $using:TmsAccount
                TmsAccountPushed = $tmsAccountPushed 
            }             
            if ($process.ExitCode -eq 0) {
                Remove-TmsAccountFromLocalAdministrators @removeTmsAccountFromLocalAdministratorsParams

                Write-Verbose $process.StandardOutput.ReadToEnd()
                Write-Verbose "Succeeded to configure BizTalk"
            } else {
                Remove-TmsAccountFromLocalAdministrators @removeTmsAccountFromLocalAdministratorsParams

                Write-Verbose $process.StandardError.ReadToEnd()

                Get-Process Configuration | Stop-Process -Force
                
                throw "Did not succeed to configure BizTalk"
            } 
        }
        DependsOn = $DependsOnResource
    }
}