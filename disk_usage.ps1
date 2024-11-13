# Function to get the folder size for each directory
function Get-FolderSize {
    param (
        [string]$folderPath
    )

    # Get all files in the folder and subfolders recursively
    $folderSize = 0
    try {
        $files = Get-ChildItem -Path $folderPath -Recurse -File -ErrorAction SilentlyContinue
        $folderSize = ($files | Measure-Object -Property Length -Sum).Sum
    }
    catch {
        Write-Warning "Failed to access $folderPath"
    }
    return $folderSize
}

# Function to get folder sizes and display as tree structure
function Get-DiskUsageReport {
    param (
        [string]$driveLetter
    )
    
    # Initialize an array to store folder data
    $report = @()
    
    # Get all top-level directories in the drive
    $topLevelDirs = Get-ChildItem -Path $driveLetter -Directory -ErrorAction SilentlyContinue

    foreach ($dir in $topLevelDirs) {
        # Get the folder size for each top-level directory
        $folderSize = Get-FolderSize -folderPath $dir.FullName
        $folderSizeGB = [math]::round($folderSize / 1GB, 2)
        
        # Create a custom object for the folder and its size
        $report += [PSCustomObject]@{
            DriveLetter = $driveLetter
            FolderPath = $dir.FullName
            SizeGB = $folderSizeGB
        }
        
        # Now scan for subfolders recursively
        Get-SubfolderSize -folderPath $dir.FullName -report $report
    }

    # Return the accumulated report
    return $report
}

# Function to get subfolder sizes recursively
function Get-SubfolderSize {
    param (
        [string]$folderPath,
        [ref]$report
    )

    try {
        $subfolders = Get-ChildItem -Path $folderPath -Directory -ErrorAction SilentlyContinue
        
        foreach ($subfolder in $subfolders) {
            $folderSize = Get-FolderSize -folderPath $subfolder.FullName
            $folderSizeGB = [math]::round($folderSize / 1GB, 2)
            
            # Add the subfolder data to the report
            $report.Value += [PSCustomObject]@{
                DriveLetter = (Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -eq $folderPath.Substring(0, 3) }).Name
                FolderPath = $subfolder.FullName
                SizeGB = $folderSizeGB
            }
            
            # Recursively get subfolder sizes
            Get-SubfolderSize -folderPath $subfolder.FullName -report $report
        }
    }
    catch {
        Write-Warning "Failed to access $folderPath"
    }
}

# Initialize an array to store all reports
$allReports = @()

# Get all drives (excluding CD/DVD/Removable drives)
$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.DisplayRoot -ne $null }

# Run disk usage report for each drive and collect results
foreach ($drive in $drives) {
    $driveLetter = $drive.Name + ":\"
    $driveReport = Get-DiskUsageReport -driveLetter $driveLetter
    
    # Append the report for this drive to the overall collection
    $allReports += $driveReport
}

# Specify the path for the CSV file export
$csvFilePath = "C:\DriveUsageReport.csv"

# Export the collected report to CSV
$allReports | Export-Csv -Path $csvFilePath -NoTypeInformation

# Output to indicate that the report has been generated
Write-Host "Disk usage report has been exported to $csvFilePath" -ForegroundColor Green
