$ou = Read-host "Enter OU [OU=MyOU,DC=MyDomain,DC=com]"
$outputFile = Read-host "Enter Output Path [C:\MyFolder\ServerInfo.csv]"


$serverInfo = @()


Get-ADComputer -SearchBase $ou -Filter {OperatingSystem -Like "Windows Server*"} | ForEach-Object {
    $serverName = $_.Name
    Write-Host "Querying server" $serverName "..."
    
    #Get installed software list
    $software = Get-WmiObject -Class Win32_Product -ComputerName $serverName | Select-Object Name, Version
    
    #Get operating system version
    $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $serverName | Select-Object Caption, Version
    
    #Get date of last Windows patch installation
    $lastPatch = Get-HotFix -ComputerName $serverName | Where-Object {$_.InstalledOn -lt (Get-Date)} | Sort-Object InstalledOn -Descending | Select-Object -First 1
    
    #Add server info to array
    $serverInfo += [PSCustomObject]@{
        ServerName = $serverName
        Software = $software.Name -join ","
        Version = $software.Version -join ","
        OperatingSystem = $os.Caption
        OSVersion = $os.Version
        LastPatch = $lastPatch.Description
        PatchDate = $lastPatch.InstalledOn
    }
}

#Export server info to CSV file
$serverInfo | Export-Csv $outputFile -NoTypeInformation
Write-Host "Server info exported to" $outputFile