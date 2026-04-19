#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
buildDir=$(mktemp -d "${TMPDIR:-/tmp}/hugo_build_XXXXXX")
trap 'rm -rf "$buildDir"' EXIT

# 1. Build into temp directory
echo "Building site into '$buildDir'..."
hugo -d "$buildDir"

# 2. Switch to gh-pages branch (or create it)
echo "Checking out gh-pages branch..."
if git rev-parse --verify gh-pages >/dev/null 2>&1; then
    git checkout gh-pages
else
    git checkout --orphan gh-pages
fi

# 3. Clean old files (keep .git and deploy.sh)
echo "Cleaning old files in gh-pages..."
shopt -s dotglob
for item in *; do
    [[ "$item" == ".git" || "$item" == "deploy.sh" ]] && continue
    rm -rf "$item"
done
shopt -u dotglob

# 4. Copy fresh build into branch root
echo "Copying new build into branch root..."
cp -r "$buildDir"/. "$SCRIPT_DIR/"

# 5. Commit and push
echo "Staging and committing changes..."
git add -A
git commit -m "Deploy at $(date -u +"%Y-%m-%d %H:%M:%SZ")"
echo "Pushing to origin/gh-pages..."
git push -f origin gh-pages

# 6. Switch back to main
echo "Switching back to main branch..."
git checkout main

echo "Deployment complete."
