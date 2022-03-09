. "$PSScriptRoot\~Common\GitSourceEnvVars.ps1"
. "$PSScriptRoot\~Common\ConfigurationManager.ps1"

configuration ServiceFabric {
    param(
        [PSCredential]$SetupCredential
    )

    Import-DscResource -ModuleName ServiceFabricDsc -ModuleVersion 1.0.0.1
    Import-DscResource -ModuleName NetworkingDsc -ModuleVersion 8.2.0
    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion 8.5.0
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    
    Node $AllNodes.NodeName {
        if (!($Node.NodeRole -contains 'ServiceFabric')) { return }

        $gitSourceEnvVarsParams = @{
            SetupCredential = $SetupCredential
        }
        GitSourceEnvVars @gitSourceEnvVarsParams
        ConfigurationManager    
    }
}