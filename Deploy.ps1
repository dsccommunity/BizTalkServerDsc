$moduleName = 'BizTalkServer'
$moduleVersion = '0.1.1.0'

$location = Split-Path -parent $PSCommandPath

$destination = "$env:ProgramFiles\WindowsPowerShell\Modules\$moduleName\$moduleversion"

Remove-Item -Path $env:ProgramFiles\WindowsPowerShell\Modules\$moduleName -Force -Recurse

mkdir $env:ProgramFiles\WindowsPowerShell\Modules\$moduleName -Force

mkdir $destination -Force

mkdir $destination\Examples -Force

mkdir $destination\Tests -Force

#Resources and Manifest

get-childitem -path $location -filter BizTalkServer.psd1 -recurse | copy-item -destination $destination

get-childitem -path $location -filter MSFT_BizTalkServer.psm1 -recurse | copy-item -destination $destination

get-childitem -path $location -filter README.md -recurse | copy-item -destination $destination

#Examples

Copy-Item -Path $location\Examples\* -Destination $destination\Examples -Recurse -Verbose

#Tests

Copy-Item -Path $location\Tests\* -Destination $destination\Tests  -Recurse -Verbose

# Script Analyzer

Invoke-ScriptAnalyzer -Path C:\Development\Integration\Deployment\Dsc\Modules\BizTalkServer

#Publish Module

