. '..\..\..\~Script\Enable-Dsc.ps1'

Enable-Dsc -Node (Import-PowerShellDataFile '..\Node.psd1') -NodeRole @('BizTalk')