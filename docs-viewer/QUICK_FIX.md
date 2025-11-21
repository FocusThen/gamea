# Quick Fix for 404 Error

If you're seeing a 404 at `https://focusthen.github.io/gamea/docs-viewer/`:

## Immediate Steps

1. **Enable GitHub Pages Manually:**
   - Go to: https://github.com/FocusThen/gamea/settings/pages
   - Under **Source**, select **GitHub Actions**
   - Click **Save**

2. **Trigger the Workflow:**
   - Go to: https://github.com/FocusThen/gamea/actions
   - Click on "Deploy Documentation to GitHub Pages" workflow
   - Click **Run workflow** (top right)
   - Select **main** branch
   - Click **Run workflow**

3. **Wait for Deployment:**
   - Check the workflow run (should show green checkmark when done)
   - Wait 2-3 minutes after workflow completes
   - Try accessing: https://focusthen.github.io/gamea/docs-viewer/

## Verify Deployment

After the workflow completes:
1. Go to **Settings** → **Pages**
2. You should see: "Your site is live at https://focusthen.github.io/gamea/"
3. The deployment should show a green checkmark

## If Still 404

1. Check browser console (F12) for errors
2. Try hard refresh: Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)
3. Check that all files are committed and pushed to `main` branch
4. Verify `.nojekyll` file exists in repository root

## Expected URL Structure

- Repository: `https://github.com/FocusThen/gamea`
- GitHub Pages: `https://focusthen.github.io/gamea/`
- Documentation: `https://focusthen.github.io/gamea/docs-viewer/`

Note: GitHub Pages URLs use lowercase repository name (`gamea`), not the GitHub username case.

