# Use the folder where the script is located
$folder = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $folder

# Base URL for downloads
$baseUrl = "https://github.com/Brandon-T/Reflection/releases/download/autobuild/"

# Define the rename mappings
$renameMap = @{
    "libRemoteInput-i686.dll"        = "libremoteinput32.dll"
    "libRemoteInput-x86_64.dll"      = "libremoteinput64.dll"
    "libRemoteInput-x86_64.dylib"    = "libremoteinput64.dylib"
    "libRemoteInput-aarch64.dylib"   = "libremoteinput64.dylib.aarch64"
    "libRemoteInput-x86_64.so"       = "libremoteinput64.so"
    "libRemoteInput-aarch64.so"      = "libremoteinput64.so.aarch64"
}

# Download and rename each file
foreach ($oldName in $renameMap.Keys) {
    $newName = $renameMap[$oldName]
    $url = "$baseUrl$oldName"
    $downloadPath = Join-Path $folder $oldName
    $targetPath = Join-Path $folder $newName

    try {
        Write-Host "Downloading '$oldName' from '$url'..."
        Invoke-WebRequest -Uri $url -OutFile $downloadPath -UseBasicParsing

        if (Test-Path $targetPath) {
            Remove-Item -Path $targetPath -Force
            Write-Host "Deleted existing file: $newName"
        }

        Rename-Item -Path $downloadPath -NewName $newName
        Write-Host "Renamed '$oldName' to '$newName'"
    } catch {
        Write-Warning "Failed to process '$oldName': $_"
    }
}
