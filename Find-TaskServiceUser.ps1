﻿Function Find-TaskServiceUser {
<#
.SYNOPSIS
Finding scheduled tasks, system services on computer by user name. 
.DESCRIPTION
Finding scheduled tasks, system services on local or remote computer by given user name. 
'Administrator' and local computer are default values.
The results can be redirected to the log file (see 'log' parameter).
.PARAMETER User
User name to find scheduled tasks or system services. Default value is 'Administrator'.
.PARAMETER Computer
Computer to find tasks/services. Default value is 'localhost' ($env:COMPUTERNAME).
.PARAMETER Task
A Switch to enable finding scheduled tasks.
.PARAMETER Service
A Switch to enable finding system services.
.PARAMETER Log
A switch to enable logging of output data to a log file. The log file with the path is defined in the "LogFile" parameter.
.PARAMETER Logfile
Path with file name where logging output. Default value is [$env:TEMP]\find-taskserviceuser.log. Works only with Log switch.
.EXAMPLE
Find-TaskServiceUser -Computer "WSRV00" -User "BobbyK" -Service -Task -Log

Description
-----------
Find system services and scheduled tasks on "WSRV00" for user "BobbyK" with logging output to file.
.EXAMPLE
"WSRV01","WSRV02" | Find-TaskServiceUser -Service -Task

Description
-----------
Find system services and scheduled tasks on computers "WSRV01", "WSRV02" for user "Administrator"
.LINK
https://github.com/voytas75/Find-TaskServiceUser
.LINK
https://www.powershellgallery.com/packages/Find-TaskServiceUser
.NOTES
version 1.1.0, 30.03.2019:
- change private functions names
- minor fixes.
version 1.0.1, 29.03.2019:
- minor bug fixes.
version 1.0, 27.03.2019:
- first build of module created from function.
#>
  [CmdletBinding()]
  Param(
    [parameter(mandatory=$false, position=0, valuefrompipeline = $true, ValueFromPipelineByPropertyName=$true, HelpMessage='Computer NetBIOS, DNS name or IP.')]
    [Alias('MachineName','Server')]
    [string[]]$Computer=$env:COMPUTERNAME,

    [parameter(Mandatory=$false, HelpMessage='User name to find services and/or tasks.')]
    [string]$User='Administrator',

    [parameter(Mandatory=$false, HelpMessage='Switch to find system services.')]
    [switch]$Service,

    [parameter(Mandatory=$false, HelpMessage='Switch to find scheduled tasks.')]
    [switch]$Task,

    [parameter(Mandatory=$false, HelpMessage='Switch to enable logging.')]
    [switch]$Log,

    [parameter(Mandatory=$false, HelpMessage='Log file path. Default is ''[$env:TEMP]\Find-TaskServiceUser.log''')]
    [string]$Logfile="$env:TEMP\Find-TaskServiceUser.log"
  )
  Begin {
    if (!$service -and !$task) {
      Write-output "You must provide 'service' or/and 'task' parameter`n"
      Write-output 'Examples:'
      Write-output '  Find-TaskServiceUser -Computer "WSRV00" -User "BobbyK" -Service -Task'
      Write-output '  Find-TaskServiceUser -Computer "WSRV01" -User "BobbyK" -Task -Log' 
      Write-output '  "WSRV00","WSRV03" | Find-TaskServiceUser -Service -Task'
      Write-output '  "WSRV04" | Find-TaskServiceUser -Service'
    } else {
      if ($user -eq "administrator") {
        Write-Output "Set default user: Administrator"
      }
      if ($computer -eq $env:COMPUTERNAME) {
        Write-output "Set default computer: $env:COMPUTERNAME (localhost)"
      }  
    }
    if ($Log) {
      Write-Log "---------$(get-date)---------"
    }
  } # end BEGIN block
  Process {
    foreach ($item in $Computer) {
      if ($service) {    
        Write-output "Finding system services with user: ""$($user.trim().toupper())"" on machine: ""$($item.trim().toupper())"""
        if ($Log) {
          Write-Log "$(get-date): Finding services with user: ""$($user.trim().toupper())"" on machine: ""$($item.trim().toupper())"""
        }
        $services = Find-ServiceUser -computer $item.Trim() -user $user
          if ($services) {
            Write-Verbose "services found"
            if ($Log) {
              Write-Log "$(get-date): Services:"
            }
            $output1 = $services | select-object SystemName,Name,DisplayName,StartName,State
            $output = $output1 | Format-Table -AutoSize
            $output
            if ($Log) {
              $output1 | ForEach-Object { Write-Log $_ }
            }
          } else {
            if ($Log) {
              Write-Log "$(get-date): No services found on computer ""$item"" for user ""$user"""
            }
            Write-output "No services found on computer ""$item"" for user ""$user"""
          }
        }
        if ($task) {
          Write-output "Finding tasks with user: ""$($user.trim().toupper())"" on machine: ""$($item.trim().toupper())"""
          if ($Log) {
            Write-Log "$(get-date): Finding tasks with user: ""$($user.trim().toupper())"" on machine: ""$($item.trim().toupper())"""
          }
          $tasks = Find-TaskUser -server $item.trim() -user $user
          if ($tasks) {
            if ($Log) {
              Write-Log "$(get-date): Tasks:"
            }
            Write-Verbose -Message 'display tasks'
            Write-output "Found scheduled tasks where ""$user"" matched task author or 'run as user'"
            $tasksdata = $tasks | ConvertFrom-Csv | Select-Object Hostname, Taskname, Author, "Run as user"
            $tasksdata
            if ($Log) {
              $tasksdata | ForEach-Object { Write-Log $_ }
            }
          } else {
            if ($Log) {
              Write-Log "$(get-date): No tasks on computer ""$item"" for user ""$user"""
          }
          Write-output "No tasks foundon computer ""$item"" for user ""$user"""
        }
      }
    }
  } # end PROCESS block
  End {
    if ($Log) { 
      Write-output "`nLog File: $($Logfile)"
    }
  } # end END block
} # end Find-TaskServiceUser function
