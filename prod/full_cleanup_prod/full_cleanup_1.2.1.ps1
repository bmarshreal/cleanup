set-executionpolicy bypass -force -Scope LocalMachine
$allGroups = Get-LocalGroup #Gets all groups 
$admins = Get-LocalGroupMember -Group 'Administrators' #Gets all members of the 'Administrators' Group
$currentDomainandUser = "$($env:UserDomain)\$($env:UserName)" #Gets current user Domain and Username

try{

    #33,*Passed Test* Must be run in admin shell **

    C:\Windows\System32\cmd.exe /k %windir%\System32\reg.exe ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f 

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Turned off User Account Control Settings"`n

}catch{

    Throw "Inadequate permissions to perform this action.[ --Unable to turn off UAC.-- #33 ]"
   
}

Start-Sleep -s 4