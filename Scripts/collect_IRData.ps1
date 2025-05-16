<#
.SYNOPSIS
This script is designed to run in CrowdStrike RTR (Real Time Response) or another EDR (Endpoint Detection and Response) RTR module to performs a comprehensive data collection process to assist in incident response and forensic analysis.

.DESCRIPTION
The script collect system information, network details, running processes, services, scheduled tasks, installed software, and other relevant data for incident response purposes. It ensures necessary directories and files are created, gathers various system details, and outputs the collected data into organized files for further review.

.LINK
https://github.com/yausername2/CrowdStrike-RTR-Scripts/blob/main/Scripts/collect_IRData.ps1
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
# Function to collect system information
function Get-SystemInfo {
    echo "=== System Information ==="
    Get-ComputerInfo | Select-Object CsName, CsManufacturer, OsName, OSDisplayVersion, OsArchitecture, OsInstallDate, OsLastBootUpTime, OsLocale, TimeZone, CsBootupState
    echo ""
}

# Function to collect network adapters
function Get-NetworkAdapters {
    echo "=== Network Adapters ==="
    Get-NetAdapter | Select-Object ifIndex, Name, MacAddress, Status
    echo ""
}

# Function to collect listening ports
function Get-ListeningPorts {
    echo "=== Listening Ports ==="
    Get-NetTCPConnection -State Listen | Select-Object LocalAddress, LocalPort, OwningProcess
    echo ""
}

# Function to collect user sessions
function Get-UserSessions {
    echo "=== User Sessions ==="
    Get-WmiObject -Class Win32_ComputerSystem | Select-Object UserName, Domain
    echo ""
}

# Function to collect disk usage
function Get-DiskUsage {
    echo "=== Disk Usage ==="
    Get-PSDrive -PSProvider FileSystem | Select-Object Name, Used, Free, @{Name="UsedGB";Expression={[math]::Round($_.Used/1GB,2)}}, @{Name="FreeGB";Expression={[math]::Round($_.Free/1GB,2)}}
    echo ""
}

# Function to collect running processes
function Get-RunningProcesses {
    echo "=== Running Processes ==="
    Get-CimInstance -ClassName Win32_Process | 
        Select-Object ProcessName, CreationDate, ProcessId, CommandLine | Format-Table
}

# Function to collect network connections
function Get-NetworkConnections {
    echo "=== Network Connections ==="
    Get-NetTCPConnection | 
        Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess | Format-Table
}

# Function to collect services
function Get-Services {
    echo "=== Services ==="
    Get-CimInstance -ClassName Win32_Service | 
        Select-Object Name, DisplayName, ProcessId, PathName, State, StartMode | Format-Table
}

# Function to collect scheduled tasks
function Get-ScheduledTasks {
    echo "=== Scheduled Tasks ==="
    schtasks.exe /QUERY /V /FO LIST | 
        Select-String "TaskName:", "Task To Run:", "Scheduled Task State:", "Next Run Time:", "Last Run Time:", "Run As User:", "Schedule Type:" | 
        ForEach-Object { if ($i % 7 -eq 0) { "`n", $_ } else { $_ } $i++ }
}

# Function to collect installed software
function Get-InstalledSoftware {
    echo "=== Installed Software ==="
    Get-Package -Provider Programs, msi -Force | Select-Object Name, Version, ProviderName
}

$outputFile = "$Env:PUBLIC\$Env:COMPUTERNAME\_Report_$Env:COMPUTERNAME.txt"

echo "Starting Incident Response Data Collection..."
try {
    echo "Incident Response Report [$Env:COMPUTERNAME]" | Out-File -FilePath $outputFile
    echo "" | Out-File -FilePath $outputFile -Append
    Get-SystemInfo | Out-File -FilePath $outputFile -Append
    Get-NetworkAdapters | Out-File -FilePath $outputFile -Append
    Get-ListeningPorts | Out-File -FilePath $outputFile -Append
    Get-UserSessions | Out-File -FilePath $outputFile -Append
    Get-DiskUsage | Out-File -FilePath $outputFile -Append
} catch {
    echo "[-] Failed to collect data: $_"
}

try {
    echo "Collecting Running Processes..."
    Get-RunningProcesses | Out-File -Width 9999 -Encoding utf8 "$env:PUBLIC\$env:COMPUTERNAME\processes_$env:COMPUTERNAME.txt"
    echo "[+] Running Processes collected successfully."
} catch {
    echo "[-] Failed to collect Running Processes: $_"
}

try {
    echo "Collecting Network Connections..."
    Get-NetworkConnections | Out-File -Width 9999 -Encoding utf8 "$env:PUBLIC\$env:COMPUTERNAME\network_$env:COMPUTERNAME.txt"
    echo "[+] Network Connections collected successfully."
} catch {
    echo "[-] Failed to collect Network Connections: $_"
}

try {
    echo "Collecting Services..."
    Get-Services | Out-File -Width 9999 -Encoding utf8 "$env:PUBLIC\$env:COMPUTERNAME\services_$env:COMPUTERNAME.txt"
    echo "[+] Services collected successfully."
} catch {
    echo "[-] Failed to collect Services: $_"
}

try {
    echo "Collecting Scheduled Tasks..."
    Get-ScheduledTasks | Out-File -Width 9999 -Encoding utf8 "$env:PUBLIC\$env:COMPUTERNAME\schtasks_$env:COMPUTERNAME.txt"
    echo "[+] Scheduled Tasks collected successfully."
} catch {
    echo "[-] Failed to collect Scheduled Tasks: $_"
}

try {
    echo "Collecting Installed Software..."
    Get-InstalledSoftware | Out-File -Width 9999 -Encoding utf8 "$env:PUBLIC\$env:COMPUTERNAME\software_$env:COMPUTERNAME.txt"
    echo "[+] Installed Software collected successfully."
} catch {
    echo "[-] Failed to collect Installed Software: $_"
}

echo ""
echo ""
