$CurrentTimeZone = Get-TimeZone
if ($CurrentTimeZone.Id -ne "Eastern Standard Time") {
    Set-TimeZone "Eastern Standard Time"
}
