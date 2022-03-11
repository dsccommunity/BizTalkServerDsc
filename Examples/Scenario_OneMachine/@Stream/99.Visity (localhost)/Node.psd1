@{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            NodeType = 'Client' # VALUES: Client | Server
            NodeRole = @('BizTalk', 'ServiceFabric', 'SqlServer') # VALUES: BizTalk & ServiceFabric & SqlServer
            BizTalkReplica = 'Primary' # VALUES: Primary | Secondary
            ServiceFabricReplica = 'Primary' # VALUES: Primary | Secondary
            SqlServerReplica = 'Primary' # VALUES: Primary | Secondary
            PSDscAllowDomainUser = $true
            PSDscAllowPlainTextPassword = $true
        },
        @{
            NodeName = '*'
        }
    )
    Modules = @(
        @{ Name = 'xPSDesiredStateConfiguration'; Version = '9.1.0' }
        @{ Name = 'ComputerManagementDsc'; Version = '8.5.0' }
        @{ Name = 'NetworkingDsc'; Version = '8.2.0' }
        @{ Name = 'xWindowsUpdate'; Version = '2.8.0' }
    )
    BizTalk = @{
        Modules = @( 
            @{ Name = 'BizTalkServer'; Version = '0.2.0' }
        )
        ProductName = 'Microsoft BizTalk Server 2020'
        ProductId = '{205F5836-7512-4A06-9E74-ADC8AFA0EEC5}'
        SourcePath = 'C:\Users\Public\Public Media\BizTalk 2020\BizTalk Server\Setup.exe'
        Patch = @{
            PatchName = 'Microsoft BizTalk Server 2020 Cumulative Update 3 [KB 5007969]'
            PatchId = 'KB5007969'
            SourcePath = 'C:\Users\Public\Public Media\BizTalk 2020\BizTalk Server CUs\BTS2020-KB5007969-ENU (CU3).exe'
        }
        # TODO: Break out to psd1 file
        Adapters = @(
            @{ Name = 'AzureBlobStorage'
                ReceiveHandlers = @(
                    @{ Host = 'GcRxHost64' }
                )
                SendHandlers = @( 
                    @{ Host = 'GcSxHost64'; Default = $false }
                )
            }
            @{ Name = 'FILE'
                ReceiveHandlers = @(
                    @{ Host = 'GcRxHost' }
                    @{ Host = 'GcRxHost64' }
                )
                SendHandlers = @( 
                    @{ Host = 'GcSxHost'; Default = $false }
                    @{ Host = 'GcSxHost64'; Default = $false }
                    @{ Host = 'GcSxPrioHost64'; Default = $false }
                )
            }
            @{ Name = 'FTP'
                ReceiveHandlers = @(
                    @{ Host = 'GcCxHost' }
                )
                SendHandlers = @( 
                    @{ Host = 'GcSxHost'; Default = $false }
                )
            }
            @{ Name = 'HTTP'
                ReceiveHandlers = @(
                    @{ Host = 'GcIxHost' }
                )
                SendHandlers = @( 
                    @{ Host = 'GcSxHost'; Default = $false }
                    @{ Host = 'GcSxHost64'; Default = $false }
                    @{ Host = 'GcSxPrioHost64'; Default = $false }
                )
            }
            @{ Name = 'MQSeries'
                ReceiveHandlers = @(
                    @{ Host = 'GcCxHost64' }
                )
                SendHandlers = @( 
                    @{ Host = 'GcCxHost64'; Default = $false }
                )
            }
            @{ Name = 'MSMQ'
                ReceiveHandlers = @(
                    @{ Host = 'GcCxHost64' }
                )
                SendHandlers = @( 
                    @{ Host = 'GcCxHost64'; Default = $false }
                )
            }
            @{ Name = 'MS-SFTP'
                ReceiveHandlers = @(
                    @{ Host = 'GcCxHost' }
                    @{ Host = 'GcCxHost64' }
                    @{ Host = 'GcRxHost' }
                )
                SendHandlers = @( 
                    @{ Host = 'GcSxHost'; Default = $false }
                    @{ Host = 'GcSxHost64'; Default = $false }
                    @{ Host = 'GcSxPrioHost64'; Default = $false }
                )
            }
            @{ Name = 'POP3'
                ReceiveHandlers = @(
                    @{ Host = 'GcCxHost64' }
                )
                SendHandlers = @()
            }
            @{ Name = 'SB-Messaging'
                ReceiveHandlers = @(
                    @{ Host = 'GcCxHost64' }
                    @{ Host = 'GcRxHost64' }
                )
                SendHandlers = @( 
                    @{ Host = 'GcSxHost64'; Default = $false }
                    @{ Host = 'GcSxPrioHost64'; Default = $false }
                )
            }
            @{ Name = 'SMTP'
                ReceiveHandlers = @()
                SendHandlers = @( 
                    @{ Host = 'GcSxHost'; Default = $false }
                    @{ Host = 'GcSxHost64'; Default = $false }
                    @{ Host = 'GcSxPrioHost64'; Default = $false }
                )
            }
            @{ Name = 'SOAP'
                ReceiveHandlers = @(
                    @{ Host = 'GcIxHost' }
                )
                SendHandlers = @( 
                    @{ Host = 'GcSxHost'; Default = $false }
                    @{ Host = 'GcSxHost64'; Default = $false }
                    @{ Host = 'GcSxPrioHost64'; Default = $false }
                )
            }
            @{ Name = 'WCF-BasicHttp'
                ReceiveHandlers = @(
                    @{ Host = 'GcIxHost' }
                )
                SendHandlers = @( 
                    @{ Host = 'GcSxHost'; Default = $false }
                    @{ Host = 'GcSxHost64'; Default = $false }
                    @{ Host = 'GcSxPrioHost64'; Default = $false }
                )
            }
            @{ Name = 'WCF-BasicHttpRelay'
                ReceiveHandlers = @(
                    @{ Host = 'GcRxHost64' }
                )
                SendHandlers = @( 
                    @{ Host = 'GcSxHost64'; Default = $false }
                    @{ Host = 'GcSxPrioHost64'; Default = $false }
                )
            }
            @{ Name = 'WCF-Custom'
                ReceiveHandlers = @(
                    @{ Host = 'GcCxHost' }
                    @{ Host = 'GcCxHost64' }
                    @{ Host = 'GcRxHost' }
                    @{ Host = 'GcRxHost64' }
                )
                SendHandlers = @( 
                    @{ Host = 'GcSxHost'; Default = $false }
                    @{ Host = 'GcSxHost64'; Default = $false }
                    @{ Host = 'GcSxPrioHost64'; Default = $false }
                )
            }
            @{ Name = 'WCF-CustomIsolated'
                ReceiveHandlers = @(
                    @{ Host = 'GcIxHost' }
                )
                SendHandlers = @()
            }
            @{ Name = 'WCF-NetMsmq'
                ReceiveHandlers = @(
                    @{ Host = 'GcCxHost64' }
                )
                SendHandlers = @(
                    @{ Host = 'GcCxHost64'; Default = $false }
                )
            }
            @{ Name = 'WCF-NetNamedPipe'
                ReceiveHandlers = @(
                    @{ Host = 'GcRxHost' }
                    @{ Host = 'GcRxHost64' }
                )
                SendHandlers = @(
                    @{ Host = 'GcSxHost'; Default = $false }
                    @{ Host = 'GcSxHost64'; Default = $false }
                    @{ Host = 'GcSxPrioHost64'; Default = $false }
                )
            }
            @{ Name = 'WCF-NetTcp'
                ReceiveHandlers = @(
                    @{ Host = 'GcRxHost' }
                    @{ Host = 'GcRxHost64' }
                )
                SendHandlers = @(
                    @{ Host = 'GcSxHost'; Default = $false }
                    @{ Host = 'GcSxHost64'; Default = $false }
                    @{ Host = 'GcSxPrioHost64'; Default = $false }
                )
            }
            @{ Name = 'WCF-NetTcpRelay'
                ReceiveHandlers = @(
                    @{ Host = 'GcRxHost64' }
                )
                SendHandlers = @(
                    @{ Host = 'GcSxHost64'; Default = $false }
                    @{ Host = 'GcSxPrioHost64'; Default = $false }
                )
            }
            @{ Name = 'WCF-SQL'
                ReceiveHandlers = @(
                    @{ Host = 'GcCxHost' }
                    @{ Host = 'GcCxHost64' }
                    @{ Host = 'GcRxHost' }
                    @{ Host = 'GcRxHost64' }
                )
                SendHandlers = @(
                    @{ Host = 'GcSxHost'; Default = $false }
                    @{ Host = 'GcSxHost64'; Default = $false }
                    @{ Host = 'GcSxPrioHost64'; Default = $false }
                )
            }
            @{ Name = 'WCF-WebHttp'
                ReceiveHandlers = @(
                    @{ Host = 'GcIxHost' }
                )
                SendHandlers = @(
                    @{ Host = 'GcSxHost64'; Default = $false }
                    @{ Host = 'GcSxPrioHost64'; Default = $false }
                )
            }
            @{ Name = 'WCF-WSHttp'
                ReceiveHandlers = @(
                    @{ Host = 'GcIxHost' }
                )
                SendHandlers = @(
                    @{ Host = 'GcSxHost64'; Default = $false }
                    @{ Host = 'GcSxPrioHost64'; Default = $false }
                )
            }
            @{ Name = 'Windows SharePoint Services'
                ReceiveHandlers = @(
                    @{ Host = 'GcRxHost' }
                    @{ Host = 'GcRxHost64' }
                )
                SendHandlers = @(
                    @{ Host = 'GcSxHost'; Default = $false }
                    @{ Host = 'GcSxHost64'; Default = $false }
                )
            }
        )
        Hosts = @(
            @{ Name = 'GcIxHost'; Type = 'Isolated'; WindowsGroup = 'BizTalk Isolated Host Users'; Account = '*******\BtsIsolated'; Is32Bit = $false; Trusted = $true; Tracking = $false; Default = $false }
            @{ Name = 'GcCxHost'; Type = 'InProcess'; WindowsGroup = 'BizTalk Application Users'; Account = '*******\BtsInProcess'; Is32Bit = $true; Trusted = $true; Tracking = $false; Default = $false }
            @{ Name = 'GcCxHost64'; Type = 'InProcess'; WindowsGroup = 'BizTalk Application Users'; Account = '*******\BtsInProcess'; Is32Bit = $false; Trusted = $true; Tracking = $false; Default = $false }
            @{ Name = 'GcRxHost'; Type = 'InProcess'; WindowsGroup = 'BizTalk Application Users'; Account = '*******\BtsInProcess'; Is32Bit = $true; Trusted = $true; Tracking = $false; Default = $false }
            @{ Name = 'GcRxHost64'; Type = 'InProcess'; WindowsGroup = 'BizTalk Application Users'; Account = '*******\BtsInProcess'; Is32Bit = $false; Trusted = $true; Tracking = $false; Default = $false }
            @{ Name = 'GcSxHost'; Type = 'InProcess'; WindowsGroup = 'BizTalk Application Users'; Account = '*******\BtsInProcess'; Is32Bit = $true; Trusted = $true; Tracking = $false; Default = $false }
            @{ Name = 'GcSxHost64'; Type = 'InProcess'; WindowsGroup = 'BizTalk Application Users'; Account = '*******\BtsInProcess'; Is32Bit = $false; Trusted = $true; Tracking = $false; Default = $false }
            @{ Name = 'GcSxPrioHost64'; Type = 'InProcess'; WindowsGroup = 'BizTalk Application Users'; Account = '*******\BtsInProcess'; Is32Bit = $false; Trusted = $true; Tracking = $false; Default = $false }
        )
    }
    ServiceFabric = @{
        Modules = @( 
            @{ Name = 'ServiceFabricDsc'; Version = '1.0.0.1' }
        )
        ProductName = '???'
        ProductId = '???'
        SourcePath = '\\???\???'
        # TODO: Break out to psd1 file
    }
    SqlServer = @{
        Modules = @( 
            @{ Name = 'xFailoverCluster'; Version = '1.16.0' } # TODO: There is a version 1.17.0 that enables placing cluster nodes in desired AD OU, need som OS love
            @{ Name = 'SqlServerDsc'; Version = '15.2.0' }
        )
        SourcePath = 'C:\Users\Public\Public Media\SQL Server 2019'
        # TODO: Break out to psd1 file
        ConfigureWindowsFirewall = $true
        SQLUserDBDir = $null
        SQLUserDBLogDir = $null
        SQLTempDBDir = $null
        SQLTempDBLogDir = $null
        FailoverClusterName = 'CLUSQL'
        FailoverClusterIPAddress = '192.168.1.200'
        FailoverClusterIgnoreNetwork = '10.0.3.0/16'
        SqlInstances = @(
            @{
                Name = 'MSSQLSERVER'
                Features = 'SQLENGINE'
                AsServerMode = 'TABULAR'
                MaxDop = 0
                TcpPort = 1433
                EndPointIPAddress = $null
                EndPointPort = $null
                Logins = @();
            }
        )
    }
    Windows = @{
        SourcePath = 'C:\Users\Public\Public Media\Windows 10\Sources\Sxs'
    }
}