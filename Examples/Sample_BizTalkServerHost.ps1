Configuration BizTalkServerHostExample
{
    Import-DSCResource -ModuleName BizTalkServer

    BizTalkServerHost SampleBizTalkServerHost
    {
        Name = 'SampleBizTalkServerApplication'
        Ensure = 'Present'
        Is32Bit = $false
        Trusted = $true
        Tracking = $true
        Type = 'InProcess'
        Default = $false
        WindowsGroup = 'BizTalk Application Users'
    }
}

