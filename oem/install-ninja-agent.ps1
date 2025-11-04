<#
.SYNOPSIS
Install NinjaOne RMM Agent

.NOTES

    Author:     Magomed Gamadaev
    Date:       2024-11-04
    File Name:  install-ninja-agent.ps1

#>

# NinjaOne Agent installer URL
$ID = "XXX"
$VERSION = "10.0.5096"
$NinjaInstallerUrl = "https://eu.ninjarmm.com/agent/installer/$ID/$VERSION/NinjaOne-Agent-StrategicZone-FR92HQ-Auto.msi"

Write-Host "Installing NinjaOne Agent silently..."

# Install directly from URL using MSIEXEC in silent mode
msiexec.exe /i "$NinjaInstallerUrl" /quiet

Write-Host "NinjaOne Agent installation completed"
