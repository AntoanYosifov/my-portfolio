# deploy.ps1 (fixed order)
Param()
$ErrorActionPreference = 'Stop'

Write-Host "⏪ Preparing gh-pages…"

# 1. Switch into public/, creating it if needed
Push-Location public

if (-not (git show-ref --verify --quiet refs/heads/gh-pages)) {
    Write-Host "✨ Creating orphan gh-pages branch"
    git checkout --orphan gh-pages
} else {
    Write-Host "⏪ Checking out gh-pages branch"
    git checkout gh-pages
}

# 2. Clean out old build
Write-Host "🧹 Cleaning old files…"
git rm -rf .

Pop-Location

# 3. Build fresh into public/
Write-Host "🔨 Building site…"
hugo

# 4. Copy the new build into public/ on gh-pages branch
Push-Location public

Write-Host "📦 Staging new build…"
git add -A

# 5. Commit & push
$ts = (Get-Date).ToString("u")
Write-Host "📝 Committing as 'Deploy at $ts'"
git commit -m "Deploy at $ts"
Write-Host "⬆️ Pushing to origin/gh-pages…"
git push -f origin gh-pages

Pop-Location

# 6. Back to main
git checkout main
Write-Host "✅ Deployed to gh-pages and back on main!"
