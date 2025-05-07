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
if (Test-Path -Path "$Env:PUBLIC\SysinternalsSuite.zip")
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
				$pinfo.WorkingDirectory = "$Env:PUBLIC\SysinternalsSuite"
				$pinfo.Arguments = "x $ENV:PUBLIC\SysinternalsSuite.zip -aos -o$Env:PUBLIC\SysinternalsSuite"
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
		Expand-Archive -LiteralPath $Env:PUBLIC\SysinternalsSuite.zip -DestinationPath $Env:PUBLIC\SysinternalsSuite -Force
        echo "Extraction completed successfully."
    }
}
else
{
	echo "Sysinternals archive not found. Exiting..."
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
	echo "Starting AutorunsC scan..."
	$pinfo = New-Object System.Diagnostics.ProcessStartInfo
	$pinfo.FileName = "$Env:PUBLIC\SysinternalsSuite\autorunsc64.exe"
	$pinfo.Arguments = "-a * -accepteula -h -v -vt -s -o $Env:PUBLIC\$Env:COMPUTERNAME\autor_log_$Env:COMPUTERNAME.txt"
	$p = New-Object System.Diagnostics.Process
	$p.StartInfo = $pinfo
	$p.Start() | Out-Null
	echo "AutorunsC scan started successfully."
	$p.WaitForExit()
}
Catch 
{
    echo "An error occurred while starting AutorunsC. Exiting..."				   
    exit
}