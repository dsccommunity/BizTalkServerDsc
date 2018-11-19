enum Ensure {
    Absent
    Present
}

[DscResource()]
class BizTalkServerSendHandler {
    [DscProperty(Key)]
    [string]$Adapter

    [DscProperty(Key)]
    [string]$Host

    [DscProperty(Mandatory)]
    [bool]$Default

    [DscProperty(Mandatory)]
    [Ensure]$Ensure

    [DscProperty()]
    [PSCredential]$Credential

    [string]$namespace = 'ROOT\MicrosoftBizTalkServer'

    [void] Set() {
        $session = New-CimSession -Credential $this.Credential

        if ($this.Ensure -eq [Ensure]::Present) {
            $query = "SELECT * FROM MSBTS_SendHandler2 WHERE AdapterName='$($this.Adapter)' AND HostName = '$($this.Host)'"

            $query = $query.Replace("\", "\\")

            $instance = Get-CimInstance -Query $query -Namespace $this.namespace -CimSession $session

            if ($null -eq $instance) {
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

            if ($null -ne $instance) {
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

        if ($this.Ensure -eq [Ensure]::Present) {
            $result = ($null -ne $instance)
        }
        else {
            $result = ($null -eq $instance)
        }

        if ($null -ne $instance) {
            $this.Default = $instance.IsDefault
        }

        Write-Verbose "Test: $result"

        return $result
    }

    [BizTalkServerSendHandler] Get() {
        $result = $this.Test()

        if ($result) {
            return $this
        }
        else {
            return $null
        }
    }
}
