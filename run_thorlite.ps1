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
if (Test-Path -Path "$Env:PUBLIC\thor-lite-win.zip")
{
    if($PSVersionTable.PSVersion.Major -lt 5)
    {
        echo "PowerShell version is outdated..."
        echo "Attempting to proceed..."
        if (Test-Path -Path "$Env:PUBLIC\7Zip.zip")
        {
            $shell=new-object -com shell.application
            $targetpath=$Env:PUBLIC
            $location=$shell.namespace($targetpath)
            $zipFiles = get-childitem $Env:PUBLIC\7Zip.zip

            foreach($zipFile in $ZipFiles)
            {
                $zipFolder = $shell.namespace($zipFile.fullname)
                $location.Copyhere($zipFolder.items(), 0x14)
            }
            if ((Test-Path -Path "$Env:PUBLIC\7z.exe") -and (Test-Path -Path "$Env:PUBLIC\7z.dll"))
            {
                if (Get-Process -Name 7z -ErrorAction SilentlyContinue)
                {
                    Get-Process -Name 7z | kill
                }
                
                Try 
                {
                    echo "Starting 7-Zip to extract files..."
                    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
                    $pinfo.FileName = "$Env:PUBLIC\7z.exe"
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
                echo "Required 7-Zip files are missing. Exiting..."
                exit
            }
        }
        else
        {
            echo "7-Zip archive not found. Exiting..."
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