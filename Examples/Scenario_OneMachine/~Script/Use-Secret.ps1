# TODO: Cache secrets looked up for performance

#Requires -PSEdition Desktop
#Requires -Version 5.1
#Requires -RunAsAdministrator

#Requires -Modules @{ ModuleName = 'Microsoft.PowerShell.SecretManagement'; ModuleVersion = '1.1.2' } 
<# #Requires -Modules @{ ModuleName = 'Microsoft.PowerShell.SecretStore'; ModuleVersion = '1.0.6' }
#Requires -Modules @{ ModuleName = 'SecretManagement.BitWarden'; ModuleVersion = '0.1.1' } 
 #>
function Use-Secret {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '', Scope='Function')]
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName = 'AccountPassword', Mandatory=$true)]
        [Parameter(ParameterSetName = 'AccountLookupPassword', Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Account,
        [Parameter(ParameterSetName = 'AccountLookupPassword', Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [hashtable]$Secrets,
        [Parameter(ParameterSetName = 'AccountPassword', Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Password
    )
    
    if ($PSCmdlet.ParameterSetName -eq 'AccountPassword') {
        (New-Object System.Management.Automation.PsCredential(
            $Account, (ConvertTo-SecureString $Password -AsPlainText -Force)))
    } elseif ($PSCmdlet.ParameterSetName -eq 'AccountLookupPassword') {
        # TODO: BitWarden via Microsoft.PowerShell.SecretManagement
        $Password = $Secrets[$Account] 

        (New-Object System.Management.Automation.PsCredential(
            $Account, (ConvertTo-SecureString $Password -AsPlainText -Force)))
    } else {
        throw "Invalid Use-Secret call: '$($PSCmdlet.ParameterSetName)'"
    } 
}