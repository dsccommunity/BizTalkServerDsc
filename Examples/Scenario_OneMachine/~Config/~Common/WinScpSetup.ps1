configuration WinScpSetup {
    param(
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [PSCredential]$SetupCredential,
        [string[]]$DependsOnResource
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 9.1.0
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    $winScpFileName = 'WinSCP-5.19.6-Setup.exe'
    $winScpUrl = "https://altushost-swe.dl.sourceforge.net/project/winscp/WinSCP/5.19.6/$winScpFileName"
    $winScpDestination = "C:\Users\Public\Downloads\$winScpFileName"

    # INFO: Install WinSCP
    Package 'WinSCP' {
        PsDscRunAsCredential = $SetupCredential
        Name = 'WinSCP 5.19.6'
        ProductId = ''
        Path = $winScpDestination
        Arguments = '/SILENT /VERYSILENT /ALLUSERS /NORESTART /NOCLOSEAPPLICATIONS'
        DependsOn = @('[xRemoteFile]WinSCP')
    } 
    # INFO: Download WinSCP to Download Folder
    xRemoteFile 'WinSCP' {
        PsDscRunAsCredential = $SetupCredential
        Uri = $winScpUrl
        DestinationPath = $winScpDestination
        MatchSource = $true
        UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer
        Headers = @{ 'Accept-Language' = 'en-US' } # NOTE: This line does not work with newer versions than 5.1 of PowerShell
        DependsOn = $DependsOnResource
    }
}
