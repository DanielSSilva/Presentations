
param ($projectName, $pullRequestId, $token, $newState, $tagsToAdd)

Set-VSTeamAccount -Account "https://dev.azure.com/danielssilvadev" -Token $token
Set-VSTeamDefaultProject -Project $projectName
$pr = Get-VSTeamPullRequest -ProjectName $projectName -Id $pullRequestId 

if($null -eq $pr)
{
    Write-Error "Could not get the Pull Request info"
    exit
}

$workitemUrl = "$($pr.url)/workitems`?api-version=6.0"
$auth = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($token)"))
$workItems = (Invoke-RestMethod -Uri $workitemUrl -Headers @{Authorization = "Basic $auth"} -Method Get).value

#If there are no workitems to change, just move on
if($workItems.Count -eq 0)
{
    return
}
#foreach work item on the PR, get info about it, add the requested tag and set it to the new state
$workItems.id | ForEach-Object {
    $wi = Get-VSTeamWorkItem -Id $_
    # Only do something if the WI is a task or a Bug
    #AND if it is in doing, 
    #otherwise don't move nor add tags
    if( ($wi.WorkItemType -eq "Task" -or $wi.WorkItemType -eq "Bug") -and $wi.State -eq "Doing")
    {
        $tags = $wi.fields."System.Tags"
        $tags += ";$tagsToAdd"
        $tags = [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($tags))
        $additionalFields = @{"System.Tags"= $tags; "System.State"=$newState}
        Update-VSTeamWorkItem -Id $wi.id -AdditionalFields $additionalFields
    }    
}
