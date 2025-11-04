Function DisableXboxFeatures {
  Write-Host "Disabling Xbox features..."
  Get-AppxPackage "Microsoft.XboxApp" | Remove-AppxPackage
  Get-AppxPackage "Microsoft.XboxIdentityProvider" | Remove-AppxPackage
  Get-AppxPackage "Microsoft.XboxSpeechToTextOverlay" | Remove-AppxPackage
  Get-AppxPackage "Microsoft.XboxGameOverlay" | Remove-AppxPackage
  Get-AppxPackage "Microsoft.Xbox.TCUI" | Remove-AppxPackage
  Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0
  If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR")) {
      New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" | Out-Null
  }
  Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0
}

# Call the function
DisableXboxFeatures
