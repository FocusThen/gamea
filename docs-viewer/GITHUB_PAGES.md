# GitHub Pages Setup

This guide explains how to deploy the documentation to GitHub Pages.

## Automatic Deployment (Recommended)

The repository includes a GitHub Actions workflow that automatically deploys documentation when you push changes.

### Setup Steps

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

### Documentation Not Loading

- Check that GitHub Pages is enabled in repository settings
- Verify the workflow ran successfully in the Actions tab
- Ensure paths are correct (should be `/repository-name/docs-viewer/`)

### 404 Errors

- Make sure you're accessing the correct URL with `/docs-viewer/` at the end
- Check that the `docs/` folder is in the repository root
- Verify the base path detection is working (check browser console)

## Workflow Details

The workflow (`/.github/workflows/docs.yml`) will:
- Run on pushes to `main` branch
- Only trigger when `docs/` or `docs-viewer/` files change
- Deploy the entire repository to GitHub Pages
- Make documentation available at the repository's Pages URL

