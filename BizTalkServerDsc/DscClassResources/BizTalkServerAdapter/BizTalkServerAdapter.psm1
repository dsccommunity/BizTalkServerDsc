enum Ensure {
    Absent
    Present
}

[DscResource()]
class BizTalkServerAdapter {
    [DscProperty(Mandatory)]
    [PSCredential]$PsDscRunAsCredential

    [DscProperty(Key)]
    [string]$Name

    [DscProperty(Mandatory)]
    [string]$MgmtCLSID

    [DscProperty(Mandatory)]
    [Ensure]$Ensure

    [string]$namespace = 'ROOT\MicrosoftBizTalkServer'

    [void]Set() {
        $session = New-CimSession -Credential $this.PsDscRunAsCredential

        if ($this.Ensure -eq [Ensure]::Present) {
            $query = "SELECT * FROM MSBTS_AdapterSetting WHERE MgmtCLSID='$($this.MgmtCLSID)'"
            $query = $query.Replace("\", "\\")
            $instance = Get-CimInstance -CimSession $session -Query $query -Namespace $this.namespace

            if ($null -eq $instance) {
                Write-Verbose "Create MSBTS_AdapterSetting $($this.Name)"

                $instanceClass = Get-CimClass -Namespace $this.namespace –ClassName MSBTS_AdapterSetting -CimSession $session
                $properties = @{
                    Name = $this.Name
                    MgmtCLSID = $this.MgmtCLSID
                }
                $instance = New-CimInstance -CimClass $instanceClass -Property $properties -CimSession $session
            } elseif ($instance.Name -ne $this.Name) {
                Write-Verbose "Rename MSBTS_AdapterSetting $($this.Name)"

                Remove-CimInstance -InputObject $instance -CimSession $session

                $instanceClass = Get-CimClass -Namespace $this.namespace –ClassName MSBTS_AdapterSetting -CimSession $session
                $properties = @{
                    Name = $this.Name
                    MgmtCLSID = $this.MgmtCLSID
                }
                $instance = New-CimInstance -CimClass $instanceClass -Property $properties -CimSession $session
            }

            Set-CimInstance -InputObject $instance
        } else {
            $query = "SELECT * FROM MSBTS_AdapterSetting WHERE MgmtCLSID='$($this.MgmtCLSID)'"
            $query = $query.Replace("\", "\\")
            $instance = Get-CimInstance -Query $query -Namespace $this.namespace -CimSession $session

            Write-Verbose "Find MSBTS_AdapterSetting $($this.Name)"

            if ($null -ne $instance) {
                Write-Verbose "Remove MSBTS_HostAdapterSetting $($this.Name)"
                
                Remove-CimInstance -InputObject $instance -CimSession $session
            }
        }
    }

    [bool]Test() {
        $session = New-CimSession -Credential $this.PsDscRunAsCredential
        $query = "SELECT * FROM MSBTS_AdapterSetting WHERE Name='$($this.Name)' AND MgmtCLSID = '$($this.MgmtCLSID)'"
        $query = $query.Replace("\", "\\")
        $instance = Get-CimInstance -Query $query -Namespace $this.namespace -CimSession $session

        if ($this.Ensure -eq [Ensure]::Present) {
            $result = ($null -ne $instance)
        } else {
            $result = ($null -eq $instance)
        }

        if ($null -ne $instance) {
            $this.MgmtCLSID = $instance.MgmtCLSID
        }

        Write-Verbose "Test: $result"

        return $result
    }

    [BizTalkServerAdapter]Get() {
        $result = $this.Test()

        if ($result) {
            return $this
        } else {
            return $null
        }
    }
}
