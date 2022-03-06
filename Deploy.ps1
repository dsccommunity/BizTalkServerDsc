$moduleName = 'BizTalkServer'
$moduleVersion = '0.1.0'

$location = Split-Path -parent $PSCommandPath

$destination = "$env:ProgramFiles\WindowsPowerShell\Modules\$moduleName\$moduleversion"

Remove-Item -Path $destination -Force -Recurse

mkdir $destination -Force

mkdir $destination\Examples -Force

mkdir $destination\Tests -Force

#Resources and Manifest

get-childitem -path $location -filter BizTalkServerDsc.psd1 -recurse | copy-item -destination $destination

get-childitem -path $location -filter MSFT_BizTalkServerDsc.psm1 -recurse | copy-item -destination $destination

get-childitem -path $location -filter README.md -recurse | copy-item -destination $destination

#Examples

Copy-Item -Path $location\Examples\* -Destination $destination\Examples -Recurse -Verbose

#Tests

Copy-Item -Path $location\Tests\* -Destination $destination\Tests  -Recurse -Verbose

# Script Analyzer

Invoke-ScriptAnalyzer -Path $destination

#Publish Module

