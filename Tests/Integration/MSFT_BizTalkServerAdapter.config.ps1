<#
.Synopsis
   DSC Configuration Template for DSC Resource Integration tests.
.DESCRIPTION
   To Use:
     1. Copy to \Tests\Integration\ folder and rename <ResourceName>.config.ps1 (e.g. MSFT_xFirewall.config.ps1)
     2. Customize TODO sections.

.NOTES
#>


# Integration Test Config Template Version: 1.0.0
configuration MSFT_BizTalkServerAdapter_config {
    Import-DscResource -ModuleName 'BizTalkServer'
    node localhost 
    {
        BizTalkServerAdapter TestBizTalkServerAdapter
        {
            Name = 'WCF-SQL'
            Ensure = 'Present'
            MgmtCLSID = '{59B35D03-6A06-4734-A249-EF561254ECF7}'
        }
    }
}
