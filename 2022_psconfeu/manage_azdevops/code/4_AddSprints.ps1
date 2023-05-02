$countriesResponse = Invoke-RestMethod -Method GET -Uri "restcountries.com/v3.1/all"
$countriesNames = $countriesResponse | Select-Object -ExpandProperty name | Select-Object -ExpandProperty common
$sprintIteration = 1..5

$initialDate = Get-Date
$endDate = $initialDate.AddDays(13)
$sprints = @()

for($i = 0 ; $i -lt $sprintIteration.Count ; ++$i)
{
    $sprints += @{
        "Name" = "Sprint $($sprintIteration[$i]) - $($countriesNames[$i])"
        "StartDate" = $initialDate.AddDays($i*14).ToString("MM-dd-yyyy")
        "FinishDate" = $endDate.AddDays($i*14).ToString("MM-dd-yyyy")
    }
}

$sprints | ForEach-Object { 
    Add-VSTeamIteration -ProjectName "PSConfEU22" -StartDate $_.StartDate -FinishDate $_.FinishDate -Name $_.Name
}


#Add-VSTeamIteration -StartDate "2021/03/01" -FinishDate "2021/03/05" -Name "TestModule"

