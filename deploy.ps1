# deploy.ps1
Param()
$ErrorActionPreference = 'Stop'

# 1) Build Hugo into a temporary directory
$buildDir = Join-Path $PSScriptRoot "__hugo_build__"
Write-Host "Building site into temporary folder..."
Remove-Item $buildDir -Recurse -Force -ErrorAction SilentlyContinue
hugo --destination $buildDir
if ($LASTEXITCODE -ne 0) {
    throw "Hugo build failed"
}

# 2) Switch the root repo to gh-pages
Write-Host "Checking out gh-pages branch..."
& git rev-parse --verify gh-pages 2>$null
if ($LASTEXITCODE -eq 0) {
    git checkout gh-pages
} else {
    git checkout --orphan gh-pages
}

# 3) Remove all existing files except .git
Write-Host "Cleaning old files (except .git)..."
Get-ChildItem -Force | Where-Object Name -NotIn '.git' | ForEach-Object {
    if ($_.PSIsContainer) {
        Remove-Item $_.FullName -Recurse -Force
    } else {
        Remove-Item $_.FullName -Force
    }
}

# 4) Copy new build from temp directory
Write-Host "Copying new build into branch root..."
Copy-Item -Path (Join-Path $buildDir '*') -Destination $PSScriptRoot -Recurse -Force

# 5) Commit and push to gh-pages
Write-Host "Staging and committing changes..."
git add -A
$timestamp = (Get-Date).ToString("u")
git commit -m "Deploy at $timestamp"
Write-Host "Pushing to origin/gh-pages..."
git push -f origin gh-pages

# 6) Switch back to main
Write-Host "Switching back to main branch..."
git checkout main

# 7) Clean up temp build directory
Remove-Item $buildDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Deployment complete."
