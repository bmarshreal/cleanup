﻿#**************Script must be run from an Administrator account in an Administrator Shell**************#

#Search Reg key 'hkcu' for all items like the word *tool; Get-ChildItem -Path hkcu:\ -Recurse -ErrorAction SilentlyContinue | Where-Object {$_.Name -like "*tool*"}*#

#Pinned items on  toolbar: C:\Users\$env:UserName\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar

#When script is validated, change Write-Host commands to Throw commands

#MSI File Installation options command for use in powershell or cmd: #Start-Process -FilePath "<Program Installer.EXE Path>" -Verb runAs -ArgumentList /?

Set-ExecutionPolicy bypass -Force

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

    Rename-LocalUser -Name "Administrator" -NewName "labadmin"
    $Password = Read-Host -AsSecureString "Please set the standard password in the prompt. Hint: '>Bier=...' "
    $UserAccount = Get-LocalUser -Name "labadmin"
    $UserAccount | Set-LocalUser -Password $Password
    Set-LocalUser -Name "labadmin" -PasswordNeverExpires 1
    Add-LocalGroupMember -Group "Remote Desktop Users" -Member "PA Validation-Team"
    $users = Get-LocalUser

    foreach($user in $users){
    
        if($user.Name -eq "labadmin" -or $user.Name -eq "Admin" -or $user.Name -eq "Administrator"){
        
            Write-Host $user.Name "Administrator Found"
        
        }else{
        
            Write-Host $user.Name "This is not an Administrative account, it will now be disabled."
            Disable-LocalUser $user.Name
        
        }
    
    }


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

    $keyOneCount = (Get-ChildItem -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate").ValueCount
    $keyTwoCount = (Get-ChildItem -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU").ValueCount

    if($keyOneCount -lt 5 -or $keyTwoCount -lt 6){

        Write-Host -ForegroundColor Yellow `n"The Following Action is in Progress: ....Registry Keys and values COULD NOT be verified, they will now be configured."`n

        gpupdate /force

        usoclient startscan
    
    }else{
    
        Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Registry Keys and values have been verified."`n
    
    }



    <#

    HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate
    "TargetGroupEnabled"=dword:00000001
    "ElevateNonAdmins"=dword:00000000
    "WUServer"="http://madintsus001:8530"
    "WUStatusServer"="http://madintsus001:8530"
    "TargetGroup"="Pre-Deployment SAs"

    HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU
    "NoAutoUpdate"=dword:00000000
    "UseWUServer"=dword:00000001
    "NoAUShutdownOption"=dword:00000001
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

    foreach($program in $programsList){
    
        if($program -like "*OneDrive*" -or $program -like "*Windows Media Player*" -or $program -like "*CutePDF*"){
        
            $MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq $program}

            $MyApp.Uninstall()
        
        }
    
    }

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Unecessary applications have been uninstalled."`n
         
}catch{

    Throw "A fatal error has occurred.[ --Could not Uninstall all unecessary software.-- #16 ]"
}

Start-Sleep -s 6
<#
try{

    #17 **Needs Testing with labs.ppdi.local access**

    Start-Process -FilePath "\\labs\Madison\AdminInstalls\Radmin\Radmin_Server_3.5" -Verb runAs

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

    Start-Process -FilePath "\\labs\madison\AdminInstalls\Adobe Reader DC\AcroRdrDC1900820081_en_US.exe" -Verb runAs

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Adobe Reader DC has been installed."`n
         
}catch{

    Throw "A fatal error has occurred.[ --Could not install Adobe DC Reader.-- #19 ]"
}

Start-Sleep -s 6

#>

try{

    #20 

    Write-Host -ForegroundColor Yellow `n"Please refer to your Validation Analyst to verify if this computer requires Microsoft Office or not..."`n
         
}catch{

    Throw "A fatal error has occurred.[ --Unknown Error.-- #20 ]"
}

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
    if($W32TMStat.Source -match "^MADDC01.*"-or $W32TMStat.Source -like "^MADDC02.*"){
    
        return $true
    
    }else{
    
        return $false
    
    }

}
 
 try{

    #24 *Needs Further Testing* TO BE CHANGED TO  "MADDC01 or MADDC02" IN FINAL VERSION!!!***

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

    function Sched-Cleanup($arg){

        #$tasks = ConvertFrom-StringData ($arg -join "`n" -replace ':', '=')
        foreach($name in $arg.TaskName){
            if($name -like "One*" -or $name -like "Adobe*"){

                #Unregister-ScheduledTask -TaskName $name -Confirm:$false        
                Write-Host "The Scheduled Task..." $name "has been unregistered."

            }
    
        }
 }

 try{

    #25*Passed Test*
 
    Sched-Cleanup(Get-ScheduledTask)

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

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Turned off power management of NICs and USB ports"`n


}catch{

    Throw "Inadequate permissions to perform this action. [ --Unable to Disable Power Management.-- #30 ]"

}

Start-Sleep -s 4

try{

    #31 **Passed Test**

    POWERCFG /HIBERNATE OFF
    POWERCFG -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Hibernate is turned off and computer is set to High Performance power settings"`n

}catch{

    Throw "Inadequate permissions to perform this action. [ --Unable to either turn Hibernate mode off or high performance mode on.-- #31 ]"
    
}

Start-Sleep -s 4

try{

    #32*Passed Test*

    Disable-WindowsErrorReporting
    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Windows Troubleshooting has been disabled."`n
}catch{ 

    Throw "A fatal error has occurred.[ --Could not disable troubleshooting.-- #32 ]" 
    
}

Start-Sleep -s 4

try{

    #33,*Passed Test* Must be run in admin shell **

    C:\Windows\System32\cmd.exe /k %windir%\System32\reg.exe ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Turned off User Account Control Settings"`n

}catch{

    Throw "Inadequate permissions to perform this action.[ --Unable to turn off UAC.-- #33 ]"
   
}

Start-Sleep -s 4

try{

    #34 **Passed Test**Needs testing at physical PC!**

    $netAdapterList = Get-NetAdapter | Format-List

    foreach($item in $netAdapterList){
        
        if($item.Name -like "*Bluetooth*" -or $item.Name -like "*Wifi*"){
        
            Disable-NetAdapter -Name $item.Name
        
        }
    
    }

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Bluetooth and WiFi have been disabled."`n


}catch{ 

    Throw "A fatal error has occurred.[ --Could not turn off either Boothtooth or Wifi Adapters.-- #34 ]" 
    
}

Start-Sleep -s 4

try{

    #35*Passed Test*

    New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows" -Name "Explorer" -force
    New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -PropertyType "DWord" -Value 1
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -PropertyType "DWord" -Value 0

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Notifications have been disabled."`n

}catch{ 

    Throw "A fatal error has occurred.[ --Could not disable notifications.-- #35 ]" 
    
}

Start-Sleep -s 4

try{

    #36*Passed Test*

    $pageFile = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges
    $pageFile.AutomaticManagedPagefile = $true #SET TO $FALSE TO DISABLE automatic swap file management
    $pageFile.put() | Out-Null

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Automatic Swap File Management has been Enabled"`n
    
}catch{

    Throw "Inadequate permissions to perform this action.[ --Unable to enable automatic swap file management.-- #36 ]" 
}

Start-Sleep -s 4

try{
    #37*Passed Test*

    $disableIndex = Get-WmiObject -Class Win32_Volume -Filter "DriveLetter='C:'"
    $disableIndex.IndexingEnabled = $false
    $disableIndex.Put()

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: '....Allow Indexing Service to index this disk for fast file searching' has been turned off for all hard drives."`n
    
}catch{

    Throw "Inadequate permissions to perform this action.[ --Disable automatic indexing of hard drive letter C:.-- #37 ]"
  
}

Start-Sleep -s 4

try{

    #38*Passed Test*

    Write-Host -ForegroundColor Yellow `n"This step will be skipped in this script due to the rarity of its use."`n
    
}catch{ 

    Throw "A fatal error has occurred.[ --Unknown Error.-- #38 ]" 
    
}

Start-Sleep -s 4

    #Unpin-App Function: Function accepts $appname (name of application) argument to unpin from the Taskbar.

    function Unpin-App($appname) {

    ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() |
        ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from taskbar'} | %{$_.DoIt()}
}

try{

    #39*Passed Test*

    #Remove all shortcuts from the desktop

    $desktop = Get-ChildItem -path C:\Users\$env:UserName\Desktop\

    foreach($item in $desktop){

        if($item -notlike "*Recycling Bin*" -or $item -notlike "*Adobe Reader*"){Remove-Item C:\Users\$env:UserName\Desktop\$item}

        Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....All Desktop items excluding Adobe Reader & Recycling Bin have been removed."`n

}
    #___________________________________________________________________________________________________________________________________
    
    #Unpin all items from the taskbar

    $toolbar = Get-ChildItem -Exclude ".lnk" "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"

    foreach($item in $toolbar){
    
        if($item.Name -notlike "*File Explorer*" -or $item.Name -notlike "*Task View*"){
           
            Unpin-App($item.Name.Replace(".lnk",""))

        }
    
    }
        Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....All Taskbar items excluding File Explorer & Task View have been removed."`n

    #___________________________________________________________________________________________________________________________________
    
    #Unpin all items from the start menu

    (New-Object -Com Shell.Application).
    NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').
    Items() |
    %{ $_.Verbs() } |
    ?{$_.Name -match 'Un.*pin from Start'} |
    %{$_.DoIt()}

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....All Start Menu items have been removed."`n

}catch{ 

    Throw "A fatal error has occurred.[ --Either could not unpin items from Taskbar\Start Menu or delete items from the Desktop.-- #39 ]" 
    
}

Start-Sleep -s 4

try{

    #40

}catch{ 

    Throw "A fatal error has occurred.[ --.-- ]" 
    
}

try{

    #41*Passed Test*

    msfeedssync disable
    
    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Msfeedssync.exe has been disabled."`n

}catch{ 

    Throw "A fatal error has occurred.[ --Could not disable Msfeedssync.exe.-- #41 ]" 
    
}

try{

    #42

    Write-Host -ForegroundColor Yellow `n"This step is not included in this program due to the rarity of its use."`n


}catch{ 

    Throw "A fatal error has occurred.[ --Unknown Error.-- #42 ]" 
    
}

try{

    #43

}catch{ 

    Throw "A fatal error has occurred.[ --.-- ]" 
    
}

try{

    #44/#45

    Write-Host -ForegroundColor Magenta `n"Please wait 24 hours for this PC to update.Then perform a Windows search for 'Check for updates'. Apply updates until computer says it's up to date... Restarting now..."`n 
    shutdown -r -t 10

}catch{ 

    Throw "A fatal error has occurred.[ --This PC could not be shutdown/restarted. Uknown Error.-- #44/#45 ]" 
    
}

Start-Sleep -s 4


#***___________________________Code below this point is for testing only... Disregard all code beyond this point...___________________________***#

<#

try{

    #46

}catch{ 

    Throw "A fatal error has occurred.[ --.-- ]" 
    
}

try{

    #47

}catch{ 

    Throw "A fatal error has occurred.[ --.-- ]" 
    
}

try{

    #48

}catch{ 

    Throw "A fatal error has occurred.[ --.-- ]" 
    
}

try{

    #49

}catch{ 

    Throw "A fatal error has occurred.[ --.-- ]" 
    
}

Stop



try{
    #10
    $Username = Read-Host -Prompt "Please enter your username."
    $Password = Read-Host -Prompt "Please enter your password." | ConvertTo-SecureString -AsPlainText -Force
    $CurrentPCName = Read-Host -Prompt "Please enter your computers CURRENT name."
    $NewPCName = Read-Host -Prompt "Please enter your computers NEW name."
    $Domain = Read-Host -Prompt "Please enter your required domain."
    $Creds = New-Object System.Management.Automation.PSCredential($Username ,$Password)


    Rename-Computer -NewName $NewPCName -ComputerName $CurrentPCName -Restart -DomainCredential $Creds
    
         
}catch{
    
    Throw "A fatal error has occurred.[ --Invalid Credentials or Computer Name/Domain.-- ]"
}

try{
    #11
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
    
         
}catch{

    Throw "Error... Command Failed."
}

Write-host "TEST"

#if((Get-ScheduledTask -TaskName -like "o")){Write-Host Get-ScheduledTask -TaskName}

#>