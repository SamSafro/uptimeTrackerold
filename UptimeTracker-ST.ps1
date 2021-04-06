<########################################################################
Build uptime monitor scheduled task and pass script to be ran hourly.

Developed by:
   Sam Safronoff - Sam.Safronoff@fourwindsinteractive.com - July 2020

#########################################################################>

##Grab Logged in user for scheduled task creation.##
$loggedinuser = (Get-WmiObject -Class Win32_Process -Filter 'Name="explorer.exe"').GetOwner().User 
If ($null -eq $LoggedInUser) {$LoggedInUser = "fwiplayer"}


##Creating Scheduled task to run uptime monitor script every hour.##
##The interval can easily be changed in the first line of code after /mo.##
& "$env:windir\system32\schtasks.exe" /create /sc minute /mo 60 /tn Uptime-Tracking /tr powershell.exe /RU $LoggedInUser /f


##Adjust the action, and the argument, to call powershell and point to script.##
$Task = "Uptime-Tracking"
$elegant_argument = "-windowstyle hidden -Command `"& 'C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\UptimeTracker.ps1'`""
$Action = New-ScheduledTaskAction -Execute "PowerShell" -Argument $elegant_argument
Set-ScheduledTask -TaskName $Task -Action $Action


##Set working directory,build uptime monitor folder and move uptime script to FWIRMM UptimeMonitor Folder. Remove old script##
Remove-Item -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\UptimeTracker.ps1"
New-Item -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor" -ItemType "directory" -ErrorAction SilentlyContinue
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
Move-Item -Path $ScriptDir\UptimeTracker.ps1 -Destination "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\" -ErrorAction SilentlyContinue

New-Item -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\" -Name "UptimeLogging.txt" -type "file"
New-Item -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\LastOfflineEvent.txt" -Type "file"
Add-Content -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\UptimeLogging.txt" -Value "Beginning"
Add-Content -Path "C:\Users\Public\Documents\Four Winds Interactive\FWIRMM UptimeMonitor\LastOfflineEvent.txt" -Value "Beginning"

##Check and exit accordingly for logging purposes.##
$taskcheck = Get-ScheduledTask -TaskName "Uptime-Tracking" -ErrorAction SilentlyContinue
    If (!$taskcheck) { 
    echo "<-Start Result->"
    echo "Result=Failed To Create Uptime Task”
    echo "<-End Result->"
    exit 1
    }

echo "<-Start Result->"
echo "Result=Uptime Task Created”
echo "<-End Result->"
exit 0