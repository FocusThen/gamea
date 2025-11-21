# GitHub Pages Setup

This guide explains how to deploy the documentation to GitHub Pages.

## Automatic Deployment (Recommended)

The repository includes a GitHub Actions workflow that automatically deploys documentation when you push changes.

### Setup Steps

**Option 1: Automatic (Recommended)**
The workflow will automatically enable GitHub Pages when it runs. Just push to main!

**Option 2: Manual Setup**
1. **Enable GitHub Pages in Repository Settings:**
   - Go to your repository on GitHub
   - Click **Settings** → **Pages**
   - Under **Source**, select **GitHub Actions**
   - Save

2. **Push to Main Branch:**
   - The workflow automatically runs when you push to `main`
   - It deploys when files in `docs/` or `docs-viewer/` change
   - Check the **Actions** tab to see deployment status

3. **Access Your Documentation:**
   - Your docs will be available at: `https://[username].github.io/[repository-name]/docs-viewer/`
   - Or: `https://[username].github.io/[repository-name]/` (redirects to docs-viewer)

## Manual Deployment

If you prefer manual deployment:

1. **Install GitHub Pages gem:**
   ```bash
   gem install github-pages
   ```

2. **Build and deploy:**
   ```bash
   # The docs are already in the right format
   # Just push to gh-pages branch or use GitHub Actions
   ```

## Custom Domain

To use a custom domain:

1. Add a `CNAME` file in the repository root with your domain
2. Configure DNS settings as per GitHub Pages documentation
3. Update the base path detection in `docs-viewer/js/app.js` if needed

## Troubleshooting

### 404 Error on GitHub Pages URL

If you see a 404 at `https://[username].github.io/[repository-name]/docs-viewer/`:

1. **Check GitHub Pages is enabled:**
   - Go to repository **Settings** → **Pages**
   - Ensure **Source: GitHub Actions** is selected
   - If not, select it and **Save**

2. **Check workflow status:**
   - Go to **Actions** tab
   - Verify "Deploy Documentation to GitHub Pages" workflow has run
   - If it failed, click on it to see the error

3. **Manually trigger deployment:**
   - In **Actions** tab, click "Deploy Documentation to GitHub Pages"
   - Click **Run workflow** → Select **main** → **Run workflow**

4. **Wait for deployment:**
   - GitHub Pages can take 1-5 minutes to deploy
   - Wait a few minutes after workflow completes

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed troubleshooting steps.

### Workflow Fails with "Get Pages site failed"

**Solution:** The workflow now automatically enables Pages. If you still see this error:
1. Go to repository **Settings** → **Pages**
2. Manually select **Source: GitHub Actions**
3. Save and re-run the workflow

### Documentation Not Loading

- Check that GitHub Pages is enabled in repository settings
- Verify the workflow ran successfully in the Actions tab
- Ensure paths are correct (should be `/repository-name/docs-viewer/`)
- Wait a few minutes after deployment for DNS propagation

### 404 Errors

- Make sure you're accessing the correct URL with `/docs-viewer/` at the end
- Check that the `docs/` folder is in the repository root
- Verify the base path detection is working (check browser console)
- Clear browser cache and try again

## Workflow Details

The workflow (`/.github/workflows/docs.yml`) will:
- Run on pushes to `main` branch
- Only trigger when `docs/` or `docs-viewer/` files change
- Deploy the entire repository to GitHub Pages
- Make documentation available at the repository's Pages URL

