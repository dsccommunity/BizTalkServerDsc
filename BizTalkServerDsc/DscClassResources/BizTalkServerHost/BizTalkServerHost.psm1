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
    [DscProperty(Mandatory)]
    [PSCredential]$PsDscRunAsCredential

    [DscProperty(Key)]
    [string]$Name

    [DscProperty(Mandatory)]
    [bool]$Trusted

    [DscProperty(Mandatory)]
    [bool]$Tracking

    [DscProperty(Mandatory)]
    [HostType]$Type

    [DscProperty(Mandatory)]
    [bool]$Is32Bit

    [DscProperty(Mandatory)]
    [bool]$Default

    [DscProperty(Mandatory)]
    [string]$WindowsGroup

    [DscProperty()]
    [Ensure]$Ensure = [Ensure]::Present

    [string]$namespace = 'ROOT\MicrosoftBizTalkServer'

    [void] Set() {
        $session = New-CimSession -Credential $this.PsDscRunAsCredential

        if ($this.Ensure -eq [Ensure]::Present) {
            $query = "SELECT * FROM MSBTS_HostSetting WHERE Name='$($this.Name)'"
            $query = $query.Replace("\", "\\")
            $instance = Get-CimInstance -Query $query -Namespace $this.namespace -CimSession $session

            if ($null -eq $instance) {
                $instanceClass = Get-CimClass -ClassName MSBTS_HostSetting -Namespace $this.namespace -CimSession $session
                $properties = @{
                    Name = $this.Name
                    AuthTrusted = $this.Trusted
                    HostTracking = $this.Tracking
                    HostType = & { if ($this.Type -eq [HostType]::Inprocess) {1} else {2} }
                    IsDefault = $this.Default
                    IsHost32BitOnly = $this.Is32Bit
                    NTGroupName = $this.WindowsGroup
                    MgmtDbServerOverride = ''
                    MgmtDbNameOverride = ''
                }
                $instance = New-CimInstance -CimClass $instanceClass  -Property $properties -CimSession $session
            } else {
                $instance.AuthTrusted = $this.Trusted;
                $instance.HostTracking = $this.Tracking;
                $instance.HostType = & {if ($this.Type -eq [HostType]::Inprocess) {1} else {2}};
                $instance.IsDefault = $this.Default;
                $instance.IsHost32BitOnly = $this.Is32Bit;
                $instance.NTGroupName = $this.WindowsGroup;
            }

            Set-CimInstance -InputObject $instance -CimSession $session
        } else {
            $query = "SELECT * FROM MSBTS_HostSetting WHERE Name='$($this.Name)'"
            $query = $query.Replace("\", "\\")
            $instance = Get-CimInstance -Query $query -Namespace $this.namespace -CimSession $session

            if ($null -ne $instance) {
                Remove-CimInstance -InputObject $instance -CimSession $session
            }
        }
    }

    [bool]Test() {
        $session = New-CimSession -Credential $this.PsDscRunAsCredential
        $hostType = & {if ($this.Type -eq [HostType]::Inprocess) {1} else {2}}
        $query = "SELECT * FROM MSBTS_HostSetting WHERE Name='$($this.Name)' AND AuthTrusted = $($this.Trusted) AND HostTracking = $($this.Tracking) AND HostType = $hostType AND IsHost32BitOnly = $($this.Is32Bit) AND IsDefault = $($this.Default) AND NTGroupName = '$($this.WindowsGroup)'"
        $query = $query.Replace("\", "\\")
        $instance = Get-CimInstance -Query $query -Namespace $this.namespace -CimSession $session

        if ($this.Ensure -eq [Ensure]::Present) {
            $result = ($null -ne $instance)
        } else {
            $result = ($null -eq $instance)
        }

        if ($null -ne $instance) {
            $this.Default = $instance.IsDefault
            $this.Is32Bit = $instance.IsHost32BitOnly
            $this.Name = $instance.Name
            $this.Trusted = $instance.AuthTrusted
            $this.Tracking = $instance.HostTracking
            $this.Type = & {if ($instance.HostType -eq 1) {[HostType]::Inprocess} else {[HostType]::Isolated}}
            $this.Default = $instance.IsDefault
            $this.Is32Bit = $instance.IsHost32BitOnly
            $this.WindowsGroup = $instance.NTGroupName
        }

        Write-Verbose "Test: $result"

        return $result
    }

    [BizTalkServerHost]Get() {
        $result = $this.Test()

        if ($result) {
            return $this
        } else {
            return $null
        }
    }
}
