# deploy.ps1
Param()
$ErrorActionPreference = 'Stop'

# 1) Build into public/ on main
Write-Host "Building site on main…"
hugo
if ($LASTEXITCODE -ne 0) { throw "Hugo build failed" }

# 2) Switch the **root** repo to gh-pages
Write-Host "⏪ Checking out gh-pages…"
& git rev-parse --verify gh-pages 2>$null
if ($LASTEXITCODE -eq 0) {
    git checkout gh-pages
} else {
    git checkout --orphan gh-pages
}

# 3) Wipe out the old deploy (keep .git)
Write-Host "Cleaning old files…"
git rm -rf .

# 4) Mirror your fresh public/ into the branch root
Write-Host "Copying public/ → branch root…"
robocopy public . /MIR /XD .git

# 5) Commit & push to origin/gh-pages
Write-Host "Committing…"
git add -A
$ts = (Get-Date).ToString("u")
git commit -m "Deploy at $ts"
Write-Host "Pushing to origin/gh-pages…"
git push -f origin gh-pages

# 6) Switch back to main
Write-Host "Returning to main…"
git checkout main

Write-Host "Deployment complete!"
