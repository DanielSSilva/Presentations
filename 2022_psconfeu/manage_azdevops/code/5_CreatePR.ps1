$projectName = "PSConfEU22"
$repoName = "PSConfEU22"

$repoId = Get-VSTeamGitRepository -Name $repoName -ProjectName $projectName | Select-Object -ExpandProperty Id

Add-VSTeamPullRequest -RepositoryId $repoId -SourceRefName "refs/heads/feature/psconfeudemo" -TargetRefName "refs/heads/main" -Title "Testing PR from VSTeam PowerShellModule" -Description "some test"