#Requires -PSEdition Desktop
#Requires -Version 5.1
#Requires -RunAsAdministrator

function Enable-Dsc {
    [CmdletBinding()] 
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [hashtable]$Node,
        [string[]]$NodeRole
    )
    
    $ErrorActionPreference = 'Stop'
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
    Get-Job | Remove-Job -Force # INFO: Remove any previous jobs

    # INFO: Retreive DSC resources needed for all nodes for all roles
    $commonModules = $Node.Modules

    $Node.AllNodes | # INFO: Filter which nodes should be used by role
        Where-Object { ($_.NodeName -ne '*') -and 
            (($null -eq $NodeRole) -or (Compare-Object $NodeRole $_.NodeRole -Include -Exclude)) } | 
                ForEach-Object {
        $combinedModules = $commonModules

        $_.NodeRole | # INFO: Filter which roles should be used for current node
            Where-Object { ($null -eq $NodeRole) -or (Compare-Object $_ $NodeRole -Include -Exclude) } | 
                ForEach-Object {
            # INFO: Retreive DSC resources for current node and current role 
            $roleModules = Invoke-Expression "`$Node.$_.Modules"
            # INFO: Add DSC resources for role to combined resource modules
            $combinedModules += $roleModules 
        }

        Write-Progress -Activity 'Preparing nodes for DSC' -Status "Node: $($_.NodeName) with $(($combinedModules | % { $_.Name }) -join ', ')"

        try { # INFO: Install PowerShell modules on nodes # NOTE: This is executed on remote node, it's hard to debug so be carefull
            Invoke-Command -Computer $_.NodeName -Script {
                param([array]$modules)

                #Requires -Version 5.1
                #Requires -RunAsAdministrator

                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                $ErrorActionPreference = 'Stop'
                Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
                Set-Item -Path 'WSMan:\localhost\MaxEnvelopeSizeKb' -Value 8192

                if (!(Get-PackageProvider -Name 'NuGet')) { # INFO: Install NuGet package provider if not present
                    Install-PackageProvider -Name 'NuGet' -Scope AllUsers -Confirm:$false -Force | Out-Null
                }

                if (($psGalleryRepo = Get-PSRepository -Name 'PSGallery') -and 
                    $psGalleryRepo.InstallationPolicy -ne 'Trusted') { # INFO: Set PSGallery installation policy to trusted if it isn't
                    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
                }

                $modules | Where-Object { $null -ne $_ } | Where-Object { # INFO: Install PowerShell modules not present on node
                    param(
                        [string]$RequiredVersion = $_.Version
                    )
                    !(Get-Module -Name $_.Name -ListAvailable | Where-Object { $_.Version -eq $RequiredVersion } ) 
                } | ForEach-Object {
                    Find-Module -Name $_.Name -RequiredVersion $_.Version | 
                        Install-Module -Scope AllUsers -AllowClobber
                }
            } -Argument (, $combinedModules) -AsJob -EnableNetwork 
        } catch {
            Complete-Job
            
            throw 
        }
    } 

    Complete-Job

    Write-Progress -Activity 'Preparing nodes for DSC' -Status "Done"
}

function Complete-Job {
    [CmdletBinding()]
    param()

    try {
        Get-Job | Wait-Job; Get-Job | Receive-Job
        Get-Job | Remove-Job
    } catch {
        Get-Job | Receive-Job

        throw
    } finally {
        Get-Job | Remove-Job -Force
    }
}

function Get-StreamPath {
    [CmdletBinding()]
    param()
 
    "$((Get-Item .).Parent.Name)\$((Get-Item .).Name)"
}