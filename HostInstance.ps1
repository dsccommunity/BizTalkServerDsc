$hostname = 'TestBizTalkServerApplication2'
$namespace = 'ROOT\MicrosoftBizTalkServer'

$query = "SELECT * FROM MSBTS_ServerHost WHERE HostName='$hostname'"

$instance = Get-CimInstance -Query $query -Namespace $namespace

if($null -ne $instance){
    Remove-CimInstance -InputObject $instance
}

$query = "SELECT * FROM MSBTS_HostSetting WHERE Name='$hostname'"

$instance = Get-CimInstance -Query $query -Namespace $namespace

if($null -ne $instance){
    Remove-CimInstance -InputObject $instance
}

$query = "SELECT * FROM MSBTS_HostInstance WHERE HostName='$hostname'"

$instance = Get-CimInstance -Query $query -Namespace $namespace

if($null -ne $instance){
    Remove-CimInstance -InputObject $instance
}

$properties = @{
    Name = $hostname;
    AuthTrusted = $true;
    HostTracking = $false;
    HostType = 1;
    IsDefault = $false;
    IsHost32BitOnly = $false;
    NTGroupName = 'BizTalk Application Users';
}

$instanceClass = Get-CimClass -ClassName MSBTS_HostSetting -Namespace $namespace

$instance = New-CimInstance -CimClass $instanceClass  -Property $properties

Set-CimInstance -InputObject $instance
           
$instanceClass = Get-CimClass -Namespace $namespace –ClassName MSBTS_ServerHost

$properties = @{
    ServerName = $env:COMPUTERNAME;
    HostName = $hostname;
}

$instance = New-CimInstance -CimClass $instanceClass -Property $properties

Set-CimInstance -InputObject $instance

$query = "SELECT * FROM MSBTS_ServerHost WHERE HostName='$hostname'"

$instance = Get-CimInstance -Query $query -Namespace $namespace

Invoke-CimMethod -InputObject $instance -MethodName Map

$query = "SELECT * FROM MSBTS_HostInstance WHERE HostName='$hostname'"

$instance = Get-CimInstance -Query $query -Namespace $namespace

if($null -ne $instance){
    Remove-CimInstance -InputObject $instance
}

$instanceClass = Get-CimClass -Namespace $namespace –ClassName MSBTS_HostInstance

$name = "Microsoft BizTalk Server $hostname $($env:COMPUTERNAME)"

$properties = @{
    Name =$name;
}

$instance = New-CimInstance -CimClass $instanceClass -Property $properties

$arguments = @{
    GrantLogOnAsService = $true;
    Logon = '\Administrator';
    Password = 'Pass@word1';
}

Set-CimInstance -InputObject $instance 

$instance = Get-CimInstance -Query $query -Namespace $namespace

Invoke-CimMethod -InputObject $instance -MethodName Install -Arguments $arguments

