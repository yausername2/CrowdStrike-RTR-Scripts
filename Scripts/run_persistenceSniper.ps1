<#
.SYNOPSIS
This script is designed to run in CrowdStrike RTR (Real Time Response) or another EDR (Endpoint Detection and Response) RTR module to perform an 'PersistenceSniper' scan for analysis.

.DESCRIPTION
The script performs a scan with 'PersistenceSniper' module. It ensures that necessary directories and files are created, extracts necessary tools and executes commands to collect data for further analysis.

.NOTES
Ensure that the PersistenceSniper and 7-Zip executable (if needed) are available in the specified locations before running the script.
If necessary, set the execution policy by running: "Set-ExecutionPolicy RemoteSigned"

.LINK
https://github.com/yausername2/CrowdStrike-RTR-Scripts/blob/main/Scripts/run_persistenceSniper.ps1

#>

# Please refer to https://github.com/last-byte/PersistenceSniper/releases for the PersistenceSniper archive.
if (Test-Path -Path "$Env:PUBLIC\PersistenceSniper.zip")
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
				$pinfo.Arguments = "x $ENV:PUBLIC\PersistenceSniper.zip -aos -o$env:temp"
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
		Expand-Archive -path $Env:PUBLIC\PersistenceSniper.zip -destinationpath $env:temp -Force
        echo "[+] Extraction completed successfully."
    }
}
else
{
	echo "[-] PersistenceSniper archive not found. Exiting..."
	exit
}

Set-Location -Path $Env:temp

Import-Module $env:temp\PersistenceSniper\PersistenceSniper.psd1

if (Test-Path -Path "$Env:PUBLIC\$Env:COMPUTERNAME")
{
	echo "Directory already exists. Proceeding..."
}
else
{
	echo "Creating directory..."
	New-Item -Path $Env:PUBLIC\$Env:COMPUTERNAME -ItemType Directory
}

Find-AllPersistence > "$Env:PUBLIC\$Env:COMPUTERNAME\persistenceSniper_$Env:COMPUTERNAME.txt"
echo "[+] Scan completed."