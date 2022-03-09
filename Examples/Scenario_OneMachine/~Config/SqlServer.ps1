# TODO: MS DTC for old connecting systems

. "$PSScriptRoot\~Common\GitSourceEnvVars.ps1"
. "$PSScriptRoot\~Common\ConfigurationManager.ps1"

configuration SqlServer {
    param([PSCredential]$SetupCredential
        , [string[]]$SqlAdminAccounts
        , [hashtable]$SqlSvcCredentials
        , [hashtable]$AgtSvcCredentials
        , [hashtable]$AssSvcCredentials
        , [hashtable]$FtsSvcCredentials
        , [hashtable]$RssSvcCredentials
    )

    Import-DscResource -ModuleName SqlServerDsc -ModuleVersion 15.2.0
    Import-DscResource -ModuleName xFailoverCluster -ModuleVersion 1.16.0
    Import-DscResource -ModuleName NetworkingDsc -ModuleVersion 8.2.0
    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion 8.5.0
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $AllNodes.NodeName {
        if (!($Node.NodeRole -contains 'SqlServer')) { return }

        Service 'SqlBrowser' {
            PsDscRunAsCredential = $SetupCredential
            Name = 'SQLBrowser'
            StartupType = 'Automatic'
            State = 'Running'
            Ensure = 'Present'
            DependsOn = @($ConfigurationData.SqlServer.SqlInstances |
                Foreach-Object { "[SqlProtocolTcpIp]$($_.Name)" })
        }
        ScheduledTask 'CleanupSqlSetupLogFiles' {
            PsDscRunAsCredential = $SetupCredential
            TaskName = 'Cleanup SQL Server Setup Log Files'
            TaskPath = '\SQL Server'
            ActionExecutable = '%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe'
            ActionArguments = '-Command "ls """$Env:ProgramFiles\Microsoft SQL Server\*\Setup Bootstrap\Log""" ' +
                '-Directory | sort -Descending | ri -Recurse -Confirm:$false -Force"'
            ScheduleType = 'Daily'
            StartTime = '03:00'
            Ensure = 'Present'
            DependsOn = @($ConfigurationData.SqlServer.SqlInstances | 
                ForEach-Object { "[SqlProtocolTcpIp]$($_.Name)" })
        }
        foreach($sqlInstance in $ConfigurationData.SqlServer.SqlInstances) {
            if ($Node.NodeType -eq 'Server') {
                $sqlAGListenerDependsOn = if ($Node.SqlServerReplica -ne 'Primary') {
                    @("[SqlAGReplica]$($sqlInstance.Name)") 
                } else { 
                    @("[SqlAG]$($sqlInstance.Name)") 
                } 
                SqlAGListener "$($sqlInstance.Name)" {
                    PsDscRunAsCredential = $SetupCredential
                    Name = $sqlInstance.Name
                    AvailabilityGroup = $sqlInstance.Name
                    ServerName = $Node.NodeName
                    InstanceName = $sqlInstance.Name
                    <# TODO: IPAddress = $sqlInstance.EndPointIPAddress
                    Port = $sqlInstance.EndPointPort #>
                    Ensure = 'Present'
                    DependsOn = $sqlAGListenerDependsOn
                }
                if ($Node.SqlServerReplica -ne 'Primary') {
                    $primary = $AllNodes | Where-Object { $_.SqlServerReplica -eq 'Primary' } | select -First 1
                    SqlAGReplica "$($sqlInstance.Name)" {
                        PsDscRunAsCredential = $SetupCredential
                        Name = "$($Node.NodeName)\$($sqlInstance.Name)"
                        AvailabilityGroupName = $sqlInstance.Name
                        ServerName = $Node.NodeName
                        InstanceName = $sqlInstance.Name
                        PrimaryReplicaServerName = $primary.NodeName
                        PrimaryReplicaInstanceName = $sqlInstance.Name
                        AvailabilityMode = 'SynchronousCommit'
                        FailoverMode = 'Automatic'
                        Ensure = 'Present'
                        DependsOn = @("[SqlAlwaysOnService]$($sqlInstance.Name)")
                    }
                } else { 
                    SqlAG "$($sqlInstance.Name)" {
                        PsDscRunAsCredential = $SetupCredential
                        Name = $sqlInstance.Name
                        ServerName = $Node.NodeName
                        InstanceName = $sqlInstance.Name
                        AvailabilityMode = 'SynchronousCommit'
                        FailoverMode = 'Automatic'
                        DtcSupportEnabled = $true
                        Ensure = 'Present'
                        DependsOn = @("[SqlAlwaysOnService]$($sqlInstance.Name)")
                    }
                }
                SqlAlwaysOnService "$($sqlInstance.Name)" {
                    PsDscRunAsCredential = $SetupCredential
                    ServerName = $Node.NodeName
                    InstanceName = $sqlInstance.Name
                    Ensure = 'Present'
                    DependsOn = @("[SqlEndPoint]$($sqlInstance.Name)")
                }
                SqlEndPoint "$($sqlInstance.Name)" {
                    PsDscRunAsCredential = $SetupCredential
                    EndPointName = $sqlInstance.Name
                    EndpointType = 'DatabaseMirroring'
                    Port = $sqlInstance.EndPointPort
                    ServerName = $Node.NodeName
                    InstanceName = $sqlInstance.Name
                    Ensure = 'Present'
                    DependsOn = @("[SqlPermission]$($sqlInstance.Name)")
                }
            }
            if ($Node.ConfigureWindowsFirewall -eq $true) {
                Firewall "$($sqlInstance.Name)_SqlEndPoint" {
                    PsDscRunAsCredential = $SetupCredential
                    Name = "SQL Server End Point - $($sqlInstance.Name)"
                    Group = 'SQL Server End Points'
                    Protocol = 'TCP'
                    LocalPort = $sqlInstance.EndPointPort
                    Action = 'Allow'
                    Enabled = $true
                    Ensure = 'Present'
                }
            }
            SqlPermission "$($sqlInstance.Name)"
            {
                PsDscRunAsCredential = $SetupCredential
                ServerName = $Node.NodeName
                InstanceName = $sqlInstance.Name
                Principal = $SetupCredential.UserName
                Permission = 'AlterAnyAvailabilityGroup', 'ViewServerState'
                Ensure = 'Present'
                DependsOn = @("[SqlProtocolTcpIp]$($sqlInstance.Name)")
            }
            if ($Node.ConfigureWindowsFirewall -eq $true) {
                SqlWindowsFirewall "$($sqlInstance.Name)" {
                    PsDscRunAsCredential = $SetupCredential
                    SourcePath = "$($Node.SqlSourcePath)\"
                    InstanceName = $sqlInstance.Name
                    Features = $sqlInstance.Features
                    Ensure = 'Present'
                    DependsOn = @("[SqlProtocolTcpIp]$($sqlInstance.Name)")
                }
            }
            SqlProtocolTcpIp "$($sqlInstance.Name)" {
                PsDscRunAsCredential = $SetupCredential
                ServerName = $Node.NodeName
                InstanceName = $sqlInstance.Name
                IpAddressGroup = 'IPAll'
                TcpPort = $sqlInstance.TcpPort
                Enabled = $true
                DependsOn = @("[SqlProtocol]$($sqlInstance.Name)")
            }
            SqlProtocol "$($sqlInstance.Name)" {
                PsDscRunAsCredential = $SetupCredential
                ServerName = $Node.NodeName
                InstanceName = $sqlInstance.Name
                ProtocolName = 'TcpIp'
                Enabled = $true
                DependsOn = @("[SqlSetup]$($sqlInstance.Name)")
            }
            foreach($role in ($sqlInstance.Logins.Roles | Sort-Object -Unique)) {
                SqlRole "$($sqlInstance.Name)_$($role)" {
                    PsDscRunAsCredential = $SetupCredential
                    ServerName = $Node.NodeName
                    InstanceName = $sqlInstance.Name
                    ServerRoleName = $role
                    MembersToInclude = $sqlInstance.Logins | Where-Object { $_.Roles -contains $role } | 
                        ForEach-Object { $_.Name }
                    Ensure = 'Present'
                    DependsOn = $sqlInstance.Logins | Where-Object { "[SqlLogin]$($sqlInstance.Name)_$($_.Name)" }
                }
            }
            foreach($login in $sqlInstance.Logins) {
                SqlLogin "$($sqlInstance.Name)_$($login.Name)" {
                    PsDscRunAsCredential = $SetupCredential
                    ServerName = $Node.NodeName
                    InstanceName = $sqlInstance.Name
                    Name = $login.Name
                    LoginType = $login.LoginType
                    Ensure = 'Present'
                    DependsOn = @("[SqlSetup]$($sqlInstance.Name)")
                }
            }
            if ($sqlInstance.MaxDop -eq '0') {
                SqlMaxDop "$($sqlInstance.Name)" {
                    PsDscRunAsCredential = $SetupCredential
                    ServerName = $Node.NodeName
                    InstanceName = $sqlInstance.Name
                    Ensure = 'Absent'
                    DependsOn = @("[SqlSetup]$($sqlInstance.Name)")
                }
            } else {
                SqlMaxDop "$($sqlInstance.Name)" {
                    PsDscRunAsCredential = $SetupCredential
                    ServerName = $Node.NodeName
                    InstanceName = $sqlInstance.Name
                    MaxDop = $sqlInstance.MaxDop
                    Ensure = 'Present'
                    DependsOn = @("[SqlSetup]$($sqlInstance.Name)")
                }
            }
            $sqlSetupDependsOn = `
                if ($Node.NodeType -eq 'Client')
                    { @() }
                elseif ($Node.SqlServerReplica -eq 'Secondary' -and (($AllNodes | Where-Object { $_.NodeName -ne '*'}).Count -gt 1))
                    { @('[xWaitForCluster]WaitForCluster', "[WaitForAny]InitializedInstance_$($sqlInstance.Name)") }
                else 
                    { @('[xWaitForCluster]WaitForCluster') } 
            SqlSetup "$($sqlInstance.Name)" {
                PsDscRunAsCredential = $SetupCredential
                SourcePath = "$($ConfigurationData.SqlServer.SourcePath)"
                Action = 'Install'
                SqlSysAdminAccounts = $SqlAdminAccounts
                InstanceName = $sqlInstance.Name
                SqlSvcAccount = $SqlSvcCredentials[$sqlInstance.Name]
                AgtSvcAccount = $AgtSvcCredentials[$sqlInstance.Name]

                ASSvcAccount = $AssSvcCredentials[$sqlInstance.Name]
                FTSvcAccount = $FtsSvcCredentials[$sqlInstance.Name]
                RSSvcAccount = $RssSvcCredentials[$sqlInstance.Name]

                Features = $sqlInstance.Features
                AsServerMode = $sqlInstance.AsServerMode
                InstallSqlDataDir = if ($null -ne $ConfigurationData.SqlServer.SQLUserDBDir) { 
                    "$($ConfigurationData.SqlServer.SQLUserDBDir)\$($sqlInstance.Name)" 
                } else { 
                    $null 
                }
                SqlUserDBDir = if ($null -ne $ConfigurationData.SqlServer.SQLUserDBDir) { 
                    "$($ConfigurationData.SqlServer.SQLUserDBDir)\$($sqlInstance.Name)" 
                } else { 
                    $null 
                }
                SqlUserDBLogDir = if ($null -ne $ConfigurationData.SqlServer.SQLUserDBLogDir) { 
                    "$($ConfigurationData.SqlServer.SQLUserDBLogDir)\$($sqlInstance.Name)"
                 } else { 
                     $null 
                }
                SqlTempDBDir = if ($null -ne $ConfigurationData.SqlServer.SQLTempDBDir) { 
                    "$($ConfigurationData.SqlServer.SQLTempDBDir)\$($sqlInstance.Name)"
                } else { 
                    $null 
                }
                SqlTempDBLogDir = if ($null -ne $ConfigurationData.SqlServer.SQLTempDBLogDir) {
                    "$($ConfigurationData.SqlServer.SQLTempDBLogDir)\$($sqlInstance.Name)" 
                } else { 
                    $null
                }
                DependsOn = $sqlSetupDependsOn
            }
            if ($Node.SqlServerReplica -eq 'Secondary' -and (($AllNodes | 
                ForEach-Object { $_.NodeName -ne '*'}).Count -gt 1))
            { 
                WaitForAny "InitializedInstance_$($sqlInstance.Name)" {
                    PsDscRunAsCredential = $SetupCredential
                    NodeName = ($AllNodes | Where-Object { $_.SqlServerReplica -eq 'Primary' } | select -First 1).NodeName
                    ResourceName = "[SqlSetup]$($sqlInstance.Name)"
                    RetryIntervalSec = 60
                    RetryCount = 40
                }
            }
        }
        if ($Node.NodeType -eq 'Server') {
            xWaitForCluster 'WaitForCluster' {
                PsDscRunAsCredential = $SetupCredential
                Name = $ConfigurationData.SqlServer.FailoverClusterName
                RetryIntervalSec = 5
                RetryCount = 15
                DependsOn = @('[xCluster]PrepareCluster')
            }
            xCluster 'PrepareCluster' {
                PsDscRunAsCredential = $SetupCredential
                DomainAdministratorCredential = $SetupCredential
                Name = $ConfigurationData.SqlServer.FailoverClusterName
                StaticIPAddress = $ConfigurationData.SqlServer.FailoverClusterIPAddress
                IgnoreNetwork = $ConfigurationData.SqlServer.FailoverClusterIgnoreNetwork
                DependsOn = @('[WindowsFeature]WSCS')
            }
            WindowsFeature 'WSCS' {
                Name = 'Failover-Clustering'
                Ensure = 'Present'
                DependsOn = @('[WindowsFeature]WSCSAutSrv', '[WindowsFeature]WSCSCmdLets', '[WindowsFeature]WSCSCmdLine')
            }
            WindowsFeature 'WSCSAutSrv' {
                Name = 'RSAT-Clustering-AutomationServer'
                Ensure = 'Present'
            }
            WindowsFeature 'WSCSCmdLets' {
                Name = 'RSAT-Clustering-PowerShell'
                Ensure = 'Present'
            }
            WindowsFeature 'WSCSCmdLine' {
                Name = 'RSAT-Clustering-CmdInterface'
                Ensure = 'Present'
            }
        }        
        $gitSourceEnvVarsParams = @{
            SetupCredential = $SetupCredential
        }
        GitSourceEnvVars @gitSourceEnvVarsParams
        ConfigurationManager
    }
}
