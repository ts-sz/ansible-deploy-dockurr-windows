<#
.SYNOPSIS
Removes default apps from Windows

.NOTES

    Author:     Magomed Gamadaev
    Date:       2024-11-25
    File Name:  remove-default-apps-v2.ps1

#>

Import-Module Appx
Import-Module Dism

# Remove Notepad++
Get-AppxPackage -AllUsers *NotepadPlusPlus* | Remove-AppxPackage
Get-AppxPackage *NotepadPlusPlus* | Remove-AppxPackage

# Get all packages  Where PublisherId -eq 8wekyb3d8bbwe and remove them
Get-AppxPackage -AllUsers | Where PublisherId -eq 8wekyb3d8bbwe | Remove-AppxPackage

# Get all packages from DISM
$packages = dism /online /get-packages

# Filter packages containing 'handwriting'
$targetPackages = $packages -split "`r`n" | Where-Object { $_ -like "*handwriting*" }

# Extract package names
$packageNames = $targetPackages | ForEach-Object {
    if ($_ -match "Package Identity : (?<name>.*)") {
        $Matches.name.trim()
    }
}

# Remove each identified package
foreach ($pkg in $packageNames) {
    if ($pkg) {
        Write-Host "Removing package: $pkg"
        dism /online /remove-package /packagename:$pkg /NoRestart
    }
}

Write-Host "Done removing packages."
