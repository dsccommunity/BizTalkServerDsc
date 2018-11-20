$password = ConvertTo-SecureString 'Pass@word1' -AsPlainText -Force

$credentials = New-Object System.Management.Automation.PSCredential ('.\Administrator', $password)

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

    BizTalkServerHostInstance SampleBizTalkServerHostInstance
    {
        DependsOn = @('[BizTalkServerHost]SampleBizTalkServerHost')
        Ensure = 'Present'
        Host = 'SampleBizTalkServerApplication'
        Credential = $credentials
    }
}

