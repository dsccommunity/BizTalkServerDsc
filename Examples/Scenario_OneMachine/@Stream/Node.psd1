@{
    AllNodes = @(
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
            @{ Name = 'BizTalkServerDsc'; Version = '0.2.0' }
        )
        ProductName = 'Microsoft BizTalk Server 2020'
        ProductId = '{205F5836-7512-4A06-9E74-ADC8AFA0EEC5}'
        SourcePath = 'C:\Users\Public\Public Media\BizTalk 2020\BizTalk Server\Setup.exe'
        Patch = @{
            PatchName = 'Microsoft BizTalk Server 2020 Cumulative Update 3 [KB 5007969]'
            PatchId = 'KB5007969'
            SourcePath = 'C:\Users\Public\Public Media\BizTalk 2020\BizTalk Server CUs\BTS2020-KB5007969-ENU (CU3).exe'
        }
        Adapters = @(
            @{ Name = 'AzureBlobStorage'
                MgmtCLSID = '{23D89CB3-D638-4558-AA36-79F1ECB0454F}'
                ReceiveHandlers = @(
                    @{ Host = 'GcRxHost64' }
                )
                SendHandlers = @( 
                    @{ Host = 'GcSxHost64'; Default = $false }
                )
            }
            @{ Name = 'FILE'
                MgmtCLSID = '{5E49E3A6-B4FC-4077-B44C-22F34A242FDB}'
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
                MgmtCLSID = '{3979FFED-0067-4CC6-9F5A-859A5DB6E9BB}'
                ReceiveHandlers = @(
                    @{ Host = 'GcCxHost' }
                )
                SendHandlers = @( 
                    @{ Host = 'GcSxHost'; Default = $false }
                )
            }
            @{ Name = 'HTTP'
                MgmtCLSID = '{1C56D157-0553-4345-8A1F-55D2D1A3FFB6}'
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
                MgmtCLSID = '{B0942470-A5A1-45AF-8D01-27481B306441}'
                ReceiveHandlers = @(
                    @{ Host = 'GcCxHost64' }
                )
                SendHandlers = @( 
                    @{ Host = 'GcCxHost64'; Default = $false }
                )
            }
            @{ Name = 'MSMQ'
                MgmtCLSID = '{FF5CEE87-FD92-4422-B47D-F7D033311693}'
                ReceiveHandlers = @(
                    @{ Host = 'GcCxHost64' }
                )
                SendHandlers = @( 
                    @{ Host = 'GcCxHost64'; Default = $false }
                )
            }
            @{ Name = 'MS-SFTP'
                MgmtCLSID = '{F75AEFF5-EBC7-4E7C-A753-FDD68AB45C95}'
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
                MgmtCLSID = '{1787FCC1-9AAA-4BBD-9096-7EB77E3D9D9B}'
                ReceiveHandlers = @(
                    @{ Host = 'GcCxHost64' }
                )
                SendHandlers = @()
            }
            @{ Name = 'SB-Messaging'
                MgmtCLSID = '{9C458D4A-A73C-4CB3-89C4-86AE0103DE2F}'
                ReceiveHandlers = @(
                    @{ Host = 'GcCxHost64' }
                    @{ Host = 'GcRxHost64' }
                )
                SendHandlers = @( 
                    @{ Host = 'GcSxHost64'; Default = $false }
                    @{ Host = 'GcSxPrioHost64'; Default = $false }
                )
            }
            @{ Name = 'Schedule'
                ProductName = 'Schedule'
                ProductId = $null
                SourcePath = '\\<YOUR SHARE>\Adapter Installers\ScheduledTaskAdapter\v7.0.2 BizTalk 2020'
                MgmtCLSID = '{F2FAA6A3-45E2-4C09-8024-425E768CC8EF}'
                ReceiveHandlers = @(
                    @{ Host = 'GcCxHost' }
                    @{ Host = 'GcCxHost64' }
                )
                SendHandlers = @()
            }
            @{ Name = 'SMTP'
                MgmtCLSID = '{8F36B311-B670-4CF6-AAEC-04EBB80ED48D}'
                ReceiveHandlers = @()
                SendHandlers = @( 
                    @{ Host = 'GcSxHost'; Default = $false }
                    @{ Host = 'GcSxHost64'; Default = $false }
                    @{ Host = 'GcSxPrioHost64'; Default = $false }
                )
            }
            @{ Name = 'SOAP'
                MgmtCLSID = '{7E104B2F-003C-4D9F-A6A5-168F727289F0}'
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
                MgmtCLSID = '{467C1A52-373F-4F09-9008-27AF6B985F14}'
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
                MgmtCLSID = '{F15097A3-283A-40B2-ACA7-6B7BAE0A0955}'
                ReceiveHandlers = @(
                    @{ Host = 'GcRxHost64' }
                )
                SendHandlers = @( 
                    @{ Host = 'GcSxHost64'; Default = $false }
                    @{ Host = 'GcSxPrioHost64'; Default = $false }
                )
            }
            @{ Name = 'WCF-Custom'
                MgmtCLSID = '{AF081F69-38CA-4D5B-87DF-F0344B12557A}'
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
                MgmtCLSID = '{16824334-968F-42DB-B33B-6F8D62ED1EBC}'
                ReceiveHandlers = @(
                    @{ Host = 'GcIxHost' }
                )
                SendHandlers = @()
            }
            @{ Name = 'WCF-NetMsmq'
                MgmtCLSID = '{36F48BEB-64AA-4C80-B396-1F2BA53BED84}'
                ReceiveHandlers = @(
                    @{ Host = 'GcCxHost64' }
                )
                SendHandlers = @(
                    @{ Host = 'GcCxHost64'; Default = $false }
                )
            }
            @{ Name = 'WCF-NetNamedPipe'
                MgmtCLSID = '{148D2E28-D634-4127-AA9E-7D6298156BF1}'
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
                MgmtCLSID = '{7FD2DFCD-6A7B-44F9-8387-29457FD2EAAF}'
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
                MgmtCLSID = '{B0A7E20B-9519-4B8E-9137-3A0DEC2792B0}'
                ReceiveHandlers = @(
                    @{ Host = 'GcRxHost64' }
                )
                SendHandlers = @(
                    @{ Host = 'GcSxHost64'; Default = $false }
                    @{ Host = 'GcSxPrioHost64'; Default = $false }
                )
            }
            @{ Name = 'WCF-SQL'
                MgmtCLSID = '{59B35D03-6A06-4734-A249-EF561254ECF7}'
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
                MgmtCLSID = '{E5B2DE81-DE67-4559-869B-20925949A1E0}'
                ReceiveHandlers = @(
                    @{ Host = 'GcIxHost' }
                )
                SendHandlers = @(
                    @{ Host = 'GcSxHost64'; Default = $false }
                    @{ Host = 'GcSxPrioHost64'; Default = $false }
                )
            }
            @{ Name = 'WCF-WSHttp'
                MgmtCLSID = '{2B219014-BA04-4B70-A66B-A8C418B109FD}'
                ReceiveHandlers = @(
                    @{ Host = 'GcIxHost' }
                )
                SendHandlers = @(
                    @{ Host = 'GcSxHost64'; Default = $false }
                    @{ Host = 'GcSxPrioHost64'; Default = $false }
                )
            }
            @{ Name = 'Windows SharePoint Services'
                MgmtCLSID = '{BA7DAD66-5FC8-4A24-A27E-D9F68FD67C3A}'
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
            @{ Name = 'GcIxHost'; Type = 'Isolated'; WindowsGroup = '<DOMAIN>\TBD'; Account = '<DOMAIN>\TBD'; Is32Bit = $false; Trusted = $true; Tracking = $false; Default = $false }
            @{ Name = 'GcCxHost'; Type = 'InProcess'; WindowsGroup = '<DOMAIN>\TBD'; Account = '<DOMAIN>\TBD'; Is32Bit = $true; Trusted = $true; Tracking = $false; Default = $false }
            @{ Name = 'GcCxHost64'; Type = 'InProcess'; WindowsGroup = '<DOMAIN>\TBD'; Account = '<DOMAIN>\TBD'; Is32Bit = $false; Trusted = $true; Tracking = $false; Default = $false }
            @{ Name = 'GcRxHost'; Type = 'InProcess'; WindowsGroup = '<DOMAIN>\TBD'; Account = '<DOMAIN>\TBD'; Is32Bit = $true; Trusted = $true; Tracking = $false; Default = $false }
            @{ Name = 'GcRxHost64'; Type = 'InProcess'; WindowsGroup = '<DOMAIN>\TBD'; Account = '<DOMAIN>\TBD'; Is32Bit = $false; Trusted = $true; Tracking = $false; Default = $false }
            @{ Name = 'GcSxHost'; Type = 'InProcess'; WindowsGroup = '<DOMAIN>\TBD'; Account = '<DOMAIN>\TBD'; Is32Bit = $true; Trusted = $true; Tracking = $false; Default = $false }
            @{ Name = 'GcSxHost64'; Type = 'InProcess'; WindowsGroup = '<DOMAIN>\TBD'; Account = '<DOMAIN>\TBD'; Is32Bit = $false; Trusted = $true; Tracking = $false; Default = $false }
            @{ Name = 'GcSxPrioHost64'; Type = 'InProcess'; WindowsGroup = '<DOMAIN>\TBD'; Account = '<DOMAIN>\TBD'; Is32Bit = $false; Trusted = $true; Tracking = $false; Default = $false }
        )
    }
    Windows = @{
        SourcePath = 'C:\Users\Public\Public Media\Windows 10\Sources\Sxs'
    }
}