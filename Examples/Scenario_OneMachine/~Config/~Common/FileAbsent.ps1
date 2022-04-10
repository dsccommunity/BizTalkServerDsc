configuration FileAbsent {
    param(
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [PSCredential]$SetupCredential,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [string]$ResourceName,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [string]$FilePath,
        [bool]$Backup,
        [string[]]$DependsOnResource
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Script $ResourceName {
        PsDscRunAsCredential = $SetupCredential
        GetScript = {
            $ErrorActionPreference = 'Stop'

            $FilePath = $ExecutionContext.InvokeCommand.ExpandString($using:FilePath)
            $file = Get-ChildItem -Path $FilePath -EA Silent

            return @{
                Result = !($file)
            }
        }
        SetScript = {
            $ErrorActionPreference = 'Stop'

            $FilePath = $ExecutionContext.InvokeCommand.ExpandString($using:FilePath)

            if ($using:Backup) {
                $backupGuid = [System.Guid]::NewGuid().ToString()
                $file = Get-Item $FilePath
                $backupFile = "$($file.BaseName).$backupGuid$($file.Extension)"

                Write-Verbose "Rename file '$FilePath' to '$backupFile'"

                Rename-Item -Path $FilePath -NewName $backupFile  
            } else {
                Write-Verbose "Removing file '$FilePath'"

                Remove-Item -Path $FilePath -Force
            }
        }
        TestScript = {
            $ErrorActionPreference = 'Stop'

            Write-Verbose "Node: $($Env:COMPUTERNAME); Domain: $($Env:USERDOMAIN); Account: $($Env:USERNAME)"

            $FilePath = $ExecutionContext.InvokeCommand.ExpandString($using:FilePath)
            $state = [scriptblock]::Create($GetScript).Invoke()

            if ($state.Result) {
                Write-Verbose "File '$FilePath' is absent"
            } else {
                Write-Verbose "File '$FilePath' is present, removing it"
            }

            return $state.Result
        }
        DependsOn = $DependsOnResource
    }
}
