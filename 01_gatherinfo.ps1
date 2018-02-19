<#
    .SYNOPSIS
    SCRIPT 01: Gathering Info: By Chase Lucas

    .EXAMPLE
    .\01_gatherinfo.ps1 -ComputerName dc1 -RunningProcesses -Services -LocalUsers
    
    .DESCRIPTION
    Allows the user to gather various different pieces of information about a local or remote system within an Active Directory Network.
    When the script is run, the output for the various different parameters will each be exported to their own .csv file.
    Any number of parameters can be mixed and matched to adjust the information you wish to gather. 
    NOTE: If the -ComputerName parameter is not used, the script will default to scanning the local system.
#>
param(
    [Parameter(mandatory=$false)][String[]]$ComputerName,
    [Parameter(mandatory=$false)][switch]$RunningProcesses,
    [Parameter(mandatory=$false)][switch]$ComputerInfo,
    [Parameter(mandatory=$false)][switch]$Services,
    [Parameter(mandatory=$false)][switch]$Updates,
    [Parameter(mandatory=$false)][switch]$LocalUsers,
    [Parameter(mandatory=$false)][switch]$DomainUsers
)
$database = @()
$database_r = @()
if($ComputerName -eq $null){
    echo "No computer name supplied, falling back to local."
    $ComputerName = $env:COMPUTERNAME
    $LocalOnly = $true
}
elseIf($ComputerName -ne $null){
    $LocalOnly = $false
}
$cred = Get-Credential
if($RunningProcesses.IsPresent -eq $True){
    if($LocalOnly -eq $true){
        Get-Process | Export-Csv "$ComputerName-Processes.csv"
    }
    ElseIf($LocalOnly -eq $False){
        foreach($hostName in $ComputerName){
            Invoke-Command -Credential $cred -ComputerName $ComputerName -ScriptBlock{
                Get-Process
            } | Export-Csv "$ComputerName-Processes.csv"
        }
    }
}
$compinfo = New-Object System.Object
if($ComputerInfo.IsPresent -eq $True){
    if($LocalOnly -eq $true){
        $domain = Get-AdDomain | Select-Object -ExpandProperty Name
        $compname = $env:COMPUTERNAME
        $model = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty Model
        $cpu_manufacturer = Get-CimInstance CIM_PROCESSOR | Select-Object -ExpandProperty Manufacturer
        $phys_mem = Get-WmiObject -class Win32_PhysicalMemory | Select-Object -ExpandProperty Capacity
        $cpu_max_clock = Get-CimInstance CIM_PROCESSOR | Select-Object -ExpandProperty MaxClockSpeed
        $cpu_model = Get-CimInstance CIM_PROCESSOR | Select-Object -ExpandProperty Name

        $compinfo | Add-Member -Type NoteProperty -Name Domain -Value $domain
        $compinfo | Add-Member -Type NoteProperty -Name CompName -Value $compname
        $compinfo | Add-Member -Type NoteProperty -Name CompModel -Value $model
        $compinfo | Add-Member -Type NoteProperty -Name ProcManufacturer -Value $cpu_manufacturer
        $compinfo | Add-Member -Type NoteProperty -Name PhysicalMemory -Value $phys_mem
        $compinfo | Add-Member -Type NoteProperty -Name ProcMaxClock -Value $cpu_max_clock
        $compinfo | Add-Member -Type NoteProperty -Name ProcModel -Value $cpu_model

        $database += $compinfo
        echo $database | Export-Csv "$ComputerName-Info.csv"
    }
    ElseIf($LocalOnly -eq $false){
        echo "in elseif" 
        foreach($hostName in $ComputerName){
            Invoke-Command -Credential $cred -ComputerName $ComputerName -ScriptBlock{
                $domain = Get-AdDomain | Select-Object -ExpandProperty Name
                $compname = $env:COMPUTERNAME
                $model = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty Model
                $cpu_manufacturer = Get-CimInstance CIM_PROCESSOR | Select-Object -ExpandProperty Manufacturer
                $phys_mem = Get-WmiObject -class Win32_PhysicalMemory | Select-Object -ExpandProperty Capacity
                $cpu_max_clock = Get-CimInstance CIM_PROCESSOR | Select-Object -ExpandProperty MaxClockSpeed
                $cpu_model = Get-CimInstance CIM_PROCESSOR | Select-Object -ExpandProperty Name

                $database = @()
                $compinfo = New-Object System.Object

                $compinfo | Add-Member -Type NoteProperty -Name Domain -Value $domain
                $compinfo | Add-Member -Type NoteProperty -Name CompName -Value $compname
                $compinfo | Add-Member -Type NoteProperty -Name CompModel -Value $model
                $compinfo | Add-Member -Type NoteProperty -Name ProcManufacturer -Value $cpu_manufacturer
                $compinfo | Add-Member -Type NoteProperty -Name PhysicalMemory -Value $phys_mem
                $compinfo | Add-Member -Type NoteProperty -Name ProcMacClock -Value $cpu_max_clock
                $compinfo | Add-Member -Type NoteProperty -Name ProcModel -Value $cpu_model

                $database += $compinfo
                echo $database
            } | Write-Output | Export-Csv "$ComputerName-Info.csv"
       

        }
    }
    
}
if($Services.IsPresent -eq $True){
    if($LocalOnly -eq $true){
        Get-Service | Export-Csv "$ComputerName-Services.csv"
    }
    ElseIf($LocalOnly -eq $false){
        foreach($hostName in $ComputerName){
            Invoke-Command -Credential $cred -ComputerName $ComputerName -ScriptBlock{
                Get-Service   
            } | Export-Csv "$ComputerName-Services.csv"
        }
    }
}
if($Updates.IsPresent -eq $True){
    if($LocalOnly -eq $true){
        Get-HotFix | Sort-Object InstalledOn | Export-Csv "$ComputerName-Updates.csv"
    }
    elseIf($LocalOnly -eq $False){
        foreach($hostName in $ComputerName){
            Invoke-Command -Credential $cred -ComputerName $ComputerName -ScriptBlock{
                Get-HotFix | Sort-Object InstalledOn
            } | Export-Csv "$ComputerName-Updates.csv"
        }
    }
}
if($LocalUsers.IsPresent -eq $true){
    if($LocalOnly -eq $true){
        Get-LocalUser | Export-Csv "$ComputerName-LocalUsers.csv"
    }
    elseIf($LocalOnly -eq $False){
        foreach($hostName in $ComputerName){
            Invoke-Command -Credential $cred -ComputerName $ComputerName -ScriptBlock{
                Get-LocalUser
            } | Export-Csv "$ComputerName-LocalUsers.csv"
        }
    }
}
if($DomainUsers.IsPresent -eq $True){
    if($LocalOnly -eq $True){
        Get-ADUser -Filter * | Select-Object Name | Export-Csv "$ComputerName-DomainUsers.csv"
    }
    elseIf($LocalOnly -eq $False){
        Invoke-Command -Credential $cred -ComputerName $ComputerName -ScriptBlock{
            Get-AdUser -Filter * | Select-Object Name
        } | Export-Csv "$ComputerName-DomainUsers.csv"
    }
}