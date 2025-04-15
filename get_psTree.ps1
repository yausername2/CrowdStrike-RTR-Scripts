function Get-PsTree {
    param(
        [switch]$OwnerInfo
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
