@{
    RootModule = "MSFT_BizTalkServer.psm1"

    DscResourcesToExport = @('BizTalkServerHost', 'BizTalkServerHostInstance', 'BizTalkServerAdapter', 'BizTalkServerSendHandler', 'BizTalkServerReceiveHandler')

    CmdLetsToExport = ''

    FunctionsToExport = ''

    # Version number of this module.
    ModuleVersion = '0.1.1.4'

    # ID used to uniquely identify this module
    GUID = 'BDFD5A0E-C922-4FE3-BDC3-107E0DAD6FF8'

    # Author of this module
    Author = 'Pieter van der Merwe, Chris Gardner'

    # Company or vendor of this module
    CompanyName = ''

    # Description of the functionality provided by this module
    Description = 'BizTalk Server DSC Resources'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.0'

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''
}
