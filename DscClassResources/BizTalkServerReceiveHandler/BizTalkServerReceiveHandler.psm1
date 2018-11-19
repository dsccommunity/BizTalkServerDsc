enum Ensure {
    Absent
    Present
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
