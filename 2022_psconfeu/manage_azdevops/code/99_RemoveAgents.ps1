$poolName = 'DanielPool'
$poolId = Get-VSTeamPool | Where-Object { $_.Name -eq $poolName } | Select-Object -ExpandProperty Id
$allAgents = Get-VSTeamAgent -PoolId $poolId

$agentInfo = $allAgents[0]

$macOSAgents = $allAgents | Where-Object { $_.OS.StartsWith("Darwin") }

$macOSOfflineAgents = $macOSAgents | Where-Object { $_.Status -eq "offline"}

$agentsToDeleteIds = $macOSOfflineAgents | Select-Object -ExpandProperty AgentId

Remove-VSTeamAgent -PoolId $poolId -Id $agentsToDeleteIds




