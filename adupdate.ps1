
$VerbosePreference = "Continue"
$Date = get-date -uformat "%Y-%m-%d"
Start-Transcript -path C:\admin\scripts\adupdate\transcripts\"$Date".txt

#email formatting
$outputreport = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
tr:hover {background-color: #7fff00;}
</style>
"@

$PSEmailServer = "smtp.uc.local"
$SMTPPort = 25
$MailTo = "Brandon.Mathews@summit-materials.com","Stephen.Nageli@summit-materials.com","Stacey.Steinberg@summit-materials.com","Amy.Trudell@summit-materials.com"
$MailFrom = "adupdate@summit-materials.com"
$SubjectFailure = "Failed AD updates to Users $Date"
$SubjectSuccess = "AD Updates Success"
$Date = get-date -uformat "%Y-%m-%d"

#Create successes CSV    
$table=@"
EmployeeID,FirstName,LastName,Company,Office,Title,StreetAddress,POBox,City,State,PostalCode,Manager
"@
$table | Set-Content C:\admin\scripts\adupdate\successes.csv

#File Transfer from FTP Server:
#mv -path "\\sm888ftp01\d$\FTP\mayres\adupdate\en_to_ad_update.csv" -Destination "C:\admin\scripts\adupdate"

# Modify account parameters
$enablelist = Import-Csv -Path "c:\admin\scripts\adupdate\en_to_ad_update.csv"
foreach($user in $enablelist){

    # Find user
    $ADUser = (Get-ADUser -Filter "employeeid -eq '$($user."Employee ID")'").samaccountname
    $Company = $user.Company
    $Office = $user.Office
    $JobTitle = $user."Job Title"
    $Address1 = $user.Address1
    $Address2 = $user.Address2
    $City = $user.City
    $State = $user.State
    $Zip = $user.Zip
    $MobilePhone = $user."MobilePhone"
    $Manager = (Get-ADUser -Filter "employeeid -eq '$($user.Manager)'").distinguishedName
    $ManagerDisplayName = $user.ManagerDisplayName   

    

    if ($ADUser){
       
        set-aduser $ADUser -Company $Company
        set-aduser $ADUser -Office $Office
        set-aduser $ADUser -Title $JobTitle
        set-aduser $ADUser -StreetAddress $Address1
        set-aduser $ADUser -POBox $Address2
        set-aduser $ADUser -City $City
        set-aduser $ADUser -State $State
        set-aduser $ADUser -PostalCode $Zip
        set-aduser $ADUser -MobilePhone $MobilePhone
        set-aduser $ADUser -Manager $Manager
        


        #Write the new variables that will go to the successes spreadsheet.  EmployeeID, First Name and Last Name come from the CSV file and are not changed.
        $employeeid = (Get-Aduser $ADUser -properties employeeid).employeeid
        $firstname = $user."First Name"
        $lastname = $user."Last Name"
        $companynew = (Get-Aduser $ADUser -properties company).Company
        #$companynew = $companynew.ToString()
        $officenew = (Get-Aduser $ADUser -properties office).Office
        $jobtitlenew = (Get-Aduser $ADUser -properties title).Title
        $address1new = (Get-Aduser $ADUser -properties StreetAddress).StreetAddress
        $address2new = (Get-Aduser $ADUser -properties POBox).POBox
        $citynew = (Get-Aduser $ADUser -properties City).City
        $statenew = (Get-Aduser $ADUser -properties State).State
        $postalcodenew = (Get-Aduser $ADUser -properties PostalCode).PostalCode
        $managernew = (Get-Aduser $ADUser -properties manager).Manager
        $mobilephonenew = (Get-Aduser $ADUser -properties mobilephone).MobilePhone
        #$managernew = $managernew.ToSTring()

        #Add-Content C:\admin\scripts\adupdate\successes.csv "$employeeid,$firstname,$lastname,$companynew,$officenew,$jobtitlenew,$address1new,$address2new,$citynew,$statenew,$postalcodenew,$mobilephonenew,$managernew"

        $attributes = @(
            [pscustomobject]@{
        
                EmployeeID = $employeeid
                FirstName = $firstname
                LastName = $lastname
                Company = $companynew
                Office = $officenew
                Title = $jobtitlenew
                StreetAddress = $address1new
                POBox = $address2new
                City = $citynew
                State = $statenew
                PostalCode = $postalcodenew
                MobilePhone = $mobilephonenew
                Manager = $managernew
                
            }
        )
        
        $attributes | Export-CSV C:\admin\scripts\adupdate\successes.csv -append -NoTypeInformation


    }
    
    else{
        #Write-Warning ("Failed to update " + "$($user."First Name") " + "$($user."Last Name")" + "$($user."Employee ID")") 3>> c:\admin\scripts\adupdate\adupdatewarnings.txt
    $warnings = "C:\admin\scripts\adupdate\warnings.csv"
    $fileexists = test-path $warnings
    if ($fileexists -eq $True){


        $Name = "$($user."First Name") " + "$($user."Last Name")"
        $ONPremUser = (get-aduser -filter * -properties employeeid | where name -eq "$Name") | select -expand samaccountname
        $OnPremEID  = (Get-Aduser $ONPremUser -properties employeeid).employeeid
    
        #Add-Content C:\admin\scripts\adupdate\adupdatewarnings.csv $($user."First Name"),$($user."Last Name"),$($user."Employee ID"),$OnPremEID,$ONPremUser
        $attributes = @(
            [pscustomobject]@{
        
                FirstName = $($user."First Name")
                LastName = $($user."Last Name")
                ENEmployeeID = $($user."Employee ID")
                ADEmployeeID = $OnPremEID
                ADUsername = $ONPremUser
                }
        )
        $attributes | Export-CSV "C:\admin\scripts\adupdate\warnings.csv" -append -notypeinformation
    }
    else {

        #Create Warnings CSV
        $table=@"
        FirstName,LastName,ENEmployeeID,ADEmployeeID,ADUsername
"@    
        $table | Set-Content "C:\admin\scripts\adupdate\warnings.csv"

        $Name = "$($user."First Name") " + "$($user."Last Name")"
        $ONPremUser = (get-aduser -filter * -properties employeeid | where name -eq "$Name") | select -expand samaccountname
        $OnPremEID  = (Get-Aduser $ONPremUser -properties employeeid).employeeid
    
        #Add-Content C:\admin\scripts\adupdate\adupdatewarnings.csv $($user."First Name"),$($user."Last Name"),$($user."Employee ID"),$OnPremEID,$ONPremUser,$($user."Company"),$($user."Job Title")
        $attributes = @(
            [pscustomobject]@{
        
                FirstName = $($user."First Name")
                LastName = $($user."Last Name")
                ENEmployeeID = $($user."Employee ID")
                ADEmployeeID = $OnPremEID
                ADUsername = $ONPremUser
		Company = $($user."Company")
		JobTitle = $($user."Job Title")
                }
        )
        $attributes | Export-CSV "C:\admin\scripts\adupdate\warnings.csv" -append -notypeinformation
    }
    }

}

#Move 2 files to the old folder:  The imported CSV file and the warnings file. Then the folders are clean for the next day.
mv "c:\admin\scripts\adupdate\en_to_ad_update.csv" "c:\admin\scripts\adupdate\adupdateold\$Date.csv"
mv "c:\admin\scripts\adupdate\warnings.csv" "c:\admin\scripts\adupdate\warningsold\Warnings-$Date.csv"
mv "c:\admin\scripts\adupdate\successes.csv" "c:\admin\scripts\adupdate\successes\Successes-$Date.csv"

Stop-Transcript

#Email warnings
$warnings = "c:\admin\scripts\adupdate\warningsold\Warnings-$Date.csv"
if (Test-Path $warnings -PathType leaf){
Send-MailMessage -From $MailFrom -To $MailTo -Subject $SubjectFailure -Port $SMTPPort -Attachments "C:\admin\scripts\adupdate\warningsold\Warnings-$Date.csv", "c:\admin\scripts\adupdate\successes\Successes-$Date.csv"
}
else {Send-MailMessage -From $MailFrom -To $MailTo -Subject $SubjectSuccess -Port $SMTPPort -Attachments "c:\admin\scripts\adupdate\successes\Successes-$Date.csv"}

