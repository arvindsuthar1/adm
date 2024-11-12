act as devops engineer and create powershell script to enable connection for ansible on public network with -skipnetwork profilecheck

To enable PowerShell script execution and allow remote commands on your system, you'll need to adjust the PowerShell execution policy and configure remote management settings.

### 1. **Enable PowerShell Script Execution**

PowerShell has an execution policy that determines which scripts are allowed to run. By default, it is often set to `Restricted`, which blocks all scripts. To enable script execution, follow these steps:

#### a. **Change the Execution Policy**
- Open **PowerShell** as Administrator (right-click the PowerShell icon and select **Run as Administrator**).
- To check the current execution policy, run:
  ```powershell
  Get-ExecutionPolicy
  ```

- To change the policy to allow script execution, run the following command:
  ```powershell
  Set-ExecutionPolicy RemoteSigned
  ```
  - `RemoteSigned` allows locally created scripts to run, while requiring scripts downloaded from the internet to be signed by a trusted publisher.

  **Other execution policy options**:
  - `Restricted`: Default policy, no scripts can be run.
  - `AllSigned`: All scripts must be signed by a trusted publisher.
  - `Unrestricted`: Allows all scripts to run (not recommended for production environments).

- Confirm the change when prompted by typing `Y` (yes) or `A` (yes to all).

#### b. **Allow Remote Script Execution**
If you plan to run remote PowerShell scripts (for example, via PowerShell Remoting), you will need to ensure remoting is enabled.

### 2. **Enable PowerShell Remoting**

PowerShell Remoting allows you to run commands on remote computers. You must enable it on both the local and remote machines. Here's how to do that:

#### a. **Enable Remoting on Local/Remote Machine**
On both the local and remote machine, open **PowerShell as Administrator** and run:
```powershell
Enable-PSRemoting -Force
```
This will:
- Start the WinRM (Windows Remote Management) service.
- Set the service to start automatically.
- Configure the firewall to allow remote PowerShell commands.

#### b. **Verify Remoting is Enabled**
Run the following command to check the status of remoting:
```powershell
Get-Service WinRM
```
The `WinRM` service should be running on both machines.

#### c. **Configure Trusted Hosts (if needed)**
If you are remoting to a machine that is not part of the same domain or a trusted network, you may need to configure trusted hosts.

- To allow remoting to any computer, run:
  ```powershell
  Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
  ```

  (Be cautious using `"*"` in production environments. It allows all machines to connect to your system.)

  You can specify individual computers instead of `*`, for example:
  ```powershell
  Set-Item WSMan:\localhost\Client\TrustedHosts -Value "remote-computer-name" -Force
  ```

#### d. **Test Remote Connectivity**
Once remoting is enabled and the firewall is configured, test the connection by running the following command from the local machine:
```powershell
Test-WSMan remote-computer-name
```
This command will verify if you can connect to the remote machine.

### 3. **Running Remote Commands**

Once remoting is set up, you can run commands on a remote computer using the `Invoke-Command` cmdlet:

#### Example:
```powershell
Invoke-Command -ComputerName remote-computer-name -ScriptBlock {
    Get-Process
} -Credential (Get-Credential)
```
This will prompt for the remote computer's credentials and then execute the `Get-Process` cmdlet on the remote system.

Alternatively, you can start a remote PowerShell session:
```powershell
Enter-PSSession -ComputerName remote-computer-name -Credential (Get-Credential)
```
This opens an interactive session on the remote machine where you can run commands directly.

### 4. **Allow Remote Desktop (if necessary)**

If you want to run scripts or commands with a GUI interface (like Remote Desktop), you'll need to ensure Remote Desktop is enabled on the remote machine:

- Open **System Properties** → **Remote** → Check "Allow remote connections to this computer".
- Ensure the appropriate firewall ports (TCP 3389) are open on the remote machine.

---

By following these steps, you'll be able to run PowerShell scripts locally and remotely. Always be cautious when enabling remoting and running scripts to avoid security vulnerabilities.
