# deploy.ps1
Param()
$ErrorActionPreference = 'Stop'

Write-Host "🔨 Building site…"
hugo

# Move into the public/ folder—this becomes the repo working directory for gh-pages
Push-Location public

# Make sure we’re starting clean on gh-pages
if (-not (git show-ref --verify --quiet refs/heads/gh-pages)) {
    Write-Host "✨ Creating orphan gh-pages branch"
    git checkout --orphan gh-pages
    git reset --hard
} else {
    Write-Host "⏪ Checking out gh-pages branch"
    git checkout gh-pages
}

# Remove any old files so we only have the new build
Write-Host "🧹 Cleaning old files…"
git rm -rf .

# Copy the new build into place
Write-Host "📦 Staging new build…"
git add -A

# Commit the changes
$ts = (Get-Date).ToString("u")
Write-Host "📝 Committing as 'Deploy at $ts'"
git commit -m "Deploy at $ts"

# Push to GitHub
Write-Host "⬆️  Pushing to origin/gh-pages…"
git push -f origin gh-pages

# Return to your source folder
Pop-Location

# Ensure we’re on main for further work
git checkout main

Write-Host "✅ Deployed to gh-pages and back on main!"
