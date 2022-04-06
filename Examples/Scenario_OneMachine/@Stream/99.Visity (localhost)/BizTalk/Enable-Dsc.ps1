# NOTE: This is a stream boot strapper file, all changes made should be done to all stream boot strapper files

. '.\..\..\..\~Script\Enable-Dsc.ps1'
. '.\..\..\..\~Script\Merge-PowerShellData.ps1'

$mergePowerShellDataParams = @{
    BasePowerShellData = (Import-PowerShellDataFile '.\..\..\Node.psd1')
    OverridingPowerShellData = (Import-PowerShellDataFile '.\..\Node.psd1')
}
Enable-Dsc -Node (Merge-PowerShellData @mergePowerShellDataParams) -NodeRole @('BizTalk')