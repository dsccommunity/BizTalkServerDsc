@{
    RootModule = "BizTalkServerDsc.psm1"

    DscResourcesToExport = @(
        'BizTalkServerHost'
        'BizTalkServerHostInstance'
        'BizTalkServerAdapter'
        'BizTalkServerSendHandler'
        'BizTalkServerReceiveHandler'
    )

    NestedModules = @(
        'DscClassResources\BizTalkServerAdapter\BizTalkServerAdapter.psd1'
        'DscClassResources\BizTalkServerHost\BizTalkServerHost.psd1'
        'DscClassResources\BizTalkServerHostInstance\BizTalkServerHostInstance.psd1'
        'DscClassResources\BizTalkServerReceiveHandler\BizTalkServerReceiveHandler.psd1'
        'DscClassResources\BizTalkServerSendHandler\BizTalkServerSendHandler.psd1'
    )
    CmdLetsToExport = @()

    FunctionsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # Version number of this module.
    ModuleVersion = '0.1.0.0'

    # ID used to uniquely identify this module
    GUID = '75c75856-75ca-451b-8255-5f3e9eaae6e2'

    # Author of this module
    Author = 'Ilian Nilsson, inherited work from Pieter van der Merwe, Chris Gardner'

    # Company or vendor of this module
    CompanyName = ''

    # Description of the functionality provided by this module
    Description = 'BizTalk Server DSC Resources'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('DSC', 'BizTalk')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/IlleNilsson/BizTalkServerDsc/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/IlleNilsson/BizTalkServerDsc'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}
