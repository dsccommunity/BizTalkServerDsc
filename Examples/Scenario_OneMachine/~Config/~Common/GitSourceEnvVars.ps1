configuration GitSourceEnvVars {
    param(
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [PSCredential]$SetupCredential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration

    if (Get-Command 'git' -EA Silent) {
        $gitClone = Get-Item .
        while (($null -ne $gitClone) -and ($null -eq (Get-Item "$($gitClone.FullName)\.git" -Force -EA Silent))) { 
            $gitClone = $gitClone.Parent 
        }
        Environment 'GitClone' {
            PsDscRunAsCredential = $SetupCredential
            Name = 'GIT_CLONE'
            Value = "$gitClone"
            Ensure = 'Present'
        }
        $gitBranch = (git branch | select-string "^\*\s*(?<branch>.*)$" -All | select -Expand Matches | 
            select -Expand Groups | Where-Object { $_.Name -eq 'branch' } | select Value).Value
        Environment 'GitBranch' {
            PsDscRunAsCredential = $SetupCredential
            Name = 'GIT_BRANCH'
            Value = "$gitBranch"
            Ensure = 'Present'
        }
        $gitRevision = git rev-parse "$gitBranch"
        Environment 'GitRevision' {
            PsDscRunAsCredential = $SetupCredential
            Name = 'GIT_REVISION'
            Value = "$gitRevision"
            Ensure = 'Present'
        }
        $gitRevisionDate = (git log "$gitRevision" -1 | select-string "^Date\:\s*(?<date>.*)$" -All | select -Expand Matches | 
            select -Expand Groups | Where-Object { $_.Name -eq 'date' } | select Value).Value
        Environment 'GitRevisionDate' {
            PsDscRunAsCredential = $SetupCredential
            Name = 'GIT_REVISION_DATE'
            Value = "$gitRevisionDate"
            Ensure = 'Present'
        }
    } 
}