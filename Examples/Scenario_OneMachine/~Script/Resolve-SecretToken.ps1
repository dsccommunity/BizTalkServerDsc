. "$PSScriptRoot\Resolve-Token.ps1"

function Resolve-SecretToken {
	[CmdletBinding()]
	param(
		[ValidateNotNullOrEmpty()]
		[string]$TokenFile
	)

	$tokenContent = Get-Content $TokenFile -Raw
	$tokenData = $tokenContent | Invoke-Expression 
	$Secrets = $tokenData['Secrets']
	$tokenContentWithSecrets = Resolve-Token -Source $tokenContent -Tokens $secrets
	$tokenDataWithSecrets = $tokenContentWithSecrets | Invoke-Expression
	
	return $tokenDataWithSecrets
}
