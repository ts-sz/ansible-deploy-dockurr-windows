# by strategic Zone
Write-Host "Remove the winsxs cache"
# source: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/clean-up-the-winsxs-folder#dismexe
# use dism to cleanup windows sxs. This only works on 2012r2 and 8.1 and above. 
# bumped up to windows 10 only as was failing on 2012r2
if ([Environment]::OSVersion.Version -ge [Version]"10.0") {
    Write-Host "Cleaning up winSXS with dism"
    dism /online /cleanup-image /startcomponentcleanup /resetbase /quiet
}

Write-Host "Cleaning Temp Files..."
try {
    @(
        "C:\Recovery",
        "$env:localappdata\temp\*",
        "$env:windir\temp\*",
        "$env:windir\logs",
        "$env:windir\winsxs\manifestcache",
        "C:\Users\sysadmin\Favorites\*"
    ) | ForEach-Object {
        if (Test-Path $_) {
            Write-Host "Removing $_"
            try {
                Takeown /d Y /R /f $_
                Icacls $_ /GRANT:r administrators:F /T /c /q 2>&1 | Out-Null
                Remove-Item $_ -Recurse -Force | Out-Null
            } catch {
                $global:error.RemoveAt(0)
            }
        }
    }
} catch { }

Write-Host "Deleting Delivery Optimization cache"
# source: https://docs.microsoft.com/en-us/windows/deployment/update/waas-delivery-optimization-setup#manage-the-delivery-optimization-cache
delete-DeliveryOptimizationCache -Force

Write-Host "Optimizing Drive"
# source: https://docs.microsoft.com/en-us/powershell/module/storage/optimize-volume?view=win10-ps#description
Optimize-Volume -DriveLetter C -Analyze -SlabConsolidate -Retrim

Write-Host "Cleaning all event logs"
# source: cookbooks\packer\recipes\cleanup.rb
wevtutil clear-log Application
wevtutil clear-log Security
wevtutil clear-log Setup
wevtutil clear-log System

# Stops the windows update service.  
Stop-Service -Name wuauserv -Force -EA 0
Get-Service -Name wuauserv

# Delete the contents of windows software distribution.
Write-Host "Delete the contents of windows software distribution"
Get-ChildItem "C:\Windows\SoftwareDistribution\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

# Delete the contents of localuser apps.
Write-Host "Delete the contents of localuser apps"
Get-ChildItem "C:\users\localuser\AppData\Local\Packages\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

# Delete the contents of user template desktop.
Write-Host "Delete the contents of user template desktop"
Get-ChildItem "C:\Users\Public\Desktop\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

# Starts the Windows Update Service 
Start-Service -Name wuauserv -EA 0

# # Install ultradefrag and SDelete
# choco install --force --yes sdelete ultradefrag

# Write-Host "Starting to Defragment Disk"
# Start-Process -FilePath 'udefrag.exe' -ArgumentList '--optimize --repeat C:' -Wait -Verb RunAs

# Write-Host "Starting to Zero blocks"
# Start-Process -FilePath 'sdelete64.exe' -ArgumentList '-q -z C:' -Wait -EA 0

# # Remove
# choco uninstall --force --yes sdelete ultradefrag

Exit 0
