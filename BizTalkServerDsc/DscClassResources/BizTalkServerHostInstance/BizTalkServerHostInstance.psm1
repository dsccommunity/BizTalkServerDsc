enum Ensure {
    Absent
    Present
}

[DscResource()]
class BizTalkServerHostInstance {
    [DscProperty(Mandatory)]
    [PSCredential]$PsDscRunAsCredential

    [DscProperty(Key)]
    [string]$Host

    [DscProperty(Mandatory)]
    [PSCredential]$Credential

    [DscProperty(Mandatory)]
    [Ensure]$Ensure

    [string]$namespace = 'ROOT\MicrosoftBizTalkServer'

    [void]Set() {
        $session = New-CimSession -Credential $this.PsDscRunAsCredential

        if ($this.Ensure -eq [Ensure]::Present) {
            $instanceClass = Get-CimClass -Namespace $this.namespace –ClassName MSBTS_ServerHost -CimSession $session
            $properties = @{
                ServerName = $Env:COMPUTERNAME
                HostName = $this.Host
                MgmtDbNameOverride = ''
                MgmtDbServerOverride = ''
            }

            Write-Verbose "Create MSBTS_ServerHost $($this.Host) Instance"

            $instance = New-CimInstance -CimClass $instanceClass -Property $properties -ClientOnly

            Write-Verbose "Map MSBTS_ServerHost $($this.Host)"

            $arguments = @{}

            Invoke-CimMethod -InputObject $instance -MethodName Map -Arguments $arguments -CimSession $session

            $instanceClass = Get-CimClass -Namespace $this.namespace –ClassName MSBTS_HostInstance -CimSession $session
            $name = "Microsoft BizTalk Server $($this.Host) $($env:COMPUTERNAME)"
            $properties = @{
                Name = $name
                HostName = $($this.Host)
                MgmtDbNameOverride = ''
                MgmtDbServerOverride = ''
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
        } else {
            $query = "SELECT * FROM MSBTS_HostInstance WHERE HostName='$($this.Host)'"
            $query = $query.Replace("\", "\\")
            $instance = Get-CimInstance -Query $query -Namespace $this.namespace -CimSession $session

            Write-Verbose "Find MSBTS_HostInstance $($this.Host)"

            $arguments = @{}

            if ($null -ne $instance) {
                if ($instance.ServiceState -eq 4) {
                    Write-Verbose "Stop MSBTS_HostInstance $($this.Host)"

                    Invoke-CimMethod -InputObject $instance -MethodName Stop -Arguments $arguments -CimSession $session
                }

                Write-Verbose "UnInstall MSBTS_HostInstance $($this.Host)"

                Invoke-CimMethod -InputObject $instance -MethodName UnInstall -Arguments $arguments
            }

            Write-Verbose "UnMap MSBTS_ServerHost $($this.Host)"

            $instanceClass = Get-CimClass -Namespace $this.namespace –ClassName MSBTS_ServerHost -CimSession $session
            $properties = @{
                ServerName = $Env:COMPUTERNAME
                HostName = $($this.Host)
                MgmtDbNameOverride = ''
                MgmtDbServerOverride = ''
            }
            $instance = New-CimInstance -CimClass $instanceClass -Property $properties -ClientOnly -CimSession $session

            Invoke-CimMethod -InputObject $instance -MethodName ForceUnmap -Arguments $arguments
        }
    }

    [bool]Test() {
        $session = New-CimSession -Credential $this.PsDscRunAsCredential
        $query = "SELECT * FROM MSBTS_HostInstance WHERE HostName='$($this.Host)' AND RunningServer='$($env:COMPUTERNAME)'"
        $query = $query.Replace("\", "\\")
        $instance = Get-CimInstance -Query $query -Namespace $this.namespace -CimSession $session

        if ($this.Ensure -eq [Ensure]::Present) {
            $result = ($null -ne $instance)
        } else {
            $result = ($null -eq $instance)
        }

        if ($null -ne $instance) {
            $this.Host = $instance.HostName
        }

        Write-Verbose "Test: $result"

        return $result
    }

    [BizTalkServerHostInstance]Get() {
        $result = $this.Test()

        if ($result) {
            return $this
        } else {
            return $null
        }
    }
}
