$moduleName = 'BizTalkServerDsc'
$moduleVersion = '0.2.0'

$location = Split-Path -parent $PSCommandPath

$destination = "$env:ProgramFiles\WindowsPowerShell\Modules\$moduleName\$moduleversion"

Remove-Item -Path $destination -Force -Recurse

# Create folders
New-Item -Name $destination -ItemType Directory -Force
New-Item -Name $destination\Examples -ItemType Directory -Force
New-Item -Name $destination\Tests -ItemType Directory -Force

# Copy Resources and Manifest
Get-ChildItem -Path $location -Filter BizTalkServerDsc.psd1 -Recurse | Copy-Item -Destination $destination
Get-ChildItem -Path $location -Filter MSFT_BizTalkServerDsc.psm1 -Recurse | Copy-Item -Destination $destination
Get-ChildItem -Path $location -Filter README.md -Recurse | Copy-Item -Destination $destination

# Copy Examples
Copy-Item -Path $location\Examples\* -Destination $destination\Examples -Recurse -Verbose

# Copy Tests
Copy-Item -Path $location\Tests\* -Destination $destination\Tests  -Recurse -Verbose

# Run Script Analyzer
Invoke-ScriptAnalyzer -Path $destination

# Publish Module
Invoke-Build -File ./build.ps1 -Configuration "Release"

