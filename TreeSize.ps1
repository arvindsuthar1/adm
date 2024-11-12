# Set path to TreeSize executable
$treeSizePath = ".\TreeSizeFree-Portable\TreeSizeFree.exe"

# Set the output file path for CSV format
$outputFile = "C:\Temp\tree_size_output.csv"

# Run TreeSize to analyze the C: drive and export the result in CSV format
Start-Process -FilePath $treeSizePath -ArgumentList "C:\", "/Export $outputFile", "/CSV" -Wait

# Wait for the process to complete
Start-Sleep -Seconds 5

# Display the CSV output (optional)
Get-Content -Path $outputFile
