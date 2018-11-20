Configuration BizTalkServerSendHandlerExample
{
    Import-DSCResource -ModuleName BizTalkServer

    BizTalkServerAdapter SampleBizTalkServerAdapter
    {
        Name = 'WCF-SQL'
        Ensure = 'Present'
        MgmtCLSID = '{59B35D03-6A06-4734-A249-EF561254ECF7}'
    }

    BizTalkServerHost SampleBizTalkServerHost
    {
        Name = 'BizTalkServerApplication2'
        Trusted = $true
        Tracking = $false
        Type = 'InProcess'
        Is32Bit = $true
        Default = $true
        WindowsGroup = 'BizTalk Application Users'
        Ensure = 'Present'
    }

    BizTalkServerSendHandler SampleBizTalkServerSendHandler
    {
        DependsOn = @('[BizTalkServerAdapter]SampleBizTalkServerAdapter','[BizTalkServerHost]SampleBizTalkServerHost')
        Adapter = 'WCF-SQL'
        Host = 'BizTalkServerApplication2'
        Default = $true
        Ensure = 'Present'
    }
}

