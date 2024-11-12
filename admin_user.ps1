# Prompt for username and password
$username = Read-Host "Enter the username for the new admin account"
$password = Read-Host "Enter the password for the new admin account" -AsSecureString

# Create the new local user
New-LocalUser -Name $username -Password $password -FullName "Administrator User" -Description "New user with Administrator privileges"

# Add the new user to the Administrators group
Add-LocalGroupMember -Group "Administrators" -Member $username

# Output success message
Write-Host "User '$username' created and added to the Administrators group."
