<#
.SYNOPSIS
This script is designed to run in CrowdStrike RTR (Real Time Response) or another EDR (Endpoint Detection and Response) RTR module to collect system information and perform a 'Thor Lite' scan for analysis.

.DESCRIPTION
The script automates the collection of various system artifacts, including process information, service details, installed software, scheduled tasks, and performs a scan with 'Thor Lite' utility. It ensures that necessary directories and files are created, extracts necessary tools and executes commands to collect data for further analysis.

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
# Please refer to https://www.nextron-systems.com/thor-lite/ for the Thor Lite
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
                $pinfo.WorkingDirectory = "$Env:PUBLIC\thor-lite-win"
                $pinfo.Arguments = "x $ENV:PUBLIC\thor-lite-win.zip -aos -o$Env:PUBLIC\thor-lite-win"
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
        }
        else
        {
            echo "7-Zip executable not found. Exiting..."
            exit
        }
    }
    else
    {
        Expand-Archive -LiteralPath $Env:PUBLIC\thor-lite-win.zip -DestinationPath $Env:PUBLIC\thor-lite-win -Force
        echo "Extraction completed successfully."
    }
}
else
{
    echo "Thor-Lite archive not found. Exiting..."
    exit
}

echo "Collecting process information..."
Get-CimInstance -ClassName Win32_Process | Select ProcessName, CreationDate, ProcessId, CommandLine | Format-Table | Out-File -Width 9999 -Encoding utf8 $env:PUBLIC\$env:COMPUTERNAME\ps_$env:COMPUTERNAME.txt
echo "[+] Done."
echo "Collecting service information..."
Get-CimInstance -ClassName win32_service | Select Name, DisplayName, ProcessId, PathName, State, StartMode | Format-Table | Out-File -Width 9999 -Encoding utf8 $env:PUBLIC\$env:COMPUTERNAME\srvc_$env:COMPUTERNAME.txt
echo "[+] Done."
echo "Collecting installed software information..."
Get-Package -Provider Programs, msi -Force | select Name, Version, ProviderName | Out-File -Width 9999 -Encoding utf8 $env:PUBLIC\$env:COMPUTERNAME\softw_$env:COMPUTERNAME.txt
echo "[+] Done."
echo "Collecting scheduled tasks information..."
schtasks.exe /QUERY /V /FO LIST | Select-String "TaskName:", "Task To Run:", "Scheduled Task State:", "Next Run Time:", "Last Run Time:", "Run As User:", "Schedule Type:" | ForEach-Object { if ($i % 7 -eq 0) { "`n", $_ } else { $_ } $i++ } | Out-File -Width 9999 -Encoding utf8 $env:PUBLIC\$env:COMPUTERNAME\schedt_$env:COMPUTERNAME.txt
echo "[+] Done."

Try
{
    echo "Starting Thor-Lite scan..."
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = "$Env:PUBLIC\thor-lite-win\thor64-lite.exe"
    $pinfo.Arguments = "--allhds --allreasons"
    $pinfo.WorkingDirectory = "$env:PUBLIC\$env:COMPUTERNAME"
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    echo "Thor-Lite scan started successfully."
    $p.WaitForExit()
}
Catch
{
    echo "An error occurred while starting Thor-Lite. Exiting..."				   
    exit
}