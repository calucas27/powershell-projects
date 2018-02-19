<#
    .SYNOPSIS
    SCRIPT 01: Event Log Manipulation: By Chase Lucas

    .EXAMPLE
    .\01_EventLog.ps1
    
    
    .DESCRIPTION
    Prints the list of available event logs, creates a new event log named CSC443 with a maximum size of 64 KB,
    1 day of retention, and an overflow action of OverwriteOlder.  100 logs will be written before the event
    log list is printed again.  The existing logs will be exported to a .csv file before the event log is cleared.
#>

Get-EventLog -List
New-EventLog -Source Script -logname "CSC443"
Limit-EventLog -LogName "CSC443" -MaximumSize 64 -RetentionDays 1 -OverflowAction OverwriteOlder

for($i=0; $i -lt 100; $i++){
    Write-EventLog -LogName "CSC443" -Source "CSC443" -EventId 1001 -EntryType Information -Message "Log from Script!"
}
Get-EventLog -List
Get-EventLog "CSC443" | Export-Csv eventlog.csv
Clear-EventLog "CSC443"


