# Troubleshooting GitHub Pages

## 404 Error on GitHub Pages

If you're seeing a 404 error at `https://[username].github.io/[repository-name]/docs-viewer/`:

### Step 1: Verify GitHub Pages is Enabled

1. Go to your repository: https://github.com/[username]/[repository-name]
2. Click **Settings** → **Pages**
3. Under **Source**, make sure **GitHub Actions** is selected
4. If it's not selected, select it and click **Save**

### Step 2: Check Workflow Status

1. Go to the **Actions** tab in your repository
2. Look for the "Deploy Documentation to GitHub Pages" workflow
3. Check if it has run and if it succeeded (green checkmark)
4. If it failed (red X), click on it to see the error

### Step 3: Manually Trigger Deployment

If the workflow hasn't run:

1. Go to **Actions** tab
2. Click on "Deploy Documentation to GitHub Pages" workflow
3. Click **Run workflow** button (top right)
4. Select **main** branch
5. Click **Run workflow**

### Step 4: Wait for Deployment

- GitHub Pages deployments can take 1-5 minutes
- After the workflow completes, wait a few minutes for DNS/propagation
- Try accessing the URL again

### Step 5: Verify Files Are Deployed

1. Go to repository **Settings** → **Pages**
2. Check the deployment status
3. You should see a green checkmark and a URL

### Step 6: Check URL Format

Make sure you're using the correct URL format:
- ✅ Correct: `https://focusthen.github.io/gamea/docs-viewer/`
- ❌ Wrong: `https://focusthen.github.io/gamea/` (missing `/docs-viewer/`)
- ❌ Wrong: `https://github.com/FocusThen/gamea/docs-viewer/` (this is the repo, not Pages)

## Common Issues

### "Get Pages site failed" Error

**Solution:**
1. Manually enable Pages: **Settings** → **Pages** → **Source: GitHub Actions**
2. Save
3. Re-run the workflow

### Workflow Runs But 404 Persists

**Possible causes:**
1. Files not in correct location - ensure `docs/` and `docs-viewer/` are in repository root
2. Base path detection issue - check browser console for errors
3. Cache issue - try hard refresh (Ctrl+Shift+R or Cmd+Shift+R)
4. Deployment not complete - wait a few more minutes

### Files Load But Show "Loading documentation..."

**Solution:**
- Check browser console (F12) for fetch errors
- Verify `docs/` folder contains `.md` files
- Check that base path detection is working (should be `/gamea/` for your repo)

## Testing Base Path Detection

Open browser console (F12) and run:
```javascript
// Should show the detected base path
console.log(window.app.basePath);
// For your repo, it should show: "/gamea"
```

## Still Having Issues?

1. Check the **Actions** tab for workflow errors
2. Check browser console (F12) for JavaScript errors
3. Verify all files are committed and pushed to `main` branch
4. Make sure `.nojekyll` file exists in repository root

