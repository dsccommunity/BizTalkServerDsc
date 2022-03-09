configuration ConfigurationManager {
    param(
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    LocalConfigurationManager {
        DebugMode = 'All'
        AllowModuleOverwrite = $true
        ConfigurationMode = 'ApplyAndAutoCorrect'
        RefreshMode = 'Push'
        RefreshFrequencyMins = 30
        ConfigurationModeFrequencyMins = 15
        RebootNodeIfNeeded = $true
        ActionAfterReboot = 'ContinueConfiguration'
    }
}