Configuration BizTalkServerAdapterExample
{
    Import-DSCResource -ModuleName BizTalkServer

    BizTalkServerAdapter SampleBizTalkServerAdapter
    {
        Name = 'WCF-SQL'
        Ensure = 'Present'
        MgmtCLSID = '{59B35D03-6A06-4734-A249-EF561254ECF7}'
    }
}

