function Add-FileToBaseline {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]$baselineFilePath,
        [Parameter(Mandatory)]$targetFilePath
    )
    try{
        if((Test-Path -Path $baselineFilePath) -eq $false){
            Write-Error -Message "$baselineFilePath does not exist" -ErrorAction stop        
        }
        if ((Test-Path -Path $targetFilePath) -eq $false) {
            Write-Error -Message "$targetFilePath does not exist" -ErrorAction stop        
        }
        if ($baselineFilePath.Substring($baselineFilePath.Length - 4, 4) -ne ".csv") {
            Write-Error -Message "$baselineFilePath needs to be .csv file " -ErrorAction stop
        }
        
        $currentBaseline=Import-Csv -Path $baselineFilePath -Delimiter ","

        if($targetFilePath -in $currentBaseline.path){
            Write-Host "File path detected already in baseline file"
            do{
                $overwrite = Read-Host -Prompt "Path exists already in the baseline file, would you like to overwrite it? [Y/N] :"
                if ($overwrite -in @('y', 'yes')) {
                    Write-Host "Path will be overwritten"

                    $currentBaseline | Where-Object path -ne $targetFilePath | Export-Csv -Path $baselineFilePath -Delimiter "," -NoTypeInformation

                    $hash = Get-FileHash -Path $targetFilePath

                    "$($targetFilePath),$($hash.hash)" | Out-File -FilePath $baselineFilePath -Append

                    Write-Host "Entry successfully added into baseline"
                }
                elseif ($overwrite -in @('n', 'no')) {
                    Write-Host "File path will not be overwritten"
                }
                else {
                    Write-Host "Invalid entry, please enter y to overwrite or n to not overwrite"
                }
            }while ($overwrite -notin @('y','yes','n','no')) 
            
        }else{
            $hash = Get-FileHash -Path $targetFilePath

            "$($targetFilePath),$($hash.hash)" | Out-File -FilePath $baselineFilePath -Append

            Write-Host "Entry successfully added into baseline"
        }

        $currentBaseline=Import-Csv -Path $baselineFilePath -Delimiter ","
        $currentBaseline | Export-Csv -Path $baselineFilePath -Delimiter "," -NoTypeInformation
    }catch{
        Write-Error $_.Exception.Message
    }
}

function Test-Baseline {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]$baselineFilePath    
    )

    try {
        if ((Test-Path -Path $baselineFilePath) -eq $false) {
            Write-Error -Message "$baselineFilePath does not exist" -ErrorAction stop        
        }
        if ($baselineFilePath.Substring($baselineFilePath.Length - 4, 4) -ne ".csv") {
            Write-Error -Message "$baselineFilePath needs to be .csv file " -ErrorAction stop
        }

        $baselineFiles = Import-Csv -Path $baselineFilePath -Delimiter ","

        foreach ($file in $baselineFiles) {
            if (Test-Path -Path $file.path) {
                $currenthash = Get-FileHash -Path $file.path
                if ($currenthash.hash -eq $file.hash) {
                    Write-Host "$($file.path) still the same"
                }
                else {
                    Write-Host "$($file.path) hash is different something has changed"
                }

            }
            else {
                Write-Host "$($file.path) is not found!"
            }
        }
    }
    catch {
        Write-Error $_.Exception.Message
    }
}

function Set-Baseline {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]$baselineFilePath 
    )

    try {
        if ($baselineFilePath.Substring($baselineFilePath.Length - 4, 4) -ne ".csv") {
            Write-Error -Message "$baselineFilePath needs to be .csv file " -ErrorAction stop
        }
        if ((Test-Path -Path $baselineFilePath)) {
            Write-Error -Message "$baselineFilePath already exists with this name" -ErrorAction stop        
        }

        "path,hash" | Out-File -FilePath $baselineFilePath -Force
    }
    catch {
        Write-Error $_.Exception.Message
    }
    
}

$baselineFilePath=""

Write-Host "File Monitor System" -ForegroundColor Green
do{
    Write-Host "Please select one of the following options or enter q or quit to quit" -ForegroundColor Green
    Write-Host "1. Choose baseline file ; Current set baseline $($baselineFilePath)" -ForegroundColor Green
    Write-Host "2. Add path to baseline" -ForegroundColor Green
    Write-Host "3. Check files against baseline" -ForegroundColor Green
    Write-Host "4. Create a new baseline" -ForegroundColor Green
    $entry=Read-Host -Prompt "Please enter a selection"

    switch($entry){
        "1"{
            $baselineFilePath=Read-Host -Prompt "Enter the baseline file path"
            if(Test-Path -Path $baselineFilePath){
                if($baselineFilePath.Substring($baselineFilePath.Length-4,4) -eq ".csv"){

                }else{
                    $baselineFilePath=""
                    Write-Host "Invalid file needs to be .csv file" -ForegroundColor Red
                }
            }else{
                $baselineFilePath=""
                Write-Host "Invalid file path for baseline" -ForegroundColor Red
            }
        }
        "2"{
            $targetFilePath=Read-Host -Prompt "Enter the path of the file you want to monitor"
            Add-FileToBaseline -baselineFilePath $baselineFilePath -targetFilePath $targetFilePath
        }
        "3"{
            Test-Baseline -baselineFilePath $baselineFilePath
        }
        "4"{
            $newBaselineFilePath=Read-Host -Prompt "Enter path for new baseline file"
            Set-Baseline -baselineFilePath $newBaselineFilePath
        }
        "q"{}
        "quit"{}
        default{
            Write-Host "Invalid entry" -ForegroundColor Red
        }

    }

}while($entry -notin @('q','quit'))

#Set-Baseline -baselineFilePath $baselineFilePath

#Add-FileToBaseline -baselineFilePath $baselineFilePath -targetFilePath "C:\Users\No Ur\Desktop\ACI Internship\file-integrity\Files\test.txt"

#Test-Baseline -baselineFilePath $baselineFilePath



