<#
.SYNOPSIS
This script is designed to run in CrowdStrike RTR (Real Time Response) or another EDR (Endpoint Detection and Response) RTR module to remove tools, files and folders deployed during an investigation.

.DESCRIPTION
The script deletes specific files and directories commonly used for forensic analysis from the '$Env:PUBLIC' directory, helping to clean up artifacts left after incident response activities.

.LINK
https://github.com/yausername2/CrowdStrike-RTR-Scripts/blob/main/Scripts/flush_tools.ps1
#>

# Files to remove
$files = @(
	"$Env:PUBLIC\$Env:COMPUTERNAME.zip",
	"$Env:PUBLIC\SysinternalsSuite.zip",
	"$Env:PUBLIC\thor-lite-win.zip",
	"$Env:PUBLIC\7za.exe",
    "$Env:PUBLIC\browsinghistoryview-x64.zip",
	"$Env:PUBLIC\Kape.zip",
)

foreach ($file in $files) {
	if (Test-Path -Path $file) {
		Remove-Item -Path $file -Verbose
	}
}

# Folders to remove
$folders = @(
	"$Env:PUBLIC\$Env:COMPUTERNAME",
	"$Env:PUBLIC\SysinternalsSuite",
	"$Env:PUBLIC\thor-lite-win",
	"$Env:PUBLIC\HistoryView",
	"$Env:PUBLIC\Kape",
)

foreach ($folder in $folders) {
	if (Test-Path -Path $folder) {
		Remove-Item -Path $folder -Recurse -Verbose -Force
	}
}
