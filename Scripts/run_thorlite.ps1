<#
.SYNOPSIS
This script is designed to run in CrowdStrike RTR (Real Time Response) or another EDR (Endpoint Detection and Response) RTR module to perform a 'Thor Lite' scan for analysis.

.DESCRIPTION
The script performs a scan with 'Thor Lite' utility. It ensures that necessary directories and files are created, extracts necessary tools and executes commands to collect data for further analysis.

.NOTES
Ensure that the Thor Lite archive and 7-Zip executable (if needed) are available in the specified locations before running the script.

.LINK
https://github.com/yausername2/CrowdStrike-RTR-Scripts/blob/main/Scripts/run_thorlite.ps1

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
if ( -not (Test-Path -Path "$Env:PUBLIC\$Env:COMPUTERNAME\#ToDoList_$Env:COMPUTERNAME.txt" -PathType Leaf))
{
    echo "Creating a To-Do list file..."
    echo "#write here the things to do#" > $Env:PUBLIC\$Env:COMPUTERNAME\#ToDoList_$Env:COMPUTERNAME.txt
}

echo ""
# Please refer to https://www.nextron-systems.com/thor-lite/ for the Thor Lite executable
if (Test-Path -Path "$Env:PUBLIC\thor-lite-win.zip")
{
    if($PSVersionTable.PSVersion.Major -lt 5)
    {
        echo "PowerShell version is outdated..."
        echo "Attempting to proceed..."
		# Please refer to https://github.com/yausername2/CrowdStrike-RTR-Scripts/blob/main/Resources/7za.exe for the standalone 7-Zip executable (7za.exe Version 24.09 x64)
		# or unpack it from the `extra` package provide by 7-Zip mantainers: https://github.com/ip7z/7zip/releases/download/24.09/7z2409-extra.7z
		if (Test-Path -Path "$Env:PUBLIC\7za.exe")
		{
            if (Get-Process -Name 7za -ErrorAction SilentlyContinue)
            {
                Get-Process -Name 7za | kill
            }
            
            Try 
            {
                echo "Starting 7-Zip to extract files..."
                $pinfo = New-Object System.Diagnostics.ProcessStartInfo
                $pinfo.FileName = "$Env:PUBLIC\7za.exe"
                $pinfo.WorkingDirectory = "$Env:PUBLIC"
                $pinfo.Arguments = "x $ENV:PUBLIC\thor-lite-win.zip -aos -o$Env:PUBLIC\thor-lite-win"
                $pinfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
                $p = New-Object System.Diagnostics.Process
                $p.StartInfo = $pinfo
                $p.Start() | Out-Null
                $p.WaitForExit()
                echo "[+] Extraction completed successfully."
            }
            Catch
            {
                echo "[-] An error occurred during extraction. Exiting..."
                exit
            }
        }
        else
        {
            echo "[-] 7-Zip executable not found. Exiting..."
            exit
        }
    }
    else
    {
        Expand-Archive -LiteralPath $Env:PUBLIC\thor-lite-win.zip -DestinationPath $Env:PUBLIC\thor-lite-win -Force
        echo "[+] Extraction completed successfully."
    }
}
else
{
    echo "[-] Thor Lite archive not found. Exiting..."
    exit
}

echo ""
Try
{
    echo "Starting Thor Lite scan..."
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = "$Env:PUBLIC\thor-lite-win\thor64-lite.exe"
    $pinfo.WorkingDirectory = "$env:PUBLIC\$env:COMPUTERNAME"
    $pinfo.Arguments = "--allhds --allreasons"
    $pinfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    echo "Thor Lite scan started successfully."
    $p.WaitForExit()
    echo "[+] Scan completed."
}
Catch
{
    echo "[-] An error occurred while starting Thor Lite. Exiting..."				   
    exit
}