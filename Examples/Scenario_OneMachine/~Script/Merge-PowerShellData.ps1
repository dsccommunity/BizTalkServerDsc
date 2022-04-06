# TODO: Verbose output of merged PowerShellData

. "$PSScriptRoot\Copy-Object.ps1"

function Merge-PowerShellData { 
    [CmdletBinding()] 
    param (
        [hashtable]$BasePowerShellData = @{ },
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [hashtable]$OverridingPowerShellData
    )

    #Casting the AllNodes array to a list in order to add elements to it
    $baseNodes = $BasePowerShellData.AllNodes -as [System.Collections.ArrayList]

    foreach ($node in $OverridingPowerShellData.AllNodes) {
        $nodeInBaseData = $BaseNodes | Where-Object { $_.NodeName -eq $Node.NodeName }

        If ($nodeInBaseData) {
            Write-Verbose "The node $($Node.NodeName) is already present in the base config."

            # Removing the NodeName entry from the current Node to keep only the actual settings
            $node.Remove('NodeName')

            foreach ($overrideSettingKey in $Node.keys) {
                if ($nodeInBaseData.ContainsKey($overrideSettingKey)) {
                    Write-Verbose "$($nodeInBaseData.NodeName).$overrideSettingKey, in node $($nodeInBaseData.NodeName) is present in the base config, overriding its value."

                    $nodeInBaseData.$overrideSettingKey = $node.$overrideSettingKey
                } else {
                    Write-Verbose "The setting $overrideSettingKey, in node $($nodeInBaseData.NodeName) is absent in the base config, adding it."

                    $nodeInBaseData.Add($overrideSettingKey, $node.$overrideSettingKey)
                }
            }
        } else { # If the node is not already present in the base base config
            Write-Verbose "The node $($node.NodeName) is absent in the base config, adding it."

            $null = $baseNodes.Add($node)
        }
    }

    foreach ($nonNodeKey in ($OverridingPowerShellData.Keys | Where-Object { $_ -ne 'AllNodes' })) {
        if ($null -eq ($BasePowerShellData.$nonNodeKey)) {
            # Use NonNodeData, in its entirety, from the Override data if NonNodeData does not exist in the Base configuration
            $BasePowerShellData.$nonNodeKey = $OverridingPowerShellData.$nonNodeKey
        } else {
            if ($BasePowerShellData.$nonNodeKey.GetType().Name -eq 'object[]') {
                $BasePowerShellData.$nonNodeKey = $OverridingPowerShellData.$nonNodeKey
            } else {
                foreach ($nonNodeSetting in $OverridingPowerShellData.$nonNodeKey.GetEnumerator()) {
                    # Checking if the setting already exists in the Base config

                    if ($BasePowerShellData.$nonNodeKey.ContainsKey($nonNodeSetting.Key)) {
                        Write-Verbose -Message "The setting $($nonNodeSetting.Key) is present in the base data, overring its value."

                        $BasePowerShellData.$nonNodeKey.Set_Item($nonNodeSetting.Key, $nonNodeSetting.Value)
                    } else {
                        Write-Verbose -Message "The setting $($nonNodeSetting.Key) is absent in the base data, adding it."

                        $BasePowerShellData.$nonNodeKey.Add($nonNodeSetting.Key, $nonNodeSetting.Value)
                    }
                }
            }
        }
    }

    $mergedData = $BasePowerShellData
    # Converting AllNodes back to an [array] because PSDesiredStateConfiguration doesn't accept an [ArrayList]
    $nodesBackToArray = $baseNodes -as [array]
    $mergedData.AllNodes = $nodesBackToArray

    return $mergedData
}