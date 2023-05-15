#**************Script must be run from an Administrator account in an Administrator Shell**************#

#Search Reg key 'hkcu' for all items like the word *tool; Get-ChildItem -Path hkcu:\ -Recurse -ErrorAction SilentlyContinue | Where-Object {$_.Name -like "*tool*"}*#

#Pinned items on  toolbar: C:\Users\$env:UserName\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar

#When script is validated, change Write-Host commands to Throw commands

#MSI File Installation options command for use in powershell or cmd: #Start-Process -FilePath "<Program Installer.EXE Path>" -Verb runAs -ArgumentList /?

set-executionpolicy bypass -Scope LocalMachine -force

$allGroups = Get-LocalGroup #Gets all groups 
$admins = Get-LocalGroupMember -Group 'Administrators' #Gets all members of the 'Administrators' Group
$currentDomainandUser = "$($env:UserDomain)\$($env:UserName)" #Gets current user Domain and Username


try{
    
    #0 **Passed PROD Test**

     if($currentDomainandUser -in $admins.Name){
    
        Write-Host -ForegroundColor Green `n'***The Following Action has Successfully Completed: ....The current user is a CONFIRMED member of the Administrators group in the appropriate Domain. Starting Program Now....***'`n
        
    }else{
    
        Throw #This 'Throw' allows a break from the if statement into the catch 'Throw' to exit the program.
       
    }

}catch{
    
        Throw "A fatal error has occurred. [ --Could NOT confirm that the current user is a member of the Administrators group. Exiting program now...-- #0 ]" 
        $ErrorActionPreference = "Stop"
         
}

Start-Sleep -s 6

try{

    #12 **Passed PROD Test**


    Write-Host -ForegroundColor Yellow `n"Skipping this step...This action will be implemented in the final version of the script at a later date."`n
         
}catch{

    Throw "A fatal error has occurred.[ --An unknown error has occured.-- #12 ]"

}

Start-Sleep -s 6

try{

    #13 **Passed PROD Test**

   
    $Password = Read-Host -AsSecureString "Please set the standard password in the prompt. Hint: Usual labadmin password... "
    $Password_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
    $check = 0

    while($check -lt 1){
    
        $verifyPassword = Read-Host -AsSecureString "Please Re-Enter the password to ensure that it is correct..."
        $verifyPassword_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($verifyPassword))
        $verifyPassword

        if($verifyPassword_text -eq $Password_text){
        
            Write-Host -ForegroundColor Cyan `n"Password has been successfully set! Moving on..."`n
            $check = 1
            
        }else{
            
            Write-Host -ForegroundColor Red `n"Passwords did not match, please try again."`n
            $verifyPassword
        }
    }
    Rename-LocalUser -Name "Administrator" -NewName "labadmin"
    $UserAccount = Get-LocalUser -Name "labadmin"
    $UserAccount | Set-LocalUser -Password $Password
    Set-LocalUser -Name "labadmin" -PasswordNeverExpires 1
    Add-LocalGroupMember -Group "Remote Desktop Users" -Member "PA Validation-Team"
    $users = Get-LocalUser

    foreach($user in $users){
    
        if($user.Name -eq "labadmin" -or $user.Name -eq "Admin" -or $user.Name -eq "Administrator" -or $user.Name -eq $env:UserName){
        
            Write-Host $user.Name "[Administrator Found]"
        
        }elseif($user.Name -ne "labadmin" -or $user.Name -ne "Admin" -or $user.Name -ne "Administrator" -or $user.Name -ne $env:UserName){
        
            Write-Host $user.Name "This is not an Administrative account, it will now be disabled."
            Disable-LocalUser $user.Name
            Enable-LocalUser "labadmin"
            Enable-LocalUser $env:UserName
        
        }
    
    }
    Enable-LocalUser "labadmin"
    Enable-LocalUser $env:UserName

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Updated Remote Desktop Users and Administrator name. All accounts other than 'labadmin' have been disabled."`n
         
}catch{

    Throw "A fatal error has occurred.[ --Could not update Remote Desktop Users group / Administrator name settings. All accounts may not be disabled.-- #13 ]"

}

Start-Sleep -s 6

try{

    #14 **Needs Testing with labs.ppdi.local access**

    ECHO Y | gpupdate /force 

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....The Group Policy has been updated."`n
    
         
}catch{

    Throw "A fatal error has occurred.[ --Could not update the group policy.-- #14 ]"

}

Start-Sleep -s 6

try{

    #15 *Passed Test*
    $keyOne = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $keyTwo = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    $keyOneCount = (Get-Item -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate").ValueCount
    $keyTwoCount = (Get-ChildItem -recurse "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate").ValueCount

    if($keyOneCount -le 4 -or $keyTwoCount -le 4){

        Write-Host -ForegroundColor Yellow `n"The Following Action is in Progress: ....Registry Keys and values COULD NOT be verified, they will now be configured."`n

        Write-Host -ForegroundColor Yellow `n"This could take a few minutes... Please wait."`n

        gpupdate /force

        usoclient startscan

        $tupleList1 = @(
    
            [tuple]::Create("TargetGroupEnabled", 1, 'DWORD'),
            [tuple]::Create("ElevateNonAdmins", 0, 'DWORD'),
            [tuple]::Create("WUServer", "http://madintsus001:8530", "String"),
            [tuple]::Create("WUStatusServer", "http://madintsus001:8530", "String"),
            [tuple]::Create("TargetGroup", "Pre-Deployment SAs", "String")
            
        )

        $tupleList2 = @(
    
            [tuple]::Create("NoAutoUpdate", 0, 'DWORD'),
            [tuple]::Create("UseWUServer", 1, 'DWORD'),
            [tuple]::Create("NoAUShutdownOption", 1, 'DWORD'),
            [tuple]::Create("AUOptions", 2, 'DWORD'),
            [tuple]::Create("ScheduledInstallDay", 0, 'DWORD'),
            [tuple]::Create("ScheduledInstallTime", 3, 'DWORD')

        )

    
        foreach($item1 in $tupleList1){
        
            New-ItemProperty -Path $keyOne -Name $item1.item1 -Value $item1.item2 -PropertyType $item1.item3

        }

        foreach($item2 in $tupleList2){
        
            New-ItemProperty -Path $keyTwo -Name $item2.item1 -Value $item2.item2 -PropertyType $item2.item3

        }


    
    }else{
    
        Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Registry Keys and values have been verified."`n
    
    }
    



    <#
    $HKLMWUpath = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    $HKLMWUAUpath = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

    $tupleList1 = @(
    
    [tuple]::Create("TargetGroupEnabled", 1, DWORD),
    [tuple]::Create("ElevateNonAdmins", 0, DWORD),
    [tuple]::Create("WUServer", "http://madintsus001:8530", String),
    [tuple]::Create("WUStatusServer", "http://madintsus001:8530", String),
    [tuple]::Create("TargetGroup", "Pre-Deployment SAs", String)
    
    )

    $tupleList2 = @(
    
    [tuple]::Create("NoAutoUpdate", 0, DWORD),
    [tuple]::Create("UseWUServer", 1, DWORD),
    [tuple]::Create("NoAUShutdownOption", 1, DWORD),
    [tuple]::Create("AUOptions", 2, DWORD),
    [tuple]::Create("ScheduledInstallDay", 0, DWORD),
    [tuple]::Create("ScheduledInstallTime", 3, DWORD),

    )


    HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate
    "TargetGroupEnabled"=dword:00000001
(5) "ElevateNonAdmins"=dword:00000000
    "WUServer"="http://madintsus001:8530"
    "WUStatusServer"="http://madintsus001:8530"
    "TargetGroup"="Pre-Deployment SAs"

    HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
    "NoAutoUpdate"=dword:00000000
    "UseWUServer"=dword:00000001
(6) "NoAUShutdownOption"=dword:00000001
    "AUOptions"=dword:00000002
    "ScheduledInstallDay"=dword:00000000
    "ScheduledInstallTime"=dword:00000003
    
    #>
    
    
         
}catch{

    Throw "A fatal error has occurred.[ --Could not verify / update registry keys .-- #15 ]"
}

Start-Sleep -s 6

try{

    #16 *Passed Test*

    $programsList = (Get-WmiObject -Class Win32_Product).Name
    $removeList = @("*OneDriver*","*Windows Media Player*","*CutePDF*")

    foreach($program in $programsList){
    
        if($program -in $removeList){
        
            $MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq $program}

            $MyApp.Uninstall()
        
        }
    
    }

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Unecessary applications have been uninstalled."`n
         
}catch{

    Throw "A fatal error has occurred.[ --Could not Uninstall all unecessary software.-- #16 ]"
}

Start-Sleep -s 6

try{

    #17 **Pass**
    cd -path "C:\Users\$env:UserName\Desktop\Sanitization\repo"

    Start Radmin_Server_3.5.2.1_EN.msi -Wait

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Radmin_Server 3.5 has been installed."`n
         
}catch{

    Throw "A fatal error has occurred.[ --Could not install Radmin_Server 3.5.-- #17 ]"
}

Start-Sleep -s 6

try{

    #18 

    Write-Host -ForegroundColor Yellow `n"Moving on... Please wait..."`n
         
}catch{

    Throw "A fatal error has occurred.[ --Unknown Error.-- #18 ]"
}

Start-Sleep -s 6


try{

    #19 **Needs Testing with labs.ppdi.local access**

    cd -path "C:\Users\$env:UserName\Desktop\Sanitization\repo"

    Start AcroRdrDC1900820081_en_US.exe -Wait

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Adobe Reader DC has been installed."`n
         
}catch{

    Throw "A fatal error has occurred.[ --Could not install Adobe DC Reader.-- #19 ]"
}

Start-Sleep -s 6

<#

try{

    #20 

    

    Mount-DiskImage -ImagePath "C:\Users\$env:UserName\Desktop\Sanitization\repo\en_office_professional_plus_2019_x86_x64_dvd_7ea28c99.iso" 

    Start-Sleep -s 10

    $disks = Get-CimInstance win32_logicaldisk

    foreach($item in $disks){
    
        if($item.VolumeName -eq "16.0.10730.20102"){
            
            cd -Path $item.DeviceID
            
            Start Setup.exe -Wait   
        }
    
    }

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Microsoft Office 2016 has been installed."`n
         
}catch{

    Throw "A fatal error has occurred.[ --Could not install Microsoft Office 2016.-- #20 ]"
}

#>

Start-Sleep -s 6



#***___________________________Code below this point is not Inst-Net specific... Code above this point may require access to the Inst-Net___________________________***#




try{

    #21*Passed Test*

    $defrag = schtasks /Change /DISABLE /TN "\Microsoft\Windows\Defrag\ScheduledDefrag"
    $defrag

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Turned off Automated Defragmentation"`n
         
}catch{

    Throw "A fatal error has occurred.[ --Was unable to Defrag.-- #21 ]"
}

Start-Sleep -s 4

try{
    
    #22*Passed Test*

    Stop-Service -Force -Name "SysMain" 
    Set-Service -Name "SysMain" -StartupType Disabled
    
    
    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Disabled SuperFetch or SysMain service"`n
         
}catch{

    Throw "A fatal error has occurred.[ --SysMain Service Could Not Be Disabled.-- #22 ]"
}   

Start-Sleep -s 4

try{
    
    #23*Passed Test*

    Set-Service -Name "W32Time" -Status Running -StartupType Automatic

    tzutil /s "Central Standard Time"

    w32tm /query /status
    
    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Verified that 'Windows Time' Service is turned on and is running."`n
         
}catch{

    Throw "A fatal error has occurred.[ --Could not verify that Windows Time is currently turned on or running.-- #23 ]"
}

Start-Sleep -s 4

    #GET-W32TMStatus Function: Function returns True if Windows Time service is synching correctly, otherwise it returns False.

    function GET-W32TMStatus($arg){

    $W32TMStat = ConvertFrom-StringData ($arg -join "`n" -replace ':', '=')
    if($W32TMStat.Source -match "^MADDC01.*"-or $W32TMStat.Source -match "^MADDC02.*"){
    
        return $true
    
    }else{
    
        return $false
    
    }

}
 
 try{

    #24 *Passed Test***

    if(GET-W32TMStatus(w32tm /query /status) -eq $true){
        
        Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....W32TM Source Name Verified... Moving On... Verified that the Windows Time is syncing correctly."`n
    
    }else{
    
       throw
    }

}catch{

    Throw "[ --This system is not synchronized with either source: MADDC01 or MADDC02.-- #24 ]"

}

Start-Sleep -s 4

    #Sched-Cleanup Function: Function searches through all Scheduled Tasks for "One-Drive" and "Adobe" and unschedules them.

    <#
    function Sched-Cleanup($arg){

        $tasks = ConvertFrom-StringData ($arg -join "`n" -replace ':', '=')
        foreach($name in $arg.TaskName){
            if($name -match "One*" -or $name -match "Adobe*"){

                #Unregister-ScheduledTask -TaskName $name -Confirm:$false        
                Write-Host "The Scheduled Task..." $name "has been unregistered."

            }
    
        }
 }

 #>

 try{

    #25*Passed Test*

    foreach($task in Get-ScheduledTask){
    
        if($task.TaskName -like "One*" -or $task.TaskName -like "Adobe*"){
        
            Stop-ScheduledTask -TaskName $task.TaskName

            Unregister-ScheduledTask -TaskName $task.TaskName
            
            write-host $task.TaskName "Has been removed"
        
        }
    
    }

    <#
 
    Sched-Cleanup(Get-ScheduledTask)
    
    if($(Get-ScheduledTask -TaskName "TASKNAME HERE" -ErrorAction SilentlyContinue).TaskName -eq "TASKNAME HERE") {
    
        Unregister-ScheduledTask -TaskName "TASKNAME HERE" -Confirm:$False
    
    }
    #>
    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Removed Windows tasks that are not needed"`n

}catch{

    Throw "A fatal error has occurred.[ --Could not remove scheduled task.-- #25 ]"

}

Start-Sleep -s 4

try{

    #26*Passed Test*

    Set-NetFirewallProfile -Enabled False

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Turned off Windows Firewall"`n

}catch{

    Throw "Inadequate permissions to perform this action. [ --Disable Firewall. -- #26 ]"

}

Start-Sleep -s 4

try{

    #27*Passed Test*

    $defaultBrowserKeyHTTPS = (Get-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice' -Name ProgId).ProgId 
    $defaultBrowserKeyHTTP = (Get-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice' -Name ProgId).ProgId 

    if($defaultBrowserKeyHTTPS -ne "IE.HTTPS" -or $defaultBrowserKeyHTTP -ne "IE-HTTP"){

        Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice' -Name ProgId -Value 'IE-HTTPS'

        Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice' -Name ProgId -Value 'IE-HTTP'
}
    
    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Internet Explorer has been set as the default browser."`n

}catch{

    Throw "Inadequate permissions to perform this action. [ --Unable to Set Default Browser.-- #27 ]"

}

Start-Sleep -s 4

try{

    #28*Passed Test*

    #Navigate to the domains folder in the registry

    Set-Location "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\" #Default Security

    #Set-Location "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\EscDomains\" #For Enchanced Security

    New-Item ppdi.local
    Set-Location ppdi.local
    New-ItemProperty . -Name https -Value 2 -Type DWORD

    #Create a new folder with the trusted website name
    
    Write-Host "Trusted-Site added Successfully"
    Start-Sleep -s 2
    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Added https://*.ppdi.local to trusted sites"`n
    

}catch{

    Throw "Inadequate permissions to perform this action. [ --Unable to Set Trusted Sites.-- #28 ]"

}

Start-Sleep -s 4

    #Get-PnpErrors Function: Function searches through all PnpDevices for an Error-State. If the devices is in an Error-State, an error will be thrown. 

    function Get-PnpErrors($arg){

        if($arg.Name -eq "Error"){
            return $false
        }else{
            return $true
        }

}

try{

    #29 *Passed Test*

    foreach($item in Get-PnpDevice){
    
        Get-PnpErrors($item) 

    }

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Verified that devices in Device Manager are functional"`n

}catch{

    Throw "An error has occured [ --Device was found with an error status.-- #29 ]"
}

Start-Sleep -s 4

try{
    #30 **Passed Test**

   $hubs = Get-WmiObject Win32_Serialport | Select-Object Name,DeviceID,Description
   $powerMgmt = Get-WmiObject MSPower_DeviceEnable -Namespace root\wmi
   foreach ($powerItem in $powerMgmt){
     $IN = $powerItem.InstanceName.ToUpper()
     foreach ($hub in $hubs){
        $PNPDI = $hub.PNPDeviceID
        if ($IN -like "*$PNPDI*"){
            $powerItem.enable = $False
            $powerItem.psbase.put()
                }
           }
    }

    $adapters = Get-NetAdapter | Get-NetAdapterPowerManagement

    foreach ($adapter in $adapters){

        $adapter.AllowComputerToTurnOffDevice = 'Disabled'

        $adapter | Set-NetAdapterPowerManagement

} 
    Set-CimInstance -Query 'SELECT * FROM MSPower_DeviceEnable WHERE InstanceName LIKE "USB\\%"' -Namespace root/WMI -Property @{Enable = $false}
    Set-CimInstance -Query 'SELECT * FROM MSPower_DeviceEnable WHERE InstanceName LIKE "Intel(R) USB 3.1 eXtensible Host Controller - 1.10\\%"' -Namespace root/WMI -Property @{Enable = $false}

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Turned off power management of NICs and USB ports"`n


}catch{

    Throw "Inadequate permissions to perform this action. [ --Unable to Disable Power Management.-- #30 ]"

}

Start-Sleep -s 4

try{

    #31 **Passed Test**

    powercfg /change standby-timeout-ac 0
    powercfg /change standby-timeout-dc 0
    powercfg /change monitor-timeout-ac 0
    powercfg /change monitor-timeout-dc 0
    powercfg /change hibernate-timeout-ac 0
    powercfg /change hibernate-timeout-dc 0
    POWERCFG -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Hibernate is turned off and computer is set to High Performance power settings"`n

}catch{

    Throw "Inadequate permissions to perform this action. [ --Unable to either turn Hibernate mode off or high performance mode on.-- #31 ]"
    
}

Start-Sleep -s 4

try{

    #32*Passed Test*

    Disable-WindowsErrorReporting

    explorer "shell:::{C58C4893-3BE0-4B45-ABB5-A63E4B8C8651}\settingPage\"

    Write-Host -ForegroundColor Cyan `n"Please toggle troubleshooting to the off position"`n

    Start-Sleep -s 5

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Windows Troubleshooting has been disabled."`n

}catch{ 

    Throw "A fatal error has occurred.[ --Could not disable troubleshooting.-- #32 ]" 
    
}
Start-Sleep -s 10

