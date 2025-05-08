# deploy.ps1
Param()
$ErrorActionPreference = 'Stop'

# 1) Define build dir
$buildDir = Join-Path $PSScriptRoot "__hugo_build__"

# 2) Build into temp folder
Write-Host "Building site into '$buildDir'..."
# Remove any previous build
if (Test-Path $buildDir) { Remove-Item $buildDir -Recurse -Force }
# Use -d (alias for --destination)
hugo -d $buildDir
if ($LASTEXITCODE -ne 0) { throw "Hugo build failed" }
if (-not (Test-Path $buildDir)) { throw "Build directory not found: $buildDir" }

# 3) Switch root repo to gh-pages
Write-Host "Checking out (or creating) gh-pages branch..."
& git rev-parse --verify gh-pages 2>$null
if ($LASTEXITCODE -eq 0) {
    git checkout gh-pages
} else {
    git checkout --orphan gh-pages
}

# 4) Wipe old files (except .git)
Write-Host "Cleaning old files (except .git)..."
Get-ChildItem -Force | Where-Object Name -NotIn '.git' | ForEach-Object {
    if ($_.PSIsContainer) { Remove-Item $_.FullName -Recurse -Force }
    else                   { Remove-Item $_.FullName -Force }
}

# 5) Copy the new build into place
Write-Host "Copying new build into branch root..."
Copy-Item -Path (Join-Path $buildDir '*') -Destination $PSScriptRoot -Recurse -Force

# 6) Commit & push
Write-Host "Staging and committing..."
git add -A
$timestamp = (Get-Date).ToString("u")
git commit -m "Deploy at $timestamp"
Write-Host "Pushing to origin/gh-pages..."
git push -f origin gh-pages

# 7) Switch back to main
Write-Host "Returning to main branch..."
git checkout main

# 8) Clean up temp folder
Write-Host "Removing temporary build directory..."
Remove-Item $buildDir -Recurse -Force

Write-Host "Deployment complete."
