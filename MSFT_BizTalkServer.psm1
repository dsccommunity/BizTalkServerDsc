Import-Module PSDesiredStateConfiguration

enum Ensure { 
    Absent 
    Present 
}

enum HostType { 
    InProcess
    Isolated
}

[DscResource()]
class BizTalkServerHost {
    [DscProperty(Key)]
    [string]$Name

    [DscProperty(Mandatory)]
    [bool] $Trusted

    [DscProperty(Mandatory)]
    [bool] $Tracking

    [DscProperty(Mandatory)]
    [HostType] $Type

    [DscProperty(Mandatory)]
    [bool] $Is32Bit

    [DscProperty(Mandatory)]
    [bool] $Default

    [DscProperty(Mandatory)]
    [string] $WindowsGroup

    [DscProperty(Key)]
    [Ensure] $Ensure

    [DscProperty()]
    [pscredential] $Credential

    [string] $namespace = 'ROOT\MicrosoftBizTalkServer'

    [void] Set() {
        $session = New-CimSession -Credential $this.Credential

        if($this.Ensure -eq [Ensure]::Present) {
            $query = "SELECT * FROM MSBTS_HostSetting WHERE Name='$($this.Name)'"

            $query = $query.Replace("\", "\\")

            $instance = Get-CimInstance -Query $query -Namespace $this.namespace -CimSession $session

            if($null -eq $instance) {
                $instanceClass = Get-CimClass -ClassName MSBTS_HostSetting -Namespace $this.namespace -CimSession $session

                $properties = @{
                    Name = $this.Name;
                    AuthTrusted = $this.Trusted;
                    HostTracking = $this.Tracking;
                    HostType = &{if($this.Type -eq [HostType]::Inprocess) {1} else {2}};
                    IsDefault = $this.Default;
                    IsHost32BitOnly = $this.Is32Bit;
                    NTGroupName = $this.WindowsGroup;
                    MgmtDbServerOverride = '';
                    MgmtDbNameOverride = ''
                }

                $instance = New-CimInstance -CimClass $instanceClass  -Property $properties -CimSession $session
            }
            else {
                $instance.AuthTrusted = $this.Trusted;
                $instance.HostTracking = $this.Tracking;
                $instance.HostType = &{if($this.Type -eq [HostType]::Inprocess) {1} else {2}};
                $instance.IsDefault = $this.Default;
                $instance.IsHost32BitOnly = $this.Is32Bit;
                $instance.NTGroupName = $this.WindowsGroup;
            }

            Set-CimInstance -InputObject $instance -CimSession $session
        }
        else {
            $query = "SELECT * FROM MSBTS_HostSetting WHERE Name='$($this.Name)'"

            $query = $query.Replace("\", "\\")

            $instance = Get-CimInstance -Query $query -Namespace $this.namespace -CimSession $session

            if($null -ne $instance) {
                Remove-CimInstance -InputObject $instance -CimSession $session
            }
        }
    }

    [bool] Test() {
        $session = New-CimSession -Credential $this.Credential

        $hostType = &{if($this.Type -eq [HostType]::Inprocess) {1} else {2}}

        $query = "SELECT * FROM MSBTS_HostSetting WHERE Name='$($this.Name)' AND AuthTrusted = $($this.Trusted) AND HostTracking = $($this.Tracking) AND HostType = $hostType AND IsHost32BitOnly = $($this.Is32Bit) AND IsDefault = $($this.Default) AND NTGroupName = '$($this.WindowsGroup)'"

        $query = $query.Replace("\", "\\")

        $instance = Get-CimInstance -Query $query -Namespace $this.namespace -CimSession $session

        if($this.Ensure -eq [Ensure]::Present) {
            $result = ($null -ne $instance)
        }
        else{
            $result = ($null -eq $instance)
        }

        if($null -ne $instance) {
            $this.Default = $instance.IsDefault
            $this.Is32Bit = $instance.IsHost32BitOnly
            $this.Name = $instance.Name
            $this.Trusted = $instance.AuthTrusted
            $this.Tracking = $instance.HostTracking
            $this.Type = &{if($instance.HostType -eq 1) {[HostType]::Inprocess} else {[HostType]::Isolated}}
            $this.Default = $instance.IsDefault
            $this.Is32Bit = $instance.IsHost32BitOnly
            $this.WindowsGroup = $instance.NTGroupName
        }

        Write-Verbose "Test: $result"
        
        return $result
    }

    [BizTalkServerHost] Get() {
        $result = $this.Test()

        if($result) {
            return $this
        }
        else {
            return $null
        }
    }
}

[DscResource()]
class BizTalkServerHostInstance {
    [DscProperty(Key)]
    [string]$Host

    [DscProperty(Mandatory)]
    [PSCredential] $Credential

    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [string] $namespace = 'ROOT\MicrosoftBizTalkServer'

    [void] Set() {
        $session = New-CimSession -Credential $this.Credential

        if($this.Ensure -eq [Ensure]::Present){
            $instanceClass = Get-CimClass -Namespace $this.namespace –ClassName MSBTS_ServerHost -CimSession $session

            $properties = @{
                ServerName = $($env:COMPUTERNAME);
                HostName = $($this.Host);
                MgmtDbNameOverride='';
                MgmtDbServerOverride='';
            }

            Write-Verbose "Create MSBTS_ServerHost $($this.Host) Instance"

            $instance = New-CimInstance -CimClass $instanceClass -Property $properties -ClientOnly

            Write-Verbose "Map MSBTS_ServerHost $($this.Host)"

            $arguments = @{}

            Invoke-CimMethod -InputObject $instance -MethodName Map -Arguments $arguments -CimSession $session

            $instanceClass = Get-CimClass -Namespace $this.namespace –ClassName MSBTS_HostInstance -CimSession $session

            $name = "Microsoft BizTalk Server $($this.Host) $($env:COMPUTERNAME)"

            $properties = @{
                Name = $name;
                HostName = $($this.Host);
                MgmtDbNameOverride='';
                MgmtDbServerOverride='';
            }

            Write-Verbose "Create MSBTS_HostInstance $($this.Host)"

            $instance = New-CimInstance -CimClass $instanceClass -Property $properties -ClientOnly

            Write-Verbose "Install MSBTS_HostInstance $($this.Host)"

            $user = $this.Credential.UserName
            $password = $this.Credential.GetNetworkCredential().Password

            $arguments = @{
                GrantLogOnAsService = $true;
                Logon = $user;
                Password = $password;
            }

            Invoke-CimMethod -InputObject $instance -MethodName Install -Arguments $arguments -CimSession $session
        }
        else{
            $query = "SELECT * FROM MSBTS_HostInstance WHERE HostName='$($this.Host)'"

            $query = $query.Replace("\", "\\")

            $instance = Get-CimInstance -Query $query -Namespace $this.namespace -CimSession $session

            Write-Verbose "Find MSBTS_HostInstance $($this.Host)"

            $arguments = @{}

            if($null -ne $instance){
                if($instance.ServiceState =eq 4){
                    Write-Verbose "Stop MSBTS_HostInstance $($this.Host)"
                    Invoke-CimMethod -InputObject $instance -MethodName Stop -Arguments $arguments -CimSession $session
                }

                Write-Verbose "UnInstall MSBTS_HostInstance $($this.Host)"

                Invoke-CimMethod -InputObject $instance -MethodName UnInstall -Arguments $arguments
            }

            Write-Verbose "UnMap MSBTS_ServerHost $($this.Host)"

            $instanceClass = Get-CimClass -Namespace $this.namespace –ClassName MSBTS_ServerHost -CimSession $session

            $properties = @{
                ServerName = $($env:COMPUTERNAME);
                HostName = $($this.Host);
                MgmtDbNameOverride='';
                MgmtDbServerOverride='';
            }

            $instance = New-CimInstance -CimClass $instanceClass -Property $properties -ClientOnly -CimSession $session

            Invoke-CimMethod -InputObject $instance -MethodName ForceUnmap -Arguments $arguments
        }
    }

    [bool] Test() {
        $session = New-CimSession -Credential $this.Credential

        $query = "SELECT * FROM MSBTS_HostInstance WHERE HostName='$($this.Host)' AND RunningServer='$($env:COMPUTERNAME)'"

        $query = $query.Replace("\", "\\")

        $instance = Get-CimInstance -Query $query -Namespace $this.namespace -CimSession $session

        if($this.Ensure -eq [Ensure]::Present){
            $result = ($null -ne $instance)
        }
        else{
            $result = ($null -eq $instance)
        }

        if($null -ne $instance)
        {
            $this.Host = $instance.HostName
        }

        Write-Verbose "Test: $result"
        
        return $result
    }

    [BizTalkServerHostInstance] Get() {
        $result = $this.Test()

        if($result){
            return $this
        }
        else{
            return $null
        }
    }
}

[DscResource()]
class BizTalkServerAdapter {
    [DscProperty(Key)]
    [string]$Name

    [DscProperty(Mandatory)]
    [string] $MgmtCLSID

    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty()]
    [PSCredential] $Credential

    [string] $namespace = 'ROOT\MicrosoftBizTalkServer'

    [void] Set() {
        $session = New-CimSession -Credential $this.Credential

        if($this.Ensure -eq [Ensure]::Present){
            $query = "SELECT * FROM MSBTS_AdapterSetting WHERE Name='$($this.Name)'"

            $query = $query.Replace("\", "\\")

            $instance = Get-CimInstance -CimSession $session -Query $query -Namespace $this.namespace

            if($null -eq $instance)
            {
                Write-Verbose "Create MSBTS_AdapterSetting $($this.Name)"

                $instanceClass = Get-CimClass -Namespace $this.namespace –ClassName MSBTS_AdapterSetting -CimSession $session

                $properties = @{
                    Name = $($this.Name);
                    MgmtCLSID = $this.MgmtCLSID;
                }

                $instance = New-CimInstance -CimClass $instanceClass -Property $properties -CimSession $session
            }
            else {
                $instance.MgmtCLSID = $this.MgmtCLSID
            }
            
            Set-CimInstance -InputObject $instance
        }
        else{
            $query = "SELECT * FROM MSBTS_AdapterSetting WHERE Name='$($this.Name)'"

            $query = $query.Replace("\", "\\")

            $instance = Get-CimInstance -Query $query -Namespace $this.namespace -CimSession $session

            Write-Verbose "Find MSBTS_AdapterSetting $($this.Name)"

            if($null -ne $instance){
                Write-Verbose "Remove MSBTS_HostAdapterSetting $($this.Name)"
                Remove-CimInstance -InputObject $instance -CimSession $session
            }
        }
    }

    [bool] Test() {
        $session = New-CimSession -Credential $this.Credential

        $query = "SELECT * FROM MSBTS_AdapterSetting WHERE Name='$($this.Name)' AND MgmtCLSID = '$($this.MgmtCLSID)'"

        $query = $query.Replace("\", "\\")

        $instance = Get-CimInstance -Query $query -Namespace $this.namespace -CimSession $session

        if($this.Ensure -eq [Ensure]::Present){
            $result = ($null -ne $instance)
        }
        else{
            $result = ($null -eq $instance)
        }

        if($null -ne $instance) {
            $this.MgmtCLSID = $instance.MgmtCLSID
        }

        Write-Verbose "Test: $result"
        
        return $result
    }

    [BizTalkServerAdapter] Get() {
        $result = $this.Test()

        if($result){
            return $this
        }
        else{
            return $null
        }
    }
}

[DscResource()]
class BizTalkServerSendHandler{
    [DscProperty(Key)]
    [string]$Adapter

    [DscProperty(Key)]
    [string] $Host

    [DscProperty(Mandatory)]
    [bool] $Default

    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty()]
    [PSCredential] $Credential

    [string] $namespace = 'ROOT\MicrosoftBizTalkServer'

    [void] Set() {
        $session = New-CimSession -Credential $this.Credential

        if($this.Ensure -eq [Ensure]::Present) {
            $query = "SELECT * FROM MSBTS_SendHandler2 WHERE AdapterName='$($this.Adapter)' AND HostName = '$($this.Host)'"

            $query = $query.Replace("\", "\\")

            $instance = Get-CimInstance -Query $query -Namespace $this.namespace -CimSession $session

            if($null -eq $instance) {
                Write-Verbose "Create MSBTS_SendHandler2 $($this.Adapter) on $($this.Host)"

                $instanceClass = Get-CimClass -Namespace $this.namespace –ClassName MSBTS_SendHandler2 -CimSession $session

                $properties = @{
                    AdapterName = $this.Adapter;
                    HostName = $this.Host;
                    IsDefault = $this.Default;
                    MgmtDbNameOverride = '';
                    MgmtDbServerOverride = '';
                    CustomCfg = ''
                }

                $instance = New-CimInstance -CimClass $instanceClass -Property $properties -CimSession $session
            }
            else {
                $instance.IsDefault = $this.Default
            }
                
            Set-CimInstance -InputObject $instance -CimSession $session
        }
        else {
            $query = "SELECT * FROM MSBTS_SendHandler2 WHERE AdapterName='$($this.Adapter)' AND HostName = '$($this.Host)'"

            $query = $query.Replace("\", "\\")

            $instance = Get-CimInstance -Query $query -Namespace $this.namespace -CimSession $session

            Write-Verbose "Find MSBTS_SendHandler2 $($this.Adapter) on $($this.Host)"

            if($null -ne $instance) {
                Write-Verbose "Remove MSBTS_SendHandler2 $($this.Adapter) on $($this.Host)"
                Remove-CimInstance -InputObject $instance -CimSession $session
            }
        }
    }

    [bool] Test() {
        $session = New-CimSession -Credential $this.Credential

        $query = "SELECT * FROM MSBTS_SendHandler2 WHERE AdapterName='$($this.Adapter)' AND HostName = '$($this.Host)' AND IsDefault = $($this.Default)"

        $query = $query.Replace("\", "\\")

        $instance = Get-CimInstance -Query $query -Namespace $this.namespace -CimSession $session

        if($this.Ensure -eq [Ensure]::Present) {
            $result = ($null -ne $instance)
        }
        else{
            $result = ($null -eq $instance)
        }

        if($null -ne $instance) {
            $this.Default = $instance.IsDefault
        }

        Write-Verbose "Test: $result"
        
        return $result
    }

    [BizTalkServerSendHandler] Get() {
        $result = $this.Test()

        if($result){
            return $this
        }
        else{
            return $null
        }
    }
}

[DscResource()]
class BizTalkServerReceiveHandler{
    [DscProperty(Key)]
    [string]$Adapter

    [DscProperty(Key)]
    [string] $Host

    [DscProperty(Mandatory)]
    [Ensure] $Ensure

    [DscProperty()]
    [PSCredential] $Credential

    [string] $namespace = 'ROOT\MicrosoftBizTalkServer'

    [void] Set() {
        $session = New-CimSession -Credential $this.Credential

        if($this.Ensure -eq [Ensure]::Present){
            Write-Verbose "Create MSBTS_ReceiveHandler $($this.Adapter) on $($this.Host)"

            $instanceClass = Get-CimClass -Namespace $this.namespace –ClassName MSBTS_ReceiveHandler -CimSession $session

            $properties = @{
                AdapterName = $this.Adapter;
                HostName = $this.Host;
                MgmtDbNameOverride = '';
                MgmtDbServerOverride = '';
                CustomCfg = ''
            }

            $instance = New-CimInstance -CimClass $instanceClass -Property $properties -CimSession $session
            
            Set-CimInstance -InputObject $instance -CimSession $session
        }
        else{
            $query = "SELECT * FROM MSBTS_ReceiveHandler WHERE AdapterName='$($this.Adapter)' AND HostName = '$($this.Host)'"

            $query = $query.Replace("\", "\\")

            $instance = Get-CimInstance -Query $query -Namespace $this.namespace -CimSession $session

            Write-Verbose "Find MSBTS_SendHandler2 $($this.Adapter) on $($this.Host)"

            if($null -ne $instance){
                Write-Verbose "Remove MSBTS_ReceiveHandler $($this.Adapter) on $($this.Host)"
                Remove-CimInstance -InputObject $instance -CimSession $session
            }
        }
    }

    [bool] Test() {
        $session = New-CimSession -Credential $this.Credential

        $query = "SELECT * FROM MSBTS_ReceiveHandler WHERE AdapterName='$($this.Adapter)' AND HostName = '$($this.Host)'"

        $query = $query.Replace("\", "\\")

        $instance = Get-CimInstance -Query $query -Namespace $this.namespace -CimSession $session

        if($this.Ensure -eq [Ensure]::Present){
            $result = ($null -ne $instance)
        }
        else{
            $result = ($null -eq $instance)
        }

        Write-Verbose "Test: $result"
        
        return $result
    }

    [BizTalkServerReceiveHandler] Get() {
        $result = $this.Test()

        if($result){
            return $this
        }
        else{
            return $null
        }
    }
}