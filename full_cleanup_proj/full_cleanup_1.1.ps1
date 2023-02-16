Set-ExecutionPolicy bypass -Force

try{

    #9 **Passed Test**

    tzutil /s 'Central Standard Time'

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Time Zone updated to 'Central Standard Time' ."`n
         
}catch{

    Throw "A fatal error has occurred.[ --Could not update Time Zone settings.-- #9 ]"

}

Start-Sleep -s 6

try{

    #10

    $newname = Read-Host -Prompt "Please enter the new name of this computer."
    $localdomain = $env:USERDOMAIN
    $Credential = $host.ui.PromptForCredential("Need credentials", "Please enter your AI Credentials to change this computers name.", "", "NetBiosUserName")
    Rename-Computer -NewName $newname -ComputerName $localdomain -DomainCredential $Credential  
    Add-Computer -DomainName labs.ppdi.local

    $pcname = $env:computername
    $hostmessage = (-join("The Following Action has Successfully Completed: ... The computer has been renamed to ",$pcname,"."))

    Write-Host -ForegroundColor Yellow `n"DO NOT RESTART THIS COMPUTER YET! PLEASE IGNORE ALL "RESTART NOW" PROMPTS.`n WHEN THE SCRIPT HAS FINISHED, IT WILL RESTART THIS COMPUTER."`n

    Write-Host -ForegroundColor Green `n $hostmessage`n
         
}catch{

    Throw "A fatal error has occurred.[ --Could not Rename the PC and/or add it to the domain.-- #10 ]"

}

Start-Sleep -s 6

try{

    #11

    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0 -Force
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

    shutdown -r -t 5

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ...Remote Access is now available on this computer. This computer will now restart. After restart, please launch the full_cleanup 1.2 script...  "`n
         
}catch{

    Throw "A fatal error has occurred.[ --Could not enable Remote Desktop Portal.-- #11 ]"

}

Start-Sleep -s 6