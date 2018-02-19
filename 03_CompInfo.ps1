<#
    .SYNOPSIS
    SCRIPT 03: Computer Status Details: By Chase Lucas

    .EXAMPLE
    .\03_CompInfo.ps1
    
    .DESCRIPTION
    Gathers information about the computer, and stores the results in a custom object.
#>
$database = @()
$computerinfo = New-Object System.Object

$comp_name = $env:computername
$comp_hostname = hostname
$comp_process = Get-Process | Measure | Select-Object -ExpandProperty Count
$comp_service = Get-Service | Measure | Select-Object -ExpandProperty Count
$comp_servicestopped = Get-Service | Where-Object {$_.Status -eq "Stopped"} | Measure | Select-Object -ExpandProperty Count
$comp_date = date
$comp_os = Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty Version
$comp_cpu = Get-CimInstance CIM_PROCESSOR | Select-Object -ExpandProperty Name


$computerinfo | Add-Member -Type NoteProperty -Name comp_name -Value $comp_name
$computerinfo | Add-Member -Type NoteProperty -Name comp_hostname -Value $comp_hostname
$computerinfo | Add-Member -Type NoteProperty -Name comp_process -Value $comp_process
$computerinfo | Add-Member -Type NoteProperty -Name comp_service -Value $comp_service
$computerinfo | Add-Member -Type NoteProperty -Name comp_servicestopped -Value $comp_servicestopped
$computerinfo | Add-Member -Type NoteProperty -Name comp_date -Value $comp_date
$computerinfo | Add-Member -Type NoteProperty -Name comp_os -Value $comp_os
$computerinfo | Add-Member -Type NoteProperty -Name comp_cpu -Value $comp_cpu

$database += $computerinfo

Write-Host ($computerinfo | Format-List | Out-String)