@echo off
:: Set the new administrator username and password
set USERNAME=new_admin
set PASSWORD=your_secure_password

:: Step 1: Create a new local user account
echo Creating new user: %USERNAME%
net user %USERNAME% %PASSWORD% /add
if %errorlevel% neq 0 (
    echo Error creating user.
    exit /b 1
)

:: Step 2: Add the new user to the Administrators group
echo Adding %USERNAME% to Administrators group...
net localgroup Administrators %USERNAME% /add
if %errorlevel% neq 0 (
    echo Error adding user to Administrators group.
    exit /b 1
)

:: Step 3: Enable WinRM service (Windows Remote Management)
echo Enabling WinRM...
winrm quickconfig -q
if %errorlevel% neq 0 (
    echo Error enabling WinRM.
    exit /b 1
)

:: Step 4: Configure WinRM to accept unencrypted traffic (for Ansible compatibility)
echo Configuring WinRM to allow unencrypted traffic for Ansible...
winrm set winrm/config/service/Auth '@{Basic="true"}'
winrm set winrm/config/service/AllowUnencrypted "@{true='true'}"
if %errorlevel% neq 0 (
    echo Error configuring WinRM.
    exit /b 1
)

:: Step 5: Open the necessary firewall ports for WinRM (Public network)
echo Configuring firewall for WinRM (Public network)...
netsh advfirewall firewall set rule group="Windows Remote Management" new enable=yes profile=public
if %errorlevel% neq 0 (
    echo Error opening firewall for WinRM on Public network.
    exit /b 1
)

:: Step 6: Enable remote access for Ansible (specific for Windows)
echo Enabling Ansible-compatible remote access...
winrm set winrm/config/client '@{TrustedHosts="*"}'
if %errorlevel% neq 0 (
    echo Error configuring remote access.
    exit /b 1
)

:: Step 7: Allow inbound traffic for WinRM on Public network
echo Allowing inbound traffic on WinRM for Public network...
netsh advfirewall firewall add rule name="Allow WinRM (Public)" dir=in action=allow protocol=TCP localport=5985 profile=public
netsh advfirewall firewall add rule name="Allow WinRM (Public - HTTPS)" dir=in action=allow protocol=TCP localport=5986 profile=public
if %errorlevel% neq 0 (
    echo Error configuring inbound traffic for WinRM.
    exit /b 1
)

:: Completion message
echo Windows Administrator user '%USERNAME%' created successfully and WinRM configured for Ansible on Public network!
pause
exit /b 0
