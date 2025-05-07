Param()
$ErrorActionPreference = 'Stop'

# 1. Build the site into public/
hugo

# 2. Go into the public/ folder
Push-Location public

# 3. If gh-pages doesn’t exist, create it as an orphan
if (-not (git show-ref --verify --quiet refs/heads/gh-pages)) {
    git checkout --orphan gh-pages
    git reset --hard
} else {
    git checkout gh-pages
}

# 4. Stage all files (your built site)
git add -A

# 5. Commit with a timestamp
$timestamp = (Get-Date).ToString("u")
git commit -m "Deploy at $timestamp"

# 6. Force-push to origin/gh-pages
git push -f origin gh-pages

# 7. Return to your source folder
Pop-Location

Write-Host "✅ Deployed to gh-pages!"