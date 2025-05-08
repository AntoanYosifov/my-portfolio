# deploy.ps1
Param()
$ErrorActionPreference = 'Stop'

Write-Host "Building site on main…"
hugo
if ($LASTEXITCODE -ne 0) { throw "Hugo build failed" }

# 1) Switch to gh-pages (in the root repo)
Write-Host "Checking out gh-pages…"
# Run git and suppress output
& git rev-parse --verify gh-pages 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "gh-pages exists, checking out"
    git checkout gh-pages
} else {
    Write-Host "gh-pages not found, creating orphan"
    git checkout --orphan gh-pages
}

# 2) Clean out the old files (but keep .git)
Write-Host "Cleaning old files…"
git rm -rf .

# 3) Mirror public/ into the branch root
Write-Host "Copying new build into place…"
robocopy public . /MIR /XD .git

# 4) Commit & push
Write-Host "Staging & committing…"
git add -A
$ts = (Get-Date).ToString("u")
git commit -m "Deploy at $ts"
Write-Host "Pushing to origin/gh-pages…"
git push -f origin gh-pages

# 5) Return to main
Write-Host "Switching back to main…"
git checkout main

Write-Host "Deployment complete!"
