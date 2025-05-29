<#
.SYNOPSIS
This script is designed to run in CrowdStrike RTR (Real Time Response) or another EDR (Endpoint Detection and Response) RTR module to triage an endpoint with 'Kape' for analysis.

.DESCRIPTION
The script collects useful forensic artifacts with 'Kape' utility. It ensures that necessary directories and files are created, extracts necessary tools and executes commands to collect data for further analysis.

.NOTES
Ensure that the Kape archive and 7-Zip executable (if needed) are available in the specified locations before running the script.

.LINK
https://github.com/yausername2/CrowdStrike-RTR-Scripts/blob/main/Scripts/run_kape.ps1

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
# Please refer to https://www.kroll.com/en/insights/publications/cyber/kroll-artifact-parser-extractor-kape for the Kape executable
if (Test-Path -Path "$Env:PUBLIC\Kape.zip")
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
				$pinfo.Arguments = "x $ENV:PUBLIC\Kape.zip -aos -o$Env:PUBLIC\Kape"
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
		Expand-Archive -LiteralPath $Env:PUBLIC\Kape.zip -DestinationPath $Env:PUBLIC\Kape -Force
        echo "[+] Extraction completed successfully."
    }
}
else
{
	echo "[-] Kape archive not found. Exiting..."
	exit
}

echo ""
Try 
{
	echo "Starting Kape triage..."
	$pinfo = New-Object System.Diagnostics.ProcessStartInfo
	$pinfo.FileName = "$Env:PUBLIC\Kape\kape.exe"
    $pinfo.WorkingDirectory = "$Env:PUBLIC\Kape"
	$pinfo.Arguments = "--tsource C: --tdest $Env:PUBLIC\$Env:COMPUTERNAME\kape_triage\C --target RegistryHives,`$J,`$LogFile,`$MFT,Amcache,EventLogs,LNKFilesAndJumpLists,Prefetch,RegistryHivesUser,ScheduledTasks,StartupFolders,StartupInfo,USBDevicesLogs --mdest $Env:PUBLIC\$Env:COMPUTERNAME\kape_triage\artifacts --module SysInternals_PsList,SysInternals_PsTree,SysInternals_Tcpvcon,AmcacheParser,PECmd"
	$pinfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
	$p = New-Object System.Diagnostics.Process
	$p.StartInfo = $pinfo
	$p.Start() | Out-Null
	echo "Kape triage started successfully."
	$p.WaitForExit()
	echo "[+] Triage completed."
}
Catch 
{
    echo "[-] An error occurred while starting Kape. Exiting..."				   
    exit
}