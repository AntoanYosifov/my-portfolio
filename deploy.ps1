# deploy.ps1
Param()
$ErrorActionPreference = 'Stop'

# 1) Build on main
Write-Host "Building site on main…"
hugo
if ($LASTEXITCODE -ne 0) { throw "Hugo build failed" }

# 2) Switch root repo to gh-pages
Write-Host "Checking out gh-pages…"
& git rev-parse --verify gh-pages 2>$null
if ($LASTEXITCODE -eq 0) {
    git checkout gh-pages
} else {
    git checkout --orphan gh-pages
}

# 3) Clean root (keep .git)
Write-Host "Cleaning old files (except .git)…"
Get-ChildItem -Force | Where-Object Name -NotIn '.git' | ForEach-Object {
    if ($_.PSIsContainer) {
        Remove-Item $_.FullName -Recurse -Force
    } else {
        Remove-Item $_.FullName -Force
    }
}

# 4) Copy fresh build
Write-Host "Copying public/ → branch root…"
Copy-Item -Path (Join-Path $PSScriptRoot 'public\*') -Destination $PSScriptRoot -Recurse -Force

# 5) Commit & push
Write-Host "Staging & committing…"
git add -A
$ts = (Get-Date).ToString("u")
git commit -m "Deploy at $ts"
Write-Host "Pushing to origin/gh-pages…"
git push -f origin gh-pages

# 6) Return to main
Write-Host "Returning to main…"
git checkout main

Write-Host "Deployment complete!"
