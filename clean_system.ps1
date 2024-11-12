# Define function to remove temporary files
function Remove-TemporaryFiles {
    Write-Host "Removing temporary files..."
    $tempPaths = @(
        "$env:TEMP\*",
        "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*",
        "$env:LOCALAPPDATA\Temp\*",
        "$env:APPDATA\Microsoft\Windows\Recent\*"
    )
    
    foreach ($path in $tempPaths) {
        try {
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Deleted: $path"
        } catch {
            Write-Host "Error deleting files from $path: $_"
        }
    }
}

# Clear Windows Update Files
function Remove-WindowsUpdateFiles {
    Write-Host "Removing old Windows update files..."
    try {
        # Run Disk Cleanup with arguments to clean up Windows Update files
        $cleanmgrArgs = "/sagerun:1"
        Start-Process "cleanmgr.exe" -ArgumentList $cleanmgrArgs -Wait
    } catch {
        Write-Host "Error clearing Windows update files: $_"
    }
}

# Clear Browser Cache for Chrome, Firefox, Edge
function Remove-BrowserCache {
    Write-Host "Clearing browser caches..."

    # Google Chrome
    $chromeCache = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*"
    if (Test-Path -Path $chromeCache) {
        Remove-Item -Path $chromeCache -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Cleared Chrome cache."
    }

    # Mozilla Firefox
    $firefoxCache = "$env:APPDATA\Mozilla\Firefox\Profiles\*\cache2\*"
    if (Test-Path -Path $firefoxCache) {
        Remove-Item -Path $firefoxCache -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Cleared Firefox cache."
    }

    # Microsoft Edge
    $edgeCache = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*"
    if (Test-Path -Path $edgeCache) {
        Remove-Item -Path $edgeCache -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Cleared Edge cache."
    }
}

# Empty Recycle Bin
function Empty-RecycleBin {
    Write-Host "Emptying Recycle Bin..."
    try {
        $shell = New-Object -ComObject Shell.Application
        $recycleBin = $shell.NameSpace('shell:::{645FF040-5081-101B-9F08-00AA002F954E}')
        $recycleBin.Items() | ForEach-Object { $_.InvokeVerb('delete') }
        Write-Host "Recycle Bin emptied."
    } catch {
        Write-Host "Error emptying Recycle Bin: $_"
    }
}

# Clear Event Logs (Optional, can be risky if you want to retain logs)
function Clear-EventLogs {
    Write-Host "Clearing event logs..."

    # Define the event log names to be cleared
    $logs = @('Application', 'System', 'Security', 'Setup', 'ForwardedEvents')

    foreach ($log in $logs) {
        try {
            Clear-EventLog -LogName $log
            Write-Host "Cleared log: $log"
        } catch {
            Write-Host "Error clearing event log $log: $_"
        }
    }
}

# Run all functions to clean up the system
function Clean-System {
    Remove-TemporaryFiles
    Remove-WindowsUpdateFiles
    Remove-BrowserCache
    Empty-RecycleBin
    Clear-EventLogs  # This step is optional and should be used carefully
}

# Main Script Execution
Write-Host "Starting system cleanup..."
Clean-System
Write-Host "System cleanup completed."
