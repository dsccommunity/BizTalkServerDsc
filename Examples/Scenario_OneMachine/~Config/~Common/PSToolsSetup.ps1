configuration PSToolsSetup {
    param(
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [PSCredential]$SetupCredential,
        [string[]]$DependsOnResource
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 9.1.0
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    $psToolsFileName = 'PSTools.zip'
    $psToolsUrl = "https://download.sysinternals.com/files/$psToolsFileName"
    $psToolsDestination = "C:\Users\Public\Downloads\$psToolsFileName"
    $psToolsFolder = 'C:\Program Files\PSTools'

    # INFO: Unzip PSTools in Program Folder
    Archive 'PSTools' {
        PsDscRunAsCredential = $SetupCredential
        Path = $psToolsDestination
        Destination = $psToolsFolder
        DependsOn = @('[Registry]PSTools')
    }
    # INFO: Set registry value to accept PSTools Eula
    Registry 'PSTools' {
        PsDscRunAsCredential = $SetupCredential
        Key = 'HKEY_CURRENT_USER\SOFTWARE\Sysinternals\PsExec'
        ValueName = 'EulaAccepted'
        ValueType = 'Dword'
        ValueData = 1
        Ensure = 'Present'
        DependsOn = @('[xRemoteFile]PSTools')
    }
    # INFO: Download PSTools Files to Download Folder
    xRemoteFile 'PSTools' {
        PsDscRunAsCredential = $SetupCredential
        Uri = $psToolsUrl
        DestinationPath = $psToolsDestination
        MatchSource = $true
        UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer
        Headers = @{ 'Accept-Language' = 'en-US' } # NOTE: This line does not work with newer versions than 5.1 of PowerShell
        DependsOn = $DependsOnResource
    }
}
