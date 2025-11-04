<#
.SYNOPSIS
Setup and configure OpenSSH Server on Windows

.NOTES

    Author:     Magomed Gamadaev
    Date:       2024-11-04
    File Name:  setup-ssh-server.ps1

#>

$ErrorActionPreference = 'Stop'

# ============================================================================
# Configuration Variables
# ============================================================================

# SSH Server Port
$SSHPort = 34523

# SSH User (Administrator user)
$SSHUser = "sysadmin"

# URLs to fetch SSH public keys from (comma-separated)
$KeyUrls = @(
    "https://github.com/ts-sz.keys"
)

# IMPORTANT: Password authentication is enabled (set to 'yes')
# This allows both SSH key and password authentication
# Change to 'no' to disable password authentication for security
$PasswordAuthentication = "yes"

# ============================================================================
# Functions
# ============================================================================

# Function to fetch SSH keys from URLs
function Get-SSHKeysFromUrls {
    param([array]$Urls)
    
    $allKeys = @()
    
    foreach ($url in $Urls) {
        $url = $url.Trim()
        try {
            Write-Host "Fetching SSH keys from: $url"
            $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 30
            if ($response.StatusCode -eq 200) {
                $keys = $response.Content.Trim() -split "`n" | Where-Object { $_.Trim() -ne "" }
                $allKeys += $keys
                Write-Host "Successfully fetched $($keys.Count) keys from $url"
            }
        }
        catch {
            Write-Warning "Failed to fetch keys from $url : $($_.Exception.Message)"
        }
    }
    
    return $allKeys
}

# ============================================================================
# Main Script
# ============================================================================

Write-Host "Starting OpenSSH Server setup..."
Write-Host "SSH Port: $SSHPort"
Write-Host "SSH User: $SSHUser"
Write-Host "Password Authentication: $PasswordAuthentication"

# Fetch public keys from URLs
Write-Host "`nFetching SSH public keys..."
$publicKeysArray = Get-SSHKeysFromUrls -Urls $KeyUrls

if ($publicKeysArray.Count -eq 0) {
    throw "No SSH keys could be fetched from any of the provided URLs"
}

$publicKeys = $publicKeysArray -join "`r`n"
Write-Host "Total SSH keys fetched: $($publicKeysArray.Count)"

# Define paths
$sshConfigPath = "C:\ProgramData\ssh\sshd_config"
$adminAuthorizedKeysPath = "C:\ProgramData\ssh\administrators_authorized_keys"
$sshCapabilityName = "OpenSSH.Server~~~~0.0.1.0"

# Check if OpenSSH Server is installed and install if not
Write-Host "`nChecking OpenSSH Server installation..."
$sshFeature = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'

if ($sshFeature.State -ne 'Installed') {
    Write-Host "Installing OpenSSH Server..."
    Add-WindowsCapability -Online -Name $sshCapabilityName
    Write-Host "OpenSSH Server installed successfully"
} else {
    Write-Host "OpenSSH Server is already installed"
}

# Ensure OpenSSH Server service is running and set to start automatically
Write-Host "`nConfiguring OpenSSH Server service..."
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
Write-Host "OpenSSH Server service configured"

# Backup the original sshd_config file
if (Test-Path $sshConfigPath) {
    Write-Host "`nBacking up sshd_config..."
    Copy-Item -Path $sshConfigPath -Destination "${sshConfigPath}.bak" -Force
}

# Update sshd_config to configure port and authentication
Write-Host "`nUpdating SSH configuration..."
$configLines = Get-Content $sshConfigPath

# Set custom port
$configLines = $configLines -replace '^[#\s]*Port\s+\d+', "Port $SSHPort"

# Set password authentication (IMPORTANT: Currently set to 'yes')
$configLines = $configLines -replace '^[#\s]*PasswordAuthentication\s+\w+', "PasswordAuthentication $PasswordAuthentication"

# Ensure PubkeyAuthentication is enabled
$configLines = $configLines -replace '^[#\s]*PubkeyAuthentication\s+\w+', 'PubkeyAuthentication yes'

# Save the updated configuration
$configLines | Set-Content $sshConfigPath
Write-Host "SSH configuration updated"

# Restart the OpenSSH Server to apply configuration changes
Write-Host "`nRestarting SSH service..."
Restart-Service sshd

# Ensure the .ssh directory exists
$sshDir = [System.IO.Path]::GetDirectoryName($adminAuthorizedKeysPath)
if (!(Test-Path -Path $sshDir)) {
    Write-Host "Creating SSH directory: $sshDir"
    New-Item -Path $sshDir -ItemType Directory -Force
}

# Ensure the authorized_keys file exists
if (!(Test-Path -Path $adminAuthorizedKeysPath)) {
    Write-Host "Creating authorized_keys file"
    New-Item -Path $adminAuthorizedKeysPath -ItemType File -Force
}

# Write the public keys to the file
Write-Host "`nWriting public keys to authorized_keys..."
$publicKeys | Set-Content -Path $adminAuthorizedKeysPath

# Set the correct permissions using SID for universal compatibility
Write-Host "Setting file permissions..."
icacls $adminAuthorizedKeysPath /inheritance:r | Out-Null
icacls $adminAuthorizedKeysPath /grant "SYSTEM:F" | Out-Null
icacls $adminAuthorizedKeysPath /grant "*S-1-5-32-544:F" | Out-Null  # SID for Administrators group

# Add Match Group configuration for administrators and specific user
Write-Host "Adding Match Group configuration..."
@"

Match Group *S-1-5-32-544
       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys

Match User $SSHUser
       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
"@ | Add-Content $sshConfigPath

# Restart SSH to apply changes
Write-Host "`nRestarting SSH service to apply all changes..."
Restart-Service sshd

# Configure Windows Firewall
Write-Host "`nConfiguring Windows Firewall..."
try {
    # Check if rule already exists
    $existingRule = Get-NetFirewallRule -DisplayName "OpenSSH Server Port $SSHPort" -ErrorAction SilentlyContinue
    
    if ($existingRule) {
        Write-Host "Firewall rule already exists, updating..."
        Set-NetFirewallRule -DisplayName "OpenSSH Server Port $SSHPort" -Direction Inbound -Action Allow -Protocol TCP -LocalPort $SSHPort
    } else {
        Write-Host "Creating new firewall rule..."
        New-NetFirewallRule -DisplayName "OpenSSH Server Port $SSHPort" -Direction Inbound -Action Allow -Protocol TCP -LocalPort $SSHPort | Out-Null
    }
    Write-Host "Firewall rule configured successfully"
}
catch {
    Write-Warning "Failed to configure firewall rule: $($_.Exception.Message)"
}

Write-Host "`n============================================================================"
Write-Host "OpenSSH Server setup completed successfully!"
Write-Host "============================================================================"
Write-Host "SSH Port: $SSHPort"
Write-Host "SSH User: $SSHUser"
Write-Host "Password Authentication: $PasswordAuthentication"
Write-Host "Public keys added: $($publicKeysArray.Count)"
Write-Host "Authorized keys file: $adminAuthorizedKeysPath"
Write-Host "SSH config file: $sshConfigPath"
Write-Host "Using universal SID S-1-5-32-544 for Administrators group compatibility"
Write-Host "============================================================================"
