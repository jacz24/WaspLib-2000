# Use the folder where the script is located
$folder = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $folder

# Define the rename mappings
$renameMap = @{
    "libRemoteInput-i686.dll"        = "libremoteinput32.dll"
    "libRemoteInput-x86_64.dll"      = "libremoteinput64.dll"
    "libRemoteInput-x86_64.dylib"    = "libremoteinput64.dylib"
    "libRemoteInput-aarch64.dylib"   = "libremoteinput64.dylib.aarch64"
    "libRemoteInput-x86_64.so"       = "libremoteinput64.so"
    "libRemoteInput-aarch64.so"      = "libremoteinput64.so.aarch64"
}

# Perform the renaming
foreach ($oldName in $renameMap.Keys) {
    $newName = $renameMap[$oldName]
    if (Test-Path $oldName) {
        Rename-Item -Path $oldName -NewName $newName
        Write-Host "Renamed '$oldName' to '$newName'"
    } else {
        Write-Warning "File not found: $oldName"
    }
}
