# NOTE: This is a stream boot strapper file, all changes made should be done to all stream boot strapper files
# TODO: Merge other roles for node in .MOF-files

. '.\..\..\..\~Script\Enable-Dsc.ps1'
. '.\..\..\..\~Script\Resolve-SecretToken.ps1'
. '.\..\..\..\~Script\Use-Secret.ps1'
. '.\..\..\..\~Script\Merge-PowerShellData.ps1'
. '.\..\..\..\~Config\BizTalk.ps1'

$tokensWithSecrets = Resolve-SecretToken -TokenFile '.\..\Token.psd1' 
$mergePowerShellDataParams = @{
    BasePowerShellData = (Import-PowerShellDataFile '.\..\..\Node.psd1')
    OverridingPowerShellData = (Import-PowerShellDataFile '.\..\Node.psd1')
}
$outputPath = ".\..\..\..\@Configuration\$(Get-StreamPath)"

Remove-Item -Path $outputPath -Recurse -Confirm:$false -Force -EA Silent
New-Item -Path $outputPath -ItemType Container -Force
Resolve-Token -Source (Get-Content '.\Configuration.xml' -Raw) -Tokens ($tokensWithSecrets['Tokens']) |
    Set-Content -Path "$outputPath\BtsConfig.xml"

$configParams = @{
    ConfigurationData = (Merge-PowerShellData @mergePowerShellDataParams)
    OutputPath = $outputPath
    SetupCredential = (Use-Secret -Account '<DOMAIN>\<ACCOUNT>' -Secrets ($tokensWithSecrets['Secrets']))
    SetupLog = 'C:\Temp\BtsSetup.log'
    PatchLog = 'C:\Temp\BtsPatch.log'
    ConfigurationFile = ((Get-ChildItem -Path "$outputPath\BtsConfig.xml").FullName)
    ConfigurationLog = 'C:\Temp\BtsConfig.log'
    Secrets = ($tokensWithSecrets['Secrets'])
}

BizTalk @configParams # NOTE: Creating configurations (.MOF files) for nodes

# NOTE: For newbies, how to push config to nodes
# Set-DscLocalConfigurationManager -Path $outputPath -Force -Verbose # INFO: Only has to be run once when node (server) is new
# Start-DscConfiguration -Path $outputPath -Force -Wait -Verbose

# NOTE: For newbies, how to diagnose config on nodes
# Get-DscConfigurationStatus | select -ExpandProperty ResourcesNotInDesiredState # On each node use this CmdLet to check status of DSC
# Get-ChildItem Env:GIT_* # To find where configuration came from

# NOTE: For newbies, how to terminate DSC for Hotfixes or Panic situations
# Stop-DscConfiguration -Force # On each node use this CmdLet to stop current DSC execution
# Remove-DscConfigurationDocument -Stage Previous, Pending, Current -Force # On each node use this CmdLet to prevent DSC to start again
