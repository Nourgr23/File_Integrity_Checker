$baselineFilePath="C:\Users\No Ur\Desktop\ACI Internship\file-integrity\baselines.csv"

##Add a file to the baseline csv
$fileToMonitorPath="C:\Users\No Ur\Desktop\ACI Internship\file-integrity\Files\test1.txt"
$hash=Get-FileHash -Path $fileToMonitorPath

"$($fileToMonitorPath),$($hash.hash)" 

##Monitor the file
$baselineFiles=Import-Csv -Path $baselineFilePath -Delimiter ","

foreach($file in $baselineFiles){
    if(Test-Path -Path $file.path){
        $currenthash=Get-FileHash -Path $file.path
        if($currenthash.hash -eq $file.hash){
            Write-Output "$($file.path) still the same"
        }else{
            Write-Output "$($file.path) hash is different something has changed"
        }

    }else {
        Write-Output "$($file.path) is not found!"
    }
}

