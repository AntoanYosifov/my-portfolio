# deploy.ps1
Param()
$ErrorActionPreference = 'Stop'

Write-Host "Building site…"
hugo

# Step into public/ for gh-pages work
Push-Location public

# Create or switch to gh-pages branch
if (-not (git show-ref --verify --quiet refs/heads/gh-pages)) {
    Write-Host "Creating orphan gh-pages branch"
    git checkout --orphan gh-pages
    git reset --hard
} else {
    Write-Host "Checking out gh-pages branch"
    git checkout gh-pages
}

# Clean out old files
Write-Host "Cleaning old files…"
git rm -rf .

# Return to project root to rebuild
Pop-Location

# Rebuild fresh
Write-Host "Rebuilding site…"
hugo

# Step back into public/ to commit the fresh build
Push-Location public

# Stage new build
Write-Host "Staging new build…"
git add -A

# Commit and push
$ts = (Get-Date).ToString("u")
Write-Host "Committing as 'Deploy at $ts'"
git commit -m "Deploy at $ts"

Write-Host "Pushing to origin/gh-pages…"
git push -f origin gh-pages

# Return to project root and main branch
Pop-Location
Write-Host "Switching back to main"
git checkout main

Write-Host "Deploy complete!"
