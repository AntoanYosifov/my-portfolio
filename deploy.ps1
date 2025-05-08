# deploy.ps1
Param()
$ErrorActionPreference = 'Stop'

# 1) Build on main into temp dir
$buildDir = Join-Path $PSScriptRoot "__hugo_build__"
Write-Host "Building site into '$buildDir'..."
if (Test-Path $buildDir) { Remove-Item $buildDir -Recurse -Force }
hugo -d $buildDir
if ($LASTEXITCODE -ne 0) { throw "Hugo build failed" }

# 2) Switch to gh-pages in the root repo
Write-Host "Checking out gh-pages branch..."
& git rev-parse --verify gh-pages 2>$null
if ($LASTEXITCODE -eq 0) {
    git checkout gh-pages
} else {
    git checkout --orphan gh-pages
}

# 3) Clean out everything except .git, temp build, and script
Write-Host "Cleaning old files (except .git and __hugo_build__ )..."
Get-ChildItem -Force | Where-Object Name -NotIn '.git','__hugo_build__','deploy.ps1' | ForEach-Object {
    if ($_.PSIsContainer) { Remove-Item $_.FullName -Recurse -Force }
    else                   { Remove-Item $_.FullName -Force }
}

# 4) Copy in the fresh build
Write-Host "Copying new build into branch root..."
Copy-Item -Path (Join-Path $buildDir '*') -Destination $PSScriptRoot -Recurse -Force

# 5) Commit & push
Write-Host "Staging & committing…"
git add -A
$ts = (Get-Date).ToString("u")
git commit -m "Deploy at $ts"
Write-Host "Pushing to origin/gh-pages…"
git push -f origin gh-pages

# 6) Return to main
Write-Host "Switching back to main…"
git checkout main

# 7) Remove the temp build folder
Write-Host "Removing temporary build directory…"
Remove-Item $buildDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Deployment complete."
