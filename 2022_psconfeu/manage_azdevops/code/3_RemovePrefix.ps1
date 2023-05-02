$workItemsIds = Get-TeamWorkItemsIds -WorkItemType 'Issue' | Select-Object -ExpandProperty Id

$items = Get-VSTeamWorkItem -Id $workItemsIds | Select-Object id, title

$items | ForEach-Object -Parallel { 
    #From the interwebs
    function Convert-DiacriticCharacters {
    param(
        [string]$inputString
    )
        [string]$formD = $inputString.Normalize(
                [System.text.NormalizationForm]::FormD
        )
        $stringBuilder = new-object System.Text.StringBuilder
        for ($i = 0; $i -lt $formD.Length; $i++){
            $unicodeCategory = [System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($formD[$i])
            $nonSPacingMark = [System.Globalization.UnicodeCategory]::NonSpacingMark
            if($unicodeCategory -ne $nonSPacingMark){
                $stringBuilder.Append($formD[$i]) | out-null
            }
        }
        $stringBuilder.ToString().Normalize([System.text.NormalizationForm]::FormC)
    }
    Update-VSTeamWorkItem -Id $_.Id -Title ((Convert-DiacriticCharacters $_.Title) -replace "\[.+\]")
}