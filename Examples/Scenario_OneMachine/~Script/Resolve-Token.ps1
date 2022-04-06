function Resolve-Token {
	[CmdletBinding()]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$Source,
		[ValidateNotNullOrEmpty()]
		[Hashtable]$Tokens,
		[string]$StartTokenPattern = "{{",
		[string]$EndTokenPattern = "}}",
		[string]$NullPattern = ":::NULL:::",
		[switch]$NoWarning
	)

	function GetTokenCount($line) {
		($line | Select-String -Pattern "$($StartTokenPattern).+?$($EndTokenPattern)" -AllMatches).Matches.Count
	}

	# Go through each line of the InputFile and replace the tokens with their values
	$totalTokens = 0
	$missedTokens = 0
	$usedTokens = New-Object -TypeName "System.Collections.ArrayList"
	$target = ''

	$Source | ForEach-Object {
		$line = $_
		$totalTokens += GetTokenCount($line)

		foreach ($key in $Tokens.Keys) {
			$token = "$($StartTokenPattern)$([regex]::Escape($key))$($EndTokenPattern)"
			$value = $Tokens.$key

			if ($line -match $token) {
				$usedTokens.Add($key) | Out-Null

				if ($value -eq $NullPattern) {
					$value = ""
				}

				Write-Verbose "Replacing $token with $value"

				$line = $line -replace "$token", "$value"
			}
		}

		$target += $line 
		$missedTokens += GetTokenCount($line)		
	}

	# Write warning if there were tokens given in the Token parameter which were not replaced
	if (!$NoWarning -and $usedTokens.Count -ne $Tokens.Count) {
		$unusedTokens = New-Object -TypeName "System.Collections.ArrayList"

		foreach ($token in $Tokens.Keys) {
			if (!$usedTokens.Contains($token)) {
				$unusedTokens.Add($token) | Out-Null
			}
		}

		Write-Warning "The following tokens were not used: $($unusedTokens -join ', ')"
	}

	# Write status message -- warn if there were tokens in the file that were not replaced
	$message = "Processed: $($totalTokens - $missedTokens) out of $totalTokens tokens replaced"

	if ($missedTokens -gt 0) {
		Write-Warning $message
	}
	else {
		Write-Host $message
	}

	return $target 
}

<#

.SYNOPSIS
Replace tokens in a file with values.

.DESCRIPTION
Finds tokens in a given file and replace them with values. It is best used to replace configuration values in a release pipeline.

.PARAMETER Source
The source data containing tokens.

.PARAMETER Tokens
A hashtable containing the tokens and the value that should replace them.

.PARAMETER StartTokenPattern
The start of the token, e.g. "{{".

.PARAMETER EndTokenPattern
The end of the token, e.g. "}}".

.PARAMETER NullPattern
The pattern that is used to signify $null. The reason for using this is that
you cannot set an environment variable to null, so instead, set the environment
variable to this pattern, and this script will replace the token with an empty string.

.PARAMETER NoWarning
If this is used, the script will not warn about tokens that cannot be found in the
input file. This is useful when using environment variables to replace tokens since
there will be a lot of warnings that aren't really warnings.

.EXAMPLE
config.template.json:
{
  "url": "{{URL}}",
  "username": "{{USERNAME}}",
  "password": "{{PASSWORD}}"
}

Replace-Tokens `
  -Source @"config.template.json:
{
  "url": "{{URL}}",
  "username": "{{USERNAME}}",
  "password": "{{PASSWORD}}"
}@" `
  -Tokens @{URL="http://localhost:8080";USERNAME="admin";PASSWORD="Test123"} `
  -StartTokenPattern "{{" `
  -EndTokenPattern "}}"

config.json (result):
{
  "url": "http://localhost:8080",
  "username": "admin",
  "password": "Test123"
}

#>
