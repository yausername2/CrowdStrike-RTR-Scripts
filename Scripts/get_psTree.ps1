<#
.SYNOPSIS
This script is designed to run in an automated, detection-triggered Endpoint Detection and Response (EDR) workflow to get a snapshot of the processes that are running.

.DESCRIPTION
The script generates a detailed hierarchical process tree that helps visualize the parent-child relationships of processes during workflows triggered by endpoint detections.

.LINK
https://github.com/yausername2/CrowdStrike-RTR-Scripts/blob/main/Scripts/get_psTree.ps1

#>

function Get-PsTree {
    param(
        [switch]$OwnerInfo,
        [int]$MaxDepth = 100  # Add a parameter for max recursion depth
    )

    Set-Variable -Name doneProc -Option AllScope
    Set-Variable -Name outVar -Option AllScope
    $outVar = @()
    $outVar += "[{0}]" -f $env:COMPUTERNAME

    $procs = Get-CimInstance -ClassName Win32_Process
    $doneProc = @()
    $groupped = $procs | Select-Object ParentProcessId, ProcessId, Name, CommandLine | Group-Object -Property ParentProcessId

    function PrintProcessLine {
        param (
            $process,
            $level
        )

        $tab = "`t" * $level
        $ownerData = "-"

        if ($OwnerInfo) {
            try {
                $ownerResult = Invoke-CimMethod -InputObject $process -MethodName GetOwner
            } catch {}

            if ($ownerResult.ReturnValue -eq 0 -and $ownerResult.User) {
                if ($ownerResult.Domain) {
                    $ownerData = "$($ownerResult.Domain)\$($ownerResult.User)"
                } else {
                    $ownerData = $ownerResult.User
                }
            }
        }

        $line = "$tab$($process.ProcessId): "
        if ($OwnerInfo) {
            $line += "[$ownerData] "
        }
        $line += "$($process.Name) $($process.CommandLine)"
        $outVar += $line
    }

    function PrintParentAndChildren {
        param (
            $currentProc,
            $currentLevel
        )

        # Prevent infinite or too deep recursion
        if ($currentLevel -gt $MaxDepth) {
            $outVar += ("`t" * ($currentLevel + 1)) + "[WARNING: Max recursion depth reached]"
            return
        }

        if ($currentProc.ProcessId -notin $doneProc) {
            $ProcessId = $currentProc.ProcessId
            PrintProcessLine $currentProc $currentLevel
            $doneProc += $ProcessId
        }

        $procs | Where-Object {
            $_.ParentProcessId -eq $currentProc.ProcessId -and $_.ProcessId -ne $currentProc.ProcessId
        } | ForEach-Object {
            PrintParentAndChildren $_ ($currentLevel + 1)
        }
    }

    # Start from top-level or orphan processes
    $procs | Where-Object {
        ($_.ParentProcessId -eq 0 -or $null -eq $_.ParentProcessId) -or ($_.ProcessId -in $groupped.Values)
    } | ForEach-Object {
        if ($_.ProcessId -notin $doneProc) {
            PrintParentAndChildren $_ 0
            $outVar += ""
        }
    }

    # Catch any missed processes
    $procs | Where-Object { $_.ProcessId -notin $doneProc } | ForEach-Object {
        PrintParentAndChildren $_ 0
        $outVar += ""
    }

    return $outVar -join "`n"
}

# Run and output the process tree
$output = Get-PsTree -OwnerInfo
$output
