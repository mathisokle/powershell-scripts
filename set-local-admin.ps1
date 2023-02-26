# Define the new username and password
$newUsername = "local-server-admin"
$newPassword = ConvertTo-SecureString "newpassword" -AsPlainText -Force

# Get the local administrator account
$adminAccount = Get-LocalUser -Name "Administrator"

# Rename the local administrator account
Rename-LocalUser -Name "Administrator" -NewName $newUsername

# Set the password for the renamed account
Set-LocalUser -Name $newUsername -Password $newPassword
