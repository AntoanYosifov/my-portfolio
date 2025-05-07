# 1. Build the site
hugo

# 2. Change into public/
Push-Location public

# 3. Checkout or create gh-pages only
if (-not (git show-ref --verify --quiet refs/heads/gh-pages)) {
    git checkout --orphan gh-pages
    git reset --hard
} else {
    git checkout gh-pages
}

# 4. Remove old files (optional but safe)
git rm -rf .

# 5. Copy in all the newly built files
git add -A

# 6. Commit the new build
$timestamp = (Get-Date).ToString("u")
git commit -m "Deploy at $timestamp"

# 7. Push to gh-pages
git push -f origin gh-pages

# 8. Return to your source folder (main branch)
Pop-Location

Write-Host "✅ Deployed to gh-pages!"