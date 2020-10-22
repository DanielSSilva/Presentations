New-UDDashboard -Title "Hello, World!" -Content {
    New-UDDynamic -Content {
        $Data = 1..10 | % { 
            [PSCustomObject]@{ Name = $_; value = get-random }
        }
        New-UDChartJS -Type 'bar' -Data $Data -DataProperty Value -Id 'test' -LabelProperty Name -BackgroundColor Blue
    } -AutoRefresh -AutoRefreshInterval 1 
}