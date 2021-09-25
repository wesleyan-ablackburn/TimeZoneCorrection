Execute-Process -Path "ntrights.exe" -Parameters "-u Users -r SeTimeZonePrivilege"
Execute-Process -Path "ntrights.exe" -Parameters "-u Users -r SeSystemtimePrivilege"

Write-Log -Message "Creating script folder..." -LogType CMTrace
If (Test-Path -Path "C:\ProgramData\TimeZone") {
} else {
  New-Item -ItemType directory -Path "C:\ProgramData\TimeZone\" > $null
}

Copy-Item -Path "$dirFiles\Correct-TimeZone.ps1" -Destination "C:\ProgramData\TimeZone\" -Force

Write-Log -Message "Creating scheduled task..." -LogType CMTrace
$Triggers = @()
$TaskName = "Time Zone Correction"
$TaskDescription = "This task ensures the device is set to ""Eastern Standard Time"" at boot up, login, and any time the time zone is changed."
$Arguments = "-WindowStyle Hidden -NonInteractive -ExecutionPolicy Bypass -File ""C:\ProgramData\TimeZone\Correct-TimeZone.ps1"""
$Action = New-ScheduledTaskAction -Execute "C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe" -Argument $Arguments
$Principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$EventTriggerClass = Get-CimClass MSFT_TaskEventTrigger root/Microsoft/Windows/TaskScheduler
$EventTrigger = $EventTriggerClass | New-CimInstance -ClientOnly
$EventTrigger.Enabled = $true
$EventTrigger.Subscription = "<QueryList><Query Id=""0"" Path=""System""><Select Path=""System"">*[System[Provider[@Name='Microsoft-Windows-Kernel-General'] and EventID=22]]</Select></Query></QueryList>"
$Triggers +=  New-ScheduledTaskTrigger -AtLogOn
$Triggers +=  New-ScheduledTaskTrigger -AtStartup
$Triggers += $EventTrigger
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -StartWhenAvailable
Register-ScheduledTask -Action $Action -Principal $Principal -Trigger $Triggers -Settings $Settings -TaskName $TaskName -Description $TaskDescription -Force
