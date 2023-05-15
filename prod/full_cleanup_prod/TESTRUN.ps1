set-executionpolicy bypass -force -Scope LocalMachine

$allGroups = Get-LocalGroup #Gets all groups 
$admins = Get-LocalGroupMember -Group 'Administrators' #Gets all members of the 'Administrators' Group
$currentDomainandUser = "$($env:UserDomain)\$($env:UserName)" #Gets current user Domain and Username

try{

    #17 **Needs Testing with labs.ppdi.local access** Copies of the files can be dropped into and accessed from my .AM shared folder
    cd -path "C:\Users\$env:UserName\Desktop\Sanitization\repo"

    Start Radmin_Server_3.5.2.1_EN.msi -Wait

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Radmin_Server 3.5 has been installed."`n
         
}catch{

    Throw "A fatal error has occurred.[ --Could not install Radmin_Server 3.5.-- #17 ]"
}

Start-Sleep -s 6
