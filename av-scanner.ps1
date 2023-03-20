Add-Type -AssemblyName System.Windows.Forms

function Get-FolderPath($description) {
    $folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowserDialog.Description = $description
    $folderBrowserDialog.ShowDialog() | Out-Null
    return $folderBrowserDialog.SelectedPath
}

function Install-ClamAV {
    Write-Host "Installing ClamAV for Windows..."
    $clamavInstallerUrl = "https://www.clamav.net/downloads/production/clamav-0.103.3-win-x64-portable.zip"
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

$folderToScan = Get-FolderPath "Select folder to scan"
$logSaveLocation = Get-FolderPath "Select where to save log"

$clamScanExe = "$env:ProgramFiles\ClamAV\clamscan.exe"
$arguments = @("-r", "-i", "-v", $folderToScan)
$logFilePath = Join-Path -Path $logSaveLocation -ChildPath "clamscan.log"

& $clamScanExe $arguments *>&1 | Tee-Object -FilePath $logFilePath
