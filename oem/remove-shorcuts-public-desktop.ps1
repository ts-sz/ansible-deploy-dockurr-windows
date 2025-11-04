Write-Host "Removing shortcuts from the Public Desktop..."

$publicDesktopPath = [Environment]::GetFolderPath("CommonDesktopDirectory")

# Find and remove shortcuts from the Public Desktop
Get-ChildItem -Path $publicDesktopPath -Filter "*.lnk" | foreach {
    if (-not $_.PSIsContainer) {
        Remove-Item -Path $_.FullName -Force
    }
}
