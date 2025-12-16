$ErrorActionPreference = “silentlycontinue”

function Show-Menu
{
     param (
           [string]$Title = 'Viewpoint/Command Session Killer'
     )
     cls
     Write-Host "================ $Title ================"
    
     Write-Host "1: Press '1' To kill a Viewpoint RAP Session."
     Write-Host "2: Press '2' To kill a Command RAP Session."
     #Write-Host "3: Press '3' for this option."
     Write-Host "Q: Press 'Q' to quit."
}

function sleepanim {
<#
.SYNOPSIS
Animated sleep
.DESCRIPTION
Takes the title and displays a looping animation for a given number of seconds.
The animation will delete itself once it's finished, to save on console scrolling.
.PARAMETER seconds
A number of seconds to sleep for
.PARAMETER title
Some words to put next to the thing
.EXAMPLE
sleepanim
Will display a small animation for 1 second
 
sleepanim 5
Will display a small animation for 5 seconds
 
sleepanim 10 "Waiting for domain sync"
Will display "Waiting for domain sync " and a small animation for 10 seconds
 
.INPUTS
seconds, title
.OUTPUTS
A little animation
.LINK
 
#>
[CmdletBinding()]
param
(
        [Parameter(Position=1)][int]$seconds=1,
        [Parameter(Position=2)][string]$title="Please wait while the user session is being terminated..."
)
        $blank = "`b" * ($title.length+11)
        $clear = " " * ($title.length+11)
        $anim=@("0o.......o","o0o.......",".o0o......","..o0o.....","...o0o....","....o0o...",".....o0o..","......o0o.",".......o0o","o.......o0") # Animation sequence characters
        while ($seconds -gt 0) {
                $anim | % {
                        Write-Host "$blank$title $_" -NoNewline -ForegroundColor Yellow
                        Start-Sleep -m 100
                }
                $seconds --
          }
        Write-Host "$blank$clear$blank" -NoNewline
}



do
{
     Show-Menu
     $input = Read-Host "Please make a selection"
     switch ($input)
     {
           
           
           '1' {
                cls

Write-Host "Gathering list of RAP servers to query.  Please wait..."

$activeserver = (get-rdconnectionbrokerhighavailability -connectionbroker sm999rdb02.uc.local).activemanagementserver

DO
{

$viewpointuser = Read-Host "What is the username?"
$aduser = (get-aduser -identity "$viewpointuser").samaccountname

if ($viewpointuser -eq $aduser){Write-Host "The username is in Active Directory"
}

else{Write-Host "Username was not found in Active Directory"
sleep -seconds 2
}

}
Until($viewpointuser -eq $aduser)




Write-Host "Searching for user session..."

$usersession = get-rdusersession "viewpoint remote apps" -connectionbroker "$activeserver" | where username -like "$viewpointuser"

$hostserver = $usersession.hostserver

$sessionid = $usersession.sessionid

if ($hostserver -eq $null){Write-Host "$viewpointuser is not logged into any RAP servers"
break}

else{Write-Host "$viewpointuser is logged into "$hostserver".  Logging them off of the RAP server now please wait..."

invoke-rduserlogoff -hostserver "$hostserver" -unifiedsessionid $sessionid -force

}

cls

#The sleepanim function gives time for the user to get logged out
sleepanim -seconds 30

Write-Host "Verifying the user session has been terminated on the rap server...."


$usersession = get-rdusersession "viewpoint remote apps" -connectionbroker "$activeserver" | where username -like "$viewpointuser"

$hostserver = $usersession.hostserver


if ($hostserver -eq $null){Write-Host "$viewpointuser has been successfully logged out of the RAP server"
break}

else {Write-Host "$viewpointuser was not successfully logged out of $hostserver Please try again or contact engineering"
sleep -seconds 5
break}
           } 
           
           
           
           '2' {
                cls

Write-Host "Gathering list of RAP servers to query.  Please wait..."

$activeserver = (get-rdconnectionbrokerhighavailability -connectionbroker sm999rdb02.uc.local).activemanagementserver

DO
{

$commanduser = Read-Host "What is the username?"
$aduser = (get-aduser -identity "$commanduser").samaccountname

if ($commanduser -eq $aduser){Write-Host "The username is in Active Directory"
}

else{Write-Host "Username was not found in Active Directory"
sleep -seconds 2
}

}
Until($commanduser -eq $aduser)




Write-Host "Searching for user session..."

$usersession = get-rdusersession "command cluster" -connectionbroker "$activeserver" | where username -like "$commanduser"

$hostserver = $usersession.hostserver

$sessionid = $usersession.sessionid

if ($hostserver -eq $null){Write-Host "$commanduser is not logged into any RAP servers"
break}

else{Write-Host "$commanduser is logged into "$hostserver".  Logging them off of the RAP server now please wait..."

invoke-rduserlogoff -hostserver "$hostserver" -unifiedsessionid $sessionid -force

}

cls

#The sleepanim function gives time for the user to get logged out
sleepanim -seconds 30

Write-Host "Verifying the user session has been terminated on the rap server...."


$usersession = get-rdusersession "command cluster" -connectionbroker "$activeserver" | where username -like "$commanduser"

$hostserver = $usersession.hostserver


if ($hostserver -eq $null){Write-Host "$commanduser has been successfully logged out of the RAP server"
break}

else {Write-Host "$commanduser was not successfully logged out of $hostserver Please try again or contact engineering"
sleep -seconds 5
break}
           } '3' {
                cls
                'You chose option #3'
           } 'q' {
                exit
           }
     }
     pause
}
until ($input -eq 'q')