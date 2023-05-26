set-executionpolicy bypass -Scope LocalMachine -force

try{

    #9 **Passed PROD Test**

    tzutil /s 'Central Standard Time'

    Write-Host -ForegroundColor Green `n"The Following Action has Successfully Completed: ....Time Zone updated to 'Central Standard Time' ."`n
         
}catch{

    Throw "A fatal error has occurred.[ --Could not update Time Zone settings.-- #9 ]"

}

Start-Sleep -s 6

try{

    #10 **Passed PROD Test**

    $initprompt = Read-Host -Prompt "Please type 'T' and press the Enter key if you'd like to skip this test for testing. Otherwise type 'C' to continue normally."

    if($initprompt -eq "C"){

        $DomainCredential = $host.ui.PromptForCredential("Need credentials", "Please enter your AI Credentials in the following prompt(s) to join this computer to the network domain.", "", "NetBiosUserName")
        
        Add-Computer -DomainName labs.ppdi.local -Credential $DomainCredential

        $hostmessage = (-join("The Following Action has Successfully Completed: ... The computer has joined the domain. Moving on..."))

        Write-Host -ForegroundColor Green `n $hostmessage`n

        Start-Sleep -s 3

        $newname = Read-Host -Prompt "Please enter the new name of this computer."

        Rename-Computer -NewName $newname -DomainCredential $DomainCredential -Force

        $hostmessage = (-join("The Following Action has Successfully Completed: ... The computer will be renamed to ",$newname,"."))

        Write-Host -ForegroundColor Green `n $hostmessage`n

        

    }elseif($initprompt -eq "T"){
    
        Write-Host -ForegroundColor Red `n"You have chosen to skip this step for testing purposes. Moving on..."`n

    }
         
}catch{

    Throw "A fatal error has occurred.[ --Could not Rename the PC and/or add it to the domain.-- #10 ]"

}

Start-Sleep -s 6

    $optional_restart = Read-Host `n"This is an optional restart point. Type the word "yes" to restart now, otherwise type the word "no" to continue..."`n

    if($optional_restart -eq "yes"){
        
        Write-Host -ForegroundColor Red `n"You have chosen to restart this computer now. Restarting..."`n
        shutdown -r -t 5    
    
    }else{
    
        Write-Host -ForegroundColor Green `n"You have chosen not the restart the computer at this point. Please continue with the Sanitization process..."`n

    }
    

Start-Sleep -s 6