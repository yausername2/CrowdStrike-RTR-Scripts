if (Test-Path -Path "$Env:PUBLIC\$Env:COMPUTERNAME")
{
    echo "Directory already exists. Proceeding..."
}
else
{
    echo "Creating directory..."
	New-Item -Path $Env:PUBLIC\$Env:COMPUTERNAME -ItemType Directory
}
if (Test-Path -Path "$Env:PUBLIC\browsinghistoryview-x64.zip")
{
    if (Test-Path -Path "$Env:PUBLIC\7Zip.zip")
    {
	    if($PSVersionTable.PSVersion.Major -lt 5)
	    {
            echo "PowerShell version is outdated..."
            echo "Attempting to proceed..."
            $shell=new-object -com shell.application
            $targetpath=$Env:PUBLIC
            $location=$shell.namespace($targetpath)
            $zipFiles = get-childitem $Env:PUBLIC\7Zip.zip

            foreach($zipFile in $ZipFiles)
            {
                $zipFolder = $shell.namespace($zipFile.fullname)
                $location.Copyhere($zipFolder.items(), 0x14)
            }
        }
        else
        {
            Expand-Archive -LiteralPath $Env:PUBLIC\7Zip.zip -DestinationPath $Env:PUBLIC -Force
        }
        if ((Test-Path -Path "$Env:PUBLIC\7z.exe") -and (Test-Path -Path "$Env:PUBLIC\7z.dll"))
        {
            echo "7-zip extraction completed successfully."
            if (Get-Process -Name 7z -ErrorAction SilentlyContinue)
            {
                Get-Process -Name 7z | kill
            }	
            Try{
                echo "Starting 7-Zip to extract files..."
                $pinfo = New-Object System.Diagnostics.ProcessStartInfo
                $pinfo.FileName = "$Env:PUBLIC\7z.exe"
                $pinfo.WorkingDirectory = "$Env:PUBLIC\HistoryView"
                $pinfo.Arguments = "x $ENV:PUBLIC\browsinghistoryview-x64.zip -aos -o$Env:PUBLIC\HistoryView"
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

            Try{
                echo "Starting BrowsingHistoryView..."
                $pinfo = New-Object System.Diagnostics.ProcessStartInfo
                $pinfo.FileName = "$Env:PUBLIC\HistoryView\BrowsingHistoryView.exe"
                $pinfo.Arguments = "/SaveDirect /HistorySource 1 /scomma $Env:PUBLIC\$Env:COMPUTERNAME\history.csv"
                $p = New-Object System.Diagnostics.Process
                $p.StartInfo = $pinfo
                $p.Start() | Out-Null
                $p.WaitForExit()
                echo "BrowsingHistoryView completed successfully."
            }
            Catch{
                echo "An error occurred while starting BrowsingHistoryView. Exiting..."
                exit
            }

            Try{
                echo "Starting 7-Zip to compress files with password..."
                $pinfo = New-Object System.Diagnostics.ProcessStartInfo
                $pinfo.FileName = "$Env:PUBLIC\7z.exe"
                $pinfo.WorkingDirectory = "$Env:PUBLIC\$Env:COMPUTERNAME"
                $pinfo.Arguments = "a $Env:PUBLIC\$Env:COMPUTERNAME\history.zip $Env:PUBLIC\$Env:COMPUTERNAME\history.csv -pYOUR_PASSWORD"
                $p = New-Object System.Diagnostics.Process
                $p.StartInfo = $pinfo
                $p.Start() | Out-Null
                $p.WaitForExit()
                echo "Compression completed successfully."
            }
            Catch{
                echo "An error occurred during compression. Exiting..."
                exit
            }

            if (Test-Path -Path "$Env:PUBLIC\$Env:COMPUTERNAME\history.csv"){
                Remove-Item -Path "$Env:PUBLIC\$Env:COMPUTERNAME\history.csv" -Verbose 
            }
            if (Test-Path -Path "$Env:PUBLIC\7Zip.zip"){
                Remove-Item -Path "$Env:PUBLIC\7Zip.zip" -Verbose 
            }
            if (Test-Path -Path "$Env:PUBLIC\7z.exe"){
                Remove-Item -Path "$Env:PUBLIC\7z.exe" -Verbose 
            }
            if (Test-Path -Path "$Env:PUBLIC\7z.dll"){
                Remove-Item -Path "$Env:PUBLIC\7z.dll" -Verbose 
            }
            if (Test-Path -Path "$Env:PUBLIC\browsinghistoryview-x64.zip"){
                Remove-Item -Path "$Env:PUBLIC\browsinghistoryview-x64.zip" -Verbose 
            }
            if (Test-Path -Path "$Env:PUBLIC\HistoryView"){
                Remove-Item -Path "$Env:PUBLIC\HistoryView" -Recurse -Verbose 
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
	echo "BrowsingHistoryView archive not found. Exiting..."
	exit
}