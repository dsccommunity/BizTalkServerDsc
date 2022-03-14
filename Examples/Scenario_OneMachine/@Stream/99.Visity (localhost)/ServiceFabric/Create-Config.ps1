. '.\..\..\..\~Script\Enable-Dsc.ps1'

Remove-Item ($outputPath = ".\..\..\..\@Template\$(Get-StreamPath)") -Recurse -Confirm:$false -Force -EA Silent

. '.\..\..\..\~Config\ServiceFabric.ps1'

$configParams = @{
    ConfigurationData = (Import-PowerShellDataFile '.\..\Node.psd1')
    OutputPath = $outputPath
    SetupCredential = (New-Secret -Account '*******\******' -Password '******')
}

ServiceFabric @configParams
# TODO: Merge other node roles
    
# Set-DscLocalConfigurationManager -Path $outputPath -Force -Verbose #-Computer Node1,Node2 #PUSH
# Start-DscConfiguration -Path $outputPath -Force -Wait -Verbose #-Computer Node1,Node2 #PUSH
# Get-DscConfigurationStatus | select -ExpandProperty ResourcesNotInDesiredState # On each node use this command to check status of DSC
# Get-ChildItem Env:GIT_* # To find where configuration came from
