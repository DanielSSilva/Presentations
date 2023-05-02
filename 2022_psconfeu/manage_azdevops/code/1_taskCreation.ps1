#create 30 tasks
1..30 | Foreach-object -Parallel {
    Add-VSTeamWorkItem -ProjectName "PSConfEU22" -Title "[Task-UX-$_]Change field $_" -WorkItemType "Task"
}

#Create some tasks with diacritic characters 
$diacritics = @("café", "façade", "élite", "entrepôt", "Doña", "Gewürztraminer", "flambé")
$diacritics | Foreach-object -Parallel {
    Add-VSTeamWorkItem -ProjectName "PSConfEU22" -Title "[Issue-UX-$]Just some task with a diacritic word - $_" -WorkItemType "Issue"
}

#Task removal

1115..1150 | Foreach-object -Parallel {
    Remove-VSTeamWorkItem -id $_ -Force
}