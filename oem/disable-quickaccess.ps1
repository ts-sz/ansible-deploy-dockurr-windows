Write-Host "Disabling Quick Access..."

# Remove Quick Access from Explorer
Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -ErrorAction SilentlyContinue
Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HomeFolder" -ErrorAction SilentlyContinue
Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Favorites" -ErrorAction SilentlyContinue
Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\RecentPlaces" -ErrorAction SilentlyContinue

# Remove Quick Access from registry
Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{679f85cb-0220-4080-b29b-5540cc05aab6}\ShellFolder" -Name "Attributes" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{24ccb8a0-03a3-45c4-ae26-5a5255b5ad41}\ShellFolder" -Name "Attributes" -ErrorAction SilentlyContinue

Write-Host "Quick Access disabled."