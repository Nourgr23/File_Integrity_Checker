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
        
        $currentBaseline=Import-Csv -Path $baselineFilePath -Delimiter ","

        if($targetFilePath -in $currentBaseline.path){
            Write-Output "File path detected already in baseline file"
            do{
                $overwrite = Read-Host -Prompt "Path exists already in the baseline file, would you like to overwrite it? [Y/N] :"
                if ($overwrite -in @('y', 'yes')) {
                    Write-Output "Path will be overwritten"

                    $currentBaseline | Where-Object path -ne $targetFilePath | Export-Csv -Path $baselineFilePath -Delimiter "," -NoTypeInformation

                    $hash = Get-FileHash -Path $targetFilePath

                    "$($targetFilePath),$($hash.hash)" | Out-File -FilePath $baselineFilePath -Append

                    Write-Output "Entry successfully added into baseline"
                }
                elseif ($overwrite -in @('n', 'no')) {
                    Write-Output "File path will not be overwritten"
                }
                else {
                    Write-Output "Invalid entry, please enter y to overwrite or n to not overwrite"
                }
            }while ($overwrite -notin @('y','yes','n','no')) 
            
        }else{
            $hash = Get-FileHash -Path $targetFilePath

            "$($targetFilePath),$($hash.hash)" | Out-File -FilePath $baselineFilePath -Append

            Write-Output "Entry successfully added into baseline"
        }

        $currentBaseline=Import-Csv -Path $baselineFilePath -Delimiter ","
        $currentBaseline | Export-Csv -Path $baselineFilePath -Delimiter "," -NoTypeInformation
    }catch{
        return $_.Exception.Message
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

        $baselineFiles = Import-Csv -Path $baselineFilePath -Delimiter ","

        foreach ($file in $baselineFiles) {
            if (Test-Path -Path $file.path) {
                $currenthash = Get-FileHash -Path $file.path
                if ($currenthash.hash -eq $file.hash) {
                    Write-Output "$($file.path) still the same"
                }
                else {
                    Write-Output "$($file.path) hash is different something has changed"
                }

            }
            else {
                Write-Output "$($file.path) is not found!"
            }
        }
    }
    catch {
        return $_.Exception.Message
    }
}

function Set-Baseline {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]$baselineFilePath 
    )

    try {
        if ((Test-Path -Path $baselineFilePath)) {
            Write-Error -Message "$baselineFilePath already exists with this name" -ErrorAction stop        
        }

        "path,hash" | Out-File -FilePath $baselineFilePath -Force
    }
    catch {
        return $_.Exception.Message
    }
    
}

$baselineFilePath="C:\Users\No Ur\Desktop\ACI Internship\file-integrity\baselines.csv"

#Set-Baseline -baselineFilePath $baselineFilePath

Add-FileToBaseline -baselineFilePath $baselineFilePath -targetFilePath "C:\Users\No Ur\Desktop\ACI Internship\file-integrity\Files\test.txt"

Test-Baseline -baselineFilePath $baselineFilePath



