configuration WinScpConfig {
    param(
        [Parameter(Mandatory)]
        [PSCredential]$SetupCredential,
        [string[]]$DependsOnResource
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    $btsSvcConfigFiles = @('BTSNTSvc.exe.config', 'BTSNTSvc64.exe.config')
    $runtimeXPath = "/*[local-name()='configuration']/*[local-name()='runtime']"
    $assemblyBindingXPath = "$runtimeXPath/*[local-name()='assemblyBinding']"
    $dependentAssemblyXPath = "$assemblyBindingXPath/*[local-name()='dependentAssembly']"
    $assemblyIdentiyXPath = "$dependentAssemblyXPath/*[local-name()='assemblyIdentity'][@name='WinSCPnet']"
    $winScpAssemblyVersion = '1.8.3.12002'
    $winScpAssemblyRedirectXml = @"
<dependentAssembly xmlns='urn:schemas-microsoft-com:asm.v1'>
    <assemblyIdentity name="WinSCPnet" publicKeyToken="2271ec4a3c56d0bf" culture="neutral" />
    <bindingRedirect oldVersion="0.0.0.0-$winScpAssemblyVersion" newVersion="$winScpAssemblyVersion"/>
</dependentAssembly>
"@

    File 'WinSCPConfig' {
        PsDscRunAsCredential = $SetupCredential
        SourcePath = "${Env:ProgramFiles(x86)}\WinSCP\WinSCP.exe"
        DestinationPath = "${Env:ProgramFiles(x86)}\Microsoft BizTalk Server\WinSCP.exe"
        MatchSource = $true
        Checksum = 'ModifiedDate'
        DependsOn = @('[Script]WinSCPAssemblyRedirect')
    }
    Script 'WinSCPAssemblyRedirect' {
        PsDscRunAsCredential = $SetupCredential
        GetScript = {
            $ErrorActionPreference = 'Stop'

            [Reflection.Assembly]::LoadWithPartialName("System.Xml.Linq") | Out-Null

            $result = $using:btsSvcConfigFiles | ForEach-Object {
                $btsSvcConfig = [System.Xml.Linq.XDocument]::Load("${Env:ProgramFiles(x86)}\Microsoft BizTalk Server\$_")
                [System.Xml.XPath.Extensions]::XPathSelectElement($btsSvcConfig, $using:assemblyIdentiyXPath)
            } | Where-Object { $null -ne $_ }

            return @{
                Result = $result.Count -eq $using:btsSvcConfigFiles.Count 
            }
        }
        SetScript = {
            $ErrorActionPreference = 'Stop'

            $winScpAssemblyRedirect = [xml]$using:winScpAssemblyRedirectXml

            $using:btsSvcConfigFiles | ForEach-Object {
                [xml]$btsSvcConfig = Get-Content -Path "${Env:ProgramFiles(x86)}\Microsoft BizTalk Server\$_"
                $assemblyIdentity = $btsSvcConfig.SelectSingleNode($using:assemblyIdentiyXPath)
                
                if ($assemblyIdentity) {
                    $assemblyIdentity.ParentNode.ParentNode.ReplaceChild($btsSvcConfig.ImportNode(
                        $winScpAssemblyRedirect.DocumentElement, $true), $assemblyIdentity.ParentNode)
                } else {
                    $assemblyBinding = $btsSvcConfig.SelectSingleNode($using:assemblyBindingXPath) 
                    $assemblyBinding.AppendChild($btsSvcConfig.ImportNode($winScpAssemblyRedirect.DocumentElement, $true))
                }

                $btsSvcConfig.Save("${Env:ProgramFiles(x86)}\Microsoft BizTalk Server\$_")
            }
        }
        TestScript = {
            $ErrorActionPreference = 'Stop'

            Write-Verbose "Node: $($Env:COMPUTERNAME); Domain: $($Env:USERDOMAIN); Account: $($Env:USERNAME)"

            $state = [scriptblock]::Create($GetScript).Invoke()

            if ($state.Result) {
                Write-Verbose 'WinSCP is configured for BizTalk'
            } else {
                Write-Verbose 'WinSCP is not configured for BizTalk'
            }

            return $state.Result
        }
        DependsOn = @('[File]WinSCP_dll')
    }
    File 'WinSCP_dll' {
        PsDscRunAsCredential = $SetupCredential
        SourcePath = "${Env:ProgramFiles(x86)}\WinSCP\WinSCPnet.dll"
        DestinationPath = "${Env:ProgramFiles(x86)}\Microsoft BizTalk Server\WinSCPnet.dll"
        MatchSource = $true
        Checksum = 'ModifiedDate'
        DependsOn = $DependsOnResource
    }
}