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
configuration MSFT_BizTalkServerHostInstance_config {

    Import-DscResource -ModuleName 'BizTalkServer'

    $name = 'TestBizTalkServerApplication'
    
    node localhost{
        $password = ConvertTo-SecureString 'Pass@word1' -AsPlainText -Force

        $credentials = New-Object System.Management.Automation.PSCredential ('Administrator', $password)

        BizTalkServerHost TestBizTalkServerHost
        {
            Name = $name
            Ensure = 'Present'
            Is32Bit = $false
            Trusted = $true
            Tracking = $true
            Type = 'InProcess'
            Default = $false
            WindowsGroup = 'BizTalk Application Users'
        }

        BizTalkServerHostInstance TestBizTalkServerHostInstance{
            DependsOn = @('[BizTalkServerHost]TestBizTalkServerHost')
            Ensure = 'Present'
            Host = $name
            Credential = $credentials
        }
    }
}
