Add-Type -AssemblyName System.Windows.Forms

function Get-FolderPath($description) {
    $folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowserDialog.Description = $description
    $folderBrowserDialog.ShowDialog() | Out-Null
    return $folderBrowserDialog.SelectedPath
}

function Install-ClamAV {
    Write-Host "Installing ClamAV for Windows..."
    $clamavDownloadPageUrl = "https://www.clamav.net/downloads"
    $downloadPageContent = Invoke-WebRequest -Uri $clamavDownloadPageUrl
    $clamavInstallerUrl = ($downloadPageContent -split "`n" -match 'production/clamav.*win-x64-portable\.zip')[0] -replace '.*="(.*)".*', '$1'
    $outputPath = "$env:TEMP\clamav.zip"
    Invoke-WebRequest -Uri $clamavInstallerUrl -OutFile $outputPath
    Expand-Archive -Path $outputPath -DestinationPath "$env:ProgramFiles\ClamAV"
}


function Test-ClamAVInstalled {
    Write-Host "Checking for ClamAV..."
    return (Get-Command "$env:ProgramFiles\ClamAV\clamscan.exe" -ErrorAction SilentlyContinue)
}

if (-not (Test-ClamAVInstalled)) {
    Install-ClamAV
}

function Update-ClamAVDatabase {
    Write-Host "Updating ClamAV virus database..."
    $freshClamExe = "$env:ProgramFiles\ClamAV\freshclam.exe"
    & $freshClamExe
}

# Ask the user if they want to update the ClamAV virus database
$updateChoice = Read-Host "Do you want to update the ClamAV virus database before scanning? [y/N]"

if ($updateChoice -eq "y" -or $updateChoice -eq "Y") {
    Update-ClamAVDatabase
}

$folderToScan = Get-FolderPath "Select folder to scan"
$logSaveLocation = Get-FolderPath "Select where to save log"

$clamScanExe = "$env:ProgramFiles\ClamAV\clamscan.exe"
$arguments = @("-r", "-i", "-v", $folderToScan)
$logFilePath = Join-Path -Path $logSaveLocation -ChildPath "clamscan.log"

& $clamScanExe $arguments *>&1 | Tee-Object -FilePath $logFilePath

