<#
.SYNOPSIS
This script is designed to run in CrowdStrike RTR (Real Time Response) to uninstalls the CrowdStrike Falcon agent using the CsUninstallTool.exe without exposing the maintenance token to the user.

.DESCRIPTION
The script performs the following steps:
1. Verifies the existence of the CsUninstallTool.exe in the public directory.
2. Updates the Access Control List (ACL) of the uninstall tool to remove protection.
3. Schedules the removal of the uninstall tool after execution by setting a RunOnce registry key.
4. Executes the uninstall tool with the provided maintenance token and runs it in quiet mode.

.NOTES
- Get the CsUninstallTool.exe from the CrowdStrike Falcon console > Support and resources > Tool downloads.
- Get the maintenance token from the CrowdStrike Falcon console > Host Management > Reveal maintenance token.
- Ensure that the CsUninstallTool.exe is placed in the public directory before running this script.
- The script requires administrative privileges to modify ACLs and registry keys.
- The maintenance token must be passed as an argument when executing the script.

.EXAMPLE
runscript -CloudFile="uninstall_CsRemote" -CommandLine="MAINTENANCE_TOKEN_HERE"

.LINK
https://github.com/yausername2/CrowdStrike-RTR-Scripts/blob/main/Scripts/uninstall_CsRemote.ps1

#>

# Ensure the file exists before proceeding
$uninstallToolPath = Join-Path $env:PUBLIC 'CsUninstallTool.exe'
if (-Not (Test-Path -Path $uninstallToolPath)) {
    echo "[!] Uninstall tool not found at $uninstallToolPath"
    exit
}

# Update ACL to remove protection
try {
    $acl = Get-Acl -Path $uninstallToolPath
    $acl.SetAccessRuleProtection($false, $false)
    $acl | Set-Acl -Path $uninstallToolPath
} catch {
    echo "[!] Failed to update ACL for $uninstallToolPath"
    exit
}

# Schedule removal of the uninstall tool after execution
try {
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" `
        -Name '!FlushCS' `
        -Value "c:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -NonInteractive -Command `"Remove-Item -Path $uninstallToolPath -Verbose`""
} catch {
    echo "[!] Failed to set RunOnce registry key"
    exit
}

# Attempt to start the uninstall tool
try {
    echo "Uninstalling CS Falcon..."
    $pInfo = New-Object System.Diagnostics.ProcessStartInfo
    $pInfo.FileName = $uninstallToolPath
    $pInfo.WorkingDirectory = $env:PUBLIC
    $pInfo.Arguments = "MAINTENANCE_TOKEN=$args /quiet"

    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pInfo
    $p.Start() | Out-Null

    $p.WaitForExit()
    echo "[+] Uninstall complete."
} catch {
    echo "[!] Failed to start or execute CsUninstallTool"
    exit
}