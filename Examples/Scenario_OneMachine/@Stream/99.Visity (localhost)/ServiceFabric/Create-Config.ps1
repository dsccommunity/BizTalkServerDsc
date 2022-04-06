# NOTE: This is a stream boot strapper file, all changes made should be done to all stream boot strapper files

# TODO: Merge other roles for node in .MOF-files

. '.\..\..\..\~Script\Enable-Dsc.ps1'
. '.\..\..\..\~Script\Resolve-SecretToken.ps1'
. '.\..\..\..\~Script\Use-Secret.ps1'
. '.\..\..\..\~Script\Merge-PowerShellData.ps1'
. '.\..\..\..\~Config\ServiceFabric.ps1'

$tokensWithSecrets = Resolve-SecretToken -TokenFile '.\..\Token.psd1' 
$mergePowerShellDataParams = @{
    BasePowerShellData = (Import-PowerShellDataFile '.\..\..\Node.psd1')
    OverridingPowerShellData = (Import-PowerShellDataFile '.\..\Node.psd1')
}
$outputPath = ".\..\..\..\@Configuration\$(Get-StreamPath)"

Remove-Item $outputPath -Recurse -Confirm:$false -Force -EA Silent
New-Item -Path $outputPath -ItemType Container -Force

$configParams = @{
    ConfigurationData = (Merge-PowerShellData @mergePowerShellDataParams)
    OutputPath = $outputPath
    SetupCredential = (Use-Secret -Account '<DOMAIN>\<ACCOUNT>' -Secrets ($tokensWithSecrets['Secrets']))
}

ServiceFabric @configParams # NOTE: Creating configurations (.MOF files) for nodes
    
# NOTE: For newbies, how to push config to nodes
# Set-DscLocalConfigurationManager -Path $outputPath -Force -Verbose
# Start-DscConfiguration -Path $outputPath -Force -Wait -Verbose

# NOTE: For newbies, how to diagnose config on nodes
# Get-DscConfigurationStatus | select -ExpandProperty ResourcesNotInDesiredState # On each node use this CmdLet to check status of DSC
# Get-ChildItem Env:GIT_* # To find where configuration came from

# NOTE: For newbies, how to terminate DSC for Hotfixes or Panic situations
# Stop-DscConfiguration -Force # On each node use this CmdLet to stop current DSC execution
# Remove-DscConfigurationDocument -Stage Previous, Pending, Current -Force # On each node use this CmdLet to prevent DSC to start again
