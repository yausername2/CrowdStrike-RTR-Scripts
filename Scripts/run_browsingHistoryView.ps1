<#
.SYNOPSIS
This script is designed to run in CrowdStrike RTR (Real Time Response) or another EDR (Endpoint Detection and Response) RTR module to collect browsing history, save it to a CSV file, encrypt it with a password, and clean up temporary files.

.DESCRIPTION
This script automates the process of extracting browsing history using 'BrowsingHistoryView', saving the data in CSV format, compressing the CSV file into a password-protected ZIP archive, and cleaning up temporary files. It ensures required directories and tools are available, handles errors gracefully, and removes sensitive data after processing.

.NOTES
- Replace 'YOUR_PASSWORD' in the compression arguments with a strong password of your choice. The password is used in the 7-Zip compression step to secure the ZIP file containing the browsing history.
- Ensure that the BrowsingHistoryView archive and 7-Zip executable are available in the specified locations before running the script.

.LINK
https://github.com/yausername2/CrowdStrike-RTR-Scripts/blob/main/Scripts/run_browsingHistoryView.ps1

#>

if (Test-Path -Path "$Env:PUBLIC\$Env:COMPUTERNAME")
{
    echo "Directory already exists. Proceeding..."
}
else
{
    echo "Creating directory..."
	New-Item -Path $Env:PUBLIC\$Env:COMPUTERNAME -ItemType Directory
}
# Please refer to https://www.nirsoft.net/utils/browsing_history_view.html for the BrowsingHistoryView
if (Test-Path -Path "$Env:PUBLIC\browsinghistoryview-x64.zip")
{
    # Please refer to https://github.com/yausername2/CrowdStrike-RTR-Scripts/blob/main/Resources/7za.exe for the standalone 7-Zip executable (7za.exe Version 24.09 x64)
	# or unpack it from the `extra` package provide by 7-Zip mantainers: https://github.com/ip7z/7zip/releases/download/24.09/7z2409-extra.7z
    if (Test-Path -Path "$Env:PUBLIC\7za.exe")
    {            
        if (Get-Process -Name 7za -ErrorAction SilentlyContinue)
        {
            Get-Process -Name 7za | kill
        }	
        Try{
            echo "Starting 7-Zip to extract files..."
            $pinfo = New-Object System.Diagnostics.ProcessStartInfo
            $pinfo.FileName = "$Env:PUBLIC\7za.exe"
            $pinfo.WorkingDirectory = "$Env:PUBLIC\HistoryView"
            $pinfo.Arguments = "x $ENV:PUBLIC\browsinghistoryview-x64.zip -aos -o$Env:PUBLIC\HistoryView"
            $p = New-Object System.Diagnostics.Process
            $p.StartInfo = $pinfo
            $p.Start() | Out-Null
            $p.WaitForExit()
            echo "Extraction completed successfully."
        }
        Catch
        {
            echo "An error occurred during extraction. Exiting..."
            exit
        }

        Try{
            echo "Starting BrowsingHistoryView..."
            $pinfo = New-Object System.Diagnostics.ProcessStartInfo
            $pinfo.FileName = "$Env:PUBLIC\HistoryView\BrowsingHistoryView.exe"
            $pinfo.Arguments = "/SaveDirect /HistorySource 1 /scomma $Env:PUBLIC\$Env:COMPUTERNAME\history.csv"
            $p = New-Object System.Diagnostics.Process
            $p.StartInfo = $pinfo
            $p.Start() | Out-Null
            $p.WaitForExit()
            echo "BrowsingHistoryView completed successfully."
        }
        Catch{
            echo "An error occurred while starting BrowsingHistoryView. Exiting..."
            exit
        }

        Try{
            echo "Starting 7-Zip to compress files with password..."
            $pinfo = New-Object System.Diagnostics.ProcessStartInfo
            $pinfo.FileName = "$Env:PUBLIC\7za.exe"
            $pinfo.WorkingDirectory = "$Env:PUBLIC\$Env:COMPUTERNAME"
            $pinfo.Arguments = "a $Env:PUBLIC\$Env:COMPUTERNAME\history.zip $Env:PUBLIC\$Env:COMPUTERNAME\history.csv -pYOUR_PASSWORD"
            $p = New-Object System.Diagnostics.Process
            $p.StartInfo = $pinfo
            $p.Start() | Out-Null
            $p.WaitForExit()
            echo "Compression completed successfully."
        }
        Catch{
            echo "An error occurred during compression. Exiting..."
            exit
        }

        if (Test-Path -Path "$Env:PUBLIC\$Env:COMPUTERNAME\history.csv"){
            Remove-Item -Path "$Env:PUBLIC\$Env:COMPUTERNAME\history.csv" -Verbose 
        }
        if (Test-Path -Path "$Env:PUBLIC\7za.exe"){
            Remove-Item -Path "$Env:PUBLIC\7za.exe" -Verbose 
        }
        if (Test-Path -Path "$Env:PUBLIC\browsinghistoryview-x64.zip"){
            Remove-Item -Path "$Env:PUBLIC\browsinghistoryview-x64.zip" -Verbose 
        }
        if (Test-Path -Path "$Env:PUBLIC\HistoryView"){
            Remove-Item -Path "$Env:PUBLIC\HistoryView" -Recurse -Verbose 
        }
    }
    else
    {
        echo "7-Zip executable not found. Exiting..."
        exit
    }
}
else
{
	echo "BrowsingHistoryView archive not found. Exiting..."
	exit
}