function Get-TeamWorkItemsIds {
    param (
        [string]$organization = "danielssilvadev",
        [string]$project = "PSConfEU22",
        [string]$team = "PSConfEU22 Team",
        [string]$WorkItemType 
    )

    $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($env:PAT)"))

    $headers = @{
        "Authorization" = "Basic $token"
        "Content-Type"  = "application/json"
    }

    $queryBody = @{
        "query" = "Select [System.Id], [System.Title], [System.State] From WorkItems Where [System.WorkItemType] = '$WorkItemType'"
    } | ConvertTo-Json

    (Invoke-RestMethod -Method Post -Headers $headers -Body $queryBody "https://dev.azure.com/${organization}/${project}/${team}/_apis/wit/wiql?api-version=6.0").workItems | Select-Object id
}