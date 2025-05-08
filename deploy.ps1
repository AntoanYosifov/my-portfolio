Param()
$ErrorActionPreference = 'Stop'

# 1) Build into a temporary directory outside the repository
$guid = [guid]::NewGuid().ToString()
$buildDir = Join-Path $env:TEMP "hugo_build_$guid"
Write-Host "Building site into '$buildDir'..."
if (Test-Path $buildDir) {
    Remove-Item $buildDir -Recurse -Force
}
hugo -d $buildDir
if ($LASTEXITCODE -ne 0) {
    throw "Hugo build failed"
}

# 2) Switch to gh-pages branch (or create it)
Write-Host "Checking out gh-pages branch..."
& git rev-parse --verify gh-pages 2>$null
if ($LASTEXITCODE -eq 0) {
    git checkout gh-pages
} else {
    git checkout --orphan gh-pages
}

# 3) Clean out old files in gh-pages (excluding .git, the temp build, and this script)
Write-Host "Cleaning old files in gh-pages..."
$keep = @('.git', (Split-Path $buildDir -Leaf), 'deploy.ps1')
Get-ChildItem -Force | Where-Object { $keep -notcontains $_.Name } | ForEach-Object {
    if ($_.PSIsContainer) {
        Remove-Item $_.FullName -Recurse -Force
    } else {
        Remove-Item $_.FullName -Force
    }
}

# 4) Copy the fresh build into the root of gh-pages
Write-Host "Copying new build into branch root..."
Copy-Item -Path (Join-Path $buildDir '*') -Destination $PSScriptRoot -Recurse -Force

# 5) Commit and push
Write-Host "Staging and committing changes..."
git add -A
$timestamp = (Get-Date).ToString("u")
git commit -m "Deploy at $timestamp"
Write-Host "Pushing to origin/gh-pages..."
git push -f origin gh-pages

# 6) Switch back to main branch
Write-Host "Switching back to main branch..."
git checkout main

# 7) Remove the temporary build directory
Write-Host "Removing temporary build directory..."
Remove-Item $buildDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Deployment complete."
