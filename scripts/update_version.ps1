# Update pubspec.yaml build number from git commit count and run flutter pub get
# Usage: .\scripts\update_version.ps1

# Get commit count
$commitCount = git rev-list --count HEAD
if ($LASTEXITCODE -ne 0) {
  Write-Error "Git command failed. Make sure you're in a git repository."
  exit 1
}

# Read pubspec
$pubspecPath = Join-Path $PSScriptRoot "..\pubspec.yaml"
$pubspec = Get-Content $pubspecPath -Raw

# Replace or append version build number
# Match version: x.y.z+build or version: x.y.z
if ($pubspec -match "version:\s*([0-9]+\.[0-9]+\.[0-9]+)(\+([0-9A-Za-z.-]+))?") {
  $base = $matches[1]
  $newVersion = "$base+$commitCount"
  $pubspec = $pubspec -replace "version:\s*([0-9]+\.[0-9]+\.[0-9]+)(\+[0-9A-Za-z.-]+)?", "version: $newVersion"
} else {
  Write-Host "No version line found, adding default 0.1.0+$commitCount"
  $pubspec = "version: 0.1.0+$commitCount`n" + $pubspec
}

# Write back
Set-Content -Path $pubspecPath -Value $pubspec -Encoding UTF8
Write-Host "Updated pubspec.yaml to use build number $commitCount"

# Run flutter pub get
flutter pub get
if ($LASTEXITCODE -ne 0) {
  Write-Error "flutter pub get failed"
  exit 1
}

Write-Host "Done."