$ErrorActionPreference = 'Stop'

$moduleName = 'BizTalkServerDsc'
$moduleVersion = '0.2.0'
$location = Split-Path -parent $PSCommandPath
$destination = "$env:ProgramFiles\WindowsPowerShell\Modules\$moduleName\$moduleversion"

# Remove current module
Remove-Item -Path $destination -Force -Recurse -EA Silent

# Create main folder
New-Item -Path $destination -ItemType Container -Force 

# Copy Manifest 
Copy-Item -Path "$location\LICENSE" -Destination "$destination"
Copy-Item -Path "$location\README.md" -Destination "$destination" 
Copy-Item -Path "$location\$moduleName\$moduleName.psd1" -Destination "$destination\$moduleName.psd1"

# Copy Resources 
Copy-Item -Path "$location\$moduleName\DscClassResources" -Recurse "$destination\DscClassResources"

# Run Script Analyzer
Invoke-ScriptAnalyzer -Path $destination | Where-Object { $_.Severity -ne 'Information' } | Format-Table -AutoSize