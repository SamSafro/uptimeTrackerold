<##########################################################################
This script will log whether or not the machine has an internet connection.

Developed by:
   Sam Safronoff - Sam.Safronoff@fourwindsinteractive.com - July 2020

###########################################################################>


##Check for online log file to exist and folder, may have been accidentally deleted or a clean content player install may have taken place.##
$loglocation = "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\UptimeLogging.txt"
$logfile = Test-Path $loglocation
If ($logfile -eq $false) {
    New-Item -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor" -ItemType "directory" -ErrorAction SilentlyContinue
    New-Item -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\" -Name "UptimeLogging.txt" -type "file"
    New-Item -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\LastOfflineEvent.txt" -Type "file"
    Add-Content -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\UptimeLogging.txt" -Value "Beginning"
    Add-Content -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\LastOfflineEvent.txt" -Value "Beginning"
    }


##Check to ensure that the uptime log file has not balloned and taken up too much space.##
$filesizecheck = (get-item $loglocation).Length/1024
$lastofflinesizecheck = "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\LastOfflineEvent.txt"
$thedate = Get-Date

If ($filesizecheck -gt 2000) {
    Remove-Item -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\UptimeLogging.txt" -ErrorAction SilentlyContinue
    New-Item -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\" -Name "UptimeLogging.txt" -type "file"
    Add-Content -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\UptimeLogging.txt" -Value "Beginning"
    Add-Content -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\UptimeLogging.txt" -Value "UptimeLogging Cleared on $thedate"
    }

##Check to ensure that the LastOffline log file has not balloned and taken up too much space.##
$filesizecheck = (get-item $lastofflinesizecheck).Length/1024

If ($filesizecheck -gt 2000) {
    Remove-Item -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\LastOfflineEvent.txt"
    New-Item -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\" -Name "LastOfflineEvent.txt" -type "file"
    Add-Content -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\UptimeLogging.txt" -Value "Beginning"
    Add-Content -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\LastOfflineEvent.txt" -Value "LastOffline Cleared on $thedate"
    }


##Time stamp information for logging.##
$uptime = Get-WmiObject win32_operatingsystem | select csname, @{LABEL=’LastBootUpTime’
;EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}

$lastbootup = $uptime.LastBootUpTime
$datetime = Get-Date -Format "dddd MM/dd/yyyy HH:mm"

##Test-Connection to check internet connection.##
$onlinecheck = ping 8.8.8.8

##Connection check and logging appropriately.##
If ($onlinecheck -match "Packets: Sent = 4, Received = 4, Lost = 0") {

    ##Get the difference between offline event and current log for total uptime since offline event.##  
    ##Last Offline Event Information##
    $last_offline_event = "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\LastOfflineEvent.txt"
    $last_offline_event = (Get-Item $last_offline_event).LastWriteTime

    ##Last Online Event Information##
    $last_online_event = "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\UptimeLogging.txt"
    $last_online_event = (Get-Item $last_online_event).LastWriteTime

    ##Get the difference of the two for total uptime.##
    $timespan = New-TimeSpan -Start $last_offline_event -End $last_online_event
    $TotalUptime = @()
    $days = $timespan.Days
    $hours = $timespan.Hours
    $minutes = $timespan.Minutes
    $TotalUptime += "Total Uptime Since Offline Event or beginning of uptime monitoring:","Days: $days, Hours: $hours"

    ##Add the information to the log.##
    Add-Content -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\UptimeLogging.txt" -Value "Pc Powered-On and Online: $datetime"
    Add-Content -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\UptimeLogging.txt" -Value "Last Reboot $lastbootup"
    Add-Content -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\UptimeLogging.txt" -Value $TotalUptime
    Add-Content -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\UptimeLogging.txt" -Value ""
    
    ##Pass to UDF 23.##
    $TotalUptimeUDF = @()
    $TotalUptimeUDF += "Total Uptime: Days: $days, Hours: $hours"
    REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\CentraStage /v Custom23 /t REG_SZ /d $TotalUptimeUDF /f


    ##Second check for offline.##
    } ElseIf ($onlinecheck -match "Packets: Sent = 4, Received = 0, Lost = 4") { 

    ##Last Offline Event Information##
    $last_offline_event = "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\LastOfflineEvent.txt"
    $last_offline_event = (Get-Item $last_offline_event).LastWriteTime

    ##Last Online Event Information##
    $last_online_event = "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\Logging.txt"
    $last_online_event = (Get-Item $last_online_event).LastWriteTime

    ##Get the difference of the two for total Off-Time.##
    $timespan = New-TimeSpan -Start $last_online_event -End $last_offline_event
    $Totalofftime = @()
    $days = $timespan.Days
    $hours = $timespan.Hours
    $minutes = $timespan.Minutes
    $Totalofftime += "Time since last online event:","Days: $days, Hours: $hours"

    ##Add the information to the log.##
    Add-Content -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\LastOfflineEvent.txt" -Value "Pc Powered-On but Offline: $datetime"
    Add-Content -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\LastOfflineEvent.txt" -Value "Last Reboot $lastbootup"
    Add-Content -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\LastOfflineEvent.txt" -Value $Totalofftime
    Add-Content -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\LastOfflineEvent.txt" -Value ""
    }