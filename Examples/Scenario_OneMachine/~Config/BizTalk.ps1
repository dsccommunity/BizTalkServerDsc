. "$PSScriptRoot\~BizTalk\BtsConfig.ps1"
. "$PSScriptRoot\~BizTalk\BtsPatch.ps1"
. "$PSScriptRoot\~BizTalk\BtsSetup.ps1"
. "$PSScriptRoot\~Common\FileAbsent.ps1"
. "$PSScriptRoot\~Common\PSToolsSetup.ps1"
. "$PSScriptRoot\~Common\GitSourceEnvVars.ps1"
. "$PSScriptRoot\~Common\ConfigurationManager.ps1"

configuration BizTalk {
    param(
        [Parameter(Mandatory)]
        [PSCredential]$SetupCredential,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [string]$SetupLog,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [string]$PatchLog,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [string]$ConfigurationFile,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [string]$ConfigurationLog,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [hashtable]$Secrets
    )

    Import-DscResource -ModuleName BizTalkServerDsc -ModuleVersion 0.2.0
    Import-DscResource -ModuleName xWindowsUpdate -ModuleVersion 2.8.0.0
    Import-DscResource -ModuleName NetworkingDsc -ModuleVersion 8.2.0
    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion 8.5.0
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 9.1.0
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    [xml]$Configuration = Get-Content -Path $ConfigurationFile
    
    Node $AllNodes.NodeName {
        if (!($Node.NodeRole -contains 'BizTalk')) { return }
        # INFO: Configure BizTalk Hosts Send & Receive Handlers
        $ConfigurationData.BizTalk.Adapters | ForEach-Object {
            param([string]$adapterName = $_.Name)
            $_.SendHandlers | ForEach-Object {
                BizTalkServerSendHandler "$($_.Host)_$($adapterName)" {
                    PsDscRunAsCredential = $SetupCredential
                    Adapter = $adapterName
                    Host = $_.Host
                    Default = $_.Default
                    Ensure = 'Present'
                    DependsOn = @("[BizTalkServerAdapter]$adapterName")
                } 
            }
            $_.ReceiveHandlers | ForEach-Object {
                BizTalkServerReceiveHandler "$($_.Host)_$($adapterName)" {
                    PsDscRunAsCredential = $SetupCredential
                    Adapter = $adapterName
                    Host = $_.Host
                    Ensure = 'Present'
                    DependsOn = @("[BizTalkServerAdapter]$adapterName")
                }
            }
        }  
        # INFO: Register BizTalk Adapters & install if needed
        $ConfigurationData.BizTalk.Adapters | Where-Object { $_.MgmtCLSID } | ForEach-Object {
            $bizTalkServerAdapterDependsOn = @(if ($_.SourcePath) { 
                    @('[Script]BtsConfig', "[Package]BtsAdapterSetup_$($_.Name)") 
                } else { 
                    @('[Script]BtsConfig') 
                } )
            $bizTalkServerAdapterDependsOn += @($ConfigurationData.BizTalk.Hosts | % { "[BizTalkServerHostInstance]$($_.Name)" })
            BizTalkServerAdapter $_.Name {
                PsDscRunAsCredential = $SetupCredential
                Name = $_.Name
                MgmtCLSID = $_.MgmtCLSID
                Ensure = 'Present'
                DependsOn = $bizTalkServerAdapterDependsOn
            }
            if ($_.SourcePath) {
                Package "BtsAdapterSetup_$($_.Name)" {
                    PsDscRunAsCredential = $SetupCredential
                    Name = "$($_.ProductName)"
                    ProductId = "$($_.ProductId)"
                    Path = "$($_.SourcePath)"
                    Ensure = 'Present' 
                    DependsOn = @('[Script]BtsConfig') + @($ConfigurationData.BizTalk.Hosts | % { "[BizTalkServerHostInstance]$($_.Name)" })
                }
            }
        }
        # INFO: Configure BizTalk Hosts & Host Instances
        $ConfigurationData.BizTalk.Hosts | ForEach-Object {
            BizTalkServerHostInstance $_.Name {
                PsDscRunAsCredential = $SetupCredential
                Host = $_.Name
                Credential = (Use-Secret -Account $_.Account -Secrets $Secrets)
                Ensure = 'Present' 
                DependsOn = @("[BizTalkServerHost]$($_.Name)") 
            } 
            BizTalkServerHost $_.Name {
                PsDscRunAsCredential = $SetupCredential
                Name = $_.Name
                Default = $_.Default
                Type = $_.Type
                Is32Bit = $_.Is32Bit
                Trusted = $_.Trusted
                Tracking = $_.Tracking
                WindowsGroup = $_.WindowsGroup
                Ensure = 'Present' 
                DependsOn = @('[Script]BtsConfig') 
            }
        }
        # INFO: Configure BizTalk
        $tmsAccountXmlPath = '/Configuration/Feature[@Name=''TMS'']/NTService'
        $tmsAccountNode = $Configuration.SelectSingleNode($tmsAccountXmlPath)
        $tmsAccount = if ($tmsAccountNode) { "$($tmsAccountNode.Domain)\$($tmsAccountNode.UserName)" }
        $btsConfigParams = @{ 
            SetupCredential = $SetupCredential
            ConfigurationFile = $ConfigurationFile # INFO: String expansion will accour on remote node
            ConfigurationLog = $ConfigurationLog # INFO: String expansion will accour on remote node
            TmsAccount = $tmsAccount
            DependsOnResource = @('[Script]BtsConfigLog')
        }
        BtsConfig @btsConfigParams
        # INFO: Backup BizTalk Setup log file
        $btsConfigLogParams = @{ 
            SetupCredential = $SetupCredential
            ResourceName = 'BtsConfigLog'
            FilePath = $ConfigurationLog # INFO: String expansion will accour on remote node
            Backup = $true
            DependsOnResource = @('[Script]SecretBackup')
        }
        FileAbsent @btsConfigLogParams
        # INFO: Backup BizTalk SSO Secret Backup file
        $secretBackupFileXmlPath = '/Configuration/Feature/Question/Answer/FILE[@ID=''SSO_ID_BACKUP_SECRET_FILE'']/Value/text()'
        $secretBackupFileName = $Configuration.SelectSingleNode($secretBackupFileXmlPath).Value
        $secretBackupParams = @{ 
            SetupCredential = $SetupCredential
            ResourceName = 'SecretBackup'
            FilePath = $secretBackupFileName
            Backup = $true
            DependsOnResource = if ($ConfigurationData.BizTalk.Patch) { @('[Script]BtsPatch') } else { @('[Script]BtsSetup') }
        }
        FileAbsent @secretBackupParams
        # INFO: Install BizTalk CU binares
        if ($ConfigurationData.BizTalk.Patch) {
            $btsPatchParams = @{
                SetupCredential = $SetupCredential
                PatchName = $ConfigurationData.BizTalk.Patch.PatchName
                PatchId = $ConfigurationData.BizTalk.Patch.PatchId
                SourcePath = $ConfigurationData.BizTalk.Patch.SourcePath
                PatchLog = $PatchLog
                DependsOnResource = @('[Script]BtsPatchLog')
            }
            BtsPatch @btsPatchParams
            # INFO: Backup BizTalk Patch log file
            $btsPatchLogParams = @{ 
                SetupCredential = $SetupCredential
                ResourceName = 'BtsPatchLog'
                FilePath = $PatchLog # INFO: String expansion will accour on remote node
                Backup = $true
                DependsOnResource = @('[Script]BtsSetup')
            }
            FileAbsent @btsPatchLogParams
        }
        # INFO: Setup BizTalk binaries
        $btsSetupParams = @{
            SetupCredential = $SetupCredential
            ProductName = $ConfigurationData.BizTalk.ProductName
            ProductId = $ConfigurationData.BizTalk.ProductId
            SourcePath = $ConfigurationData.BizTalk.SourcePath
            AddLocal = if ($Node.NodeType -eq 'Client') { 
                    'ALL'
                } elseif ($Node.NodeType -eq 'Server') { 
                    'WMI,BizTalk,WCFSQLAdapter,Engine,MOT,Runtime'
                } else {
                    throw 'Invalid NodeType' 
                }
            SetupLog = $SetupLog
            DependsOnResource = @('[Script]BtsSetupLog')
        }
        BtsSetup @btsSetupParams  
        # INFO: Backup BizTalk Setup log file
        $btsSetupLogParams = @{ 
            SetupCredential = $SetupCredential
            ResourceName = 'BtsSetupLog'
            FilePath = $SetupLog # INFO: String expansion will accour on remote node
            Backup = $true
            DependsOnResource = @('[Archive]PSTools')
        }
        FileAbsent @btsSetupLogParams
        # INFO: Download and Setup PSTools
        $psToolsSetupParams = @{ 
            SetupCredential = $SetupCredential
        }
        PSToolsSetup @psToolsSetupParams
        # INFO: Define enviroment variables for where this config came from
        $gitSourceEnvVarsParams = @{
            SetupCredential = $SetupCredential
        }
        GitSourceEnvVars @gitSourceEnvVarsParams
        # INFO: Define how DSC Local Configuration Manager should work
        ConfigurationManager
    } 
}