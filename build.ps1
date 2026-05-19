$outDir  = "releases"
$outName = "RayneDevLibs.vmz"
$outPath = "$outDir\$outName"

if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
if (Test-Path $outPath)       { Remove-Item $outPath }

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$absOut  = (Resolve-Path $outDir).Path + "\$outName"
$archive = [System.IO.Compression.ZipFile]::Open($absOut, [System.IO.Compression.ZipArchiveMode]::Create)
$optimal = [System.IO.Compression.CompressionLevel]::Optimal

# mod.txt goes at the zip root
[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
    $archive, (Resolve-Path "RayneDevLibs\mod.txt").Path, "mod.txt", $optimal) | Out-Null

# All other files go under mods/RayneDevLibs/ preserving subdirectory structure
$srcRoot = (Resolve-Path "RayneDevLibs").Path
Get-ChildItem "RayneDevLibs" -File -Recurse | Where-Object { $_.Name -ne "mod.txt" } | ForEach-Object {
    $rel = $_.FullName.Substring($srcRoot.Length + 1).Replace("\", "/")
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
        $archive, $_.FullName, "mods/RayneDevLibs/$rel", $optimal) | Out-Null
}

$archive.Dispose()
Write-Host "Built $outPath"

# Deploy to mods folder (path set in build.local.ps1)
if (Test-Path "build.local.ps1") { . ".\build.local.ps1" }
if ($modsDir -and (Test-Path $modsDir)) {
    Copy-Item $absOut -Destination "$modsDir\$outName" -Force
    Write-Host "Deployed to $modsDir\$outName"
}
