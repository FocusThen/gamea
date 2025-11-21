# Documentation Viewer

Interactive web-based documentation viewer for the game project.

## Quick Start

### Local Development

#### Option 1: Using the Serve Script (Recommended)

```bash
# From the project root directory
./docs-viewer/serve.sh
```

Or from docs-viewer directory:
```bash
cd docs-viewer
./serve.sh
```

Then open: http://localhost:8000/docs-viewer/

#### Option 2: Python HTTP Server

```bash
# From the project root directory (important!)
python3 -m http.server 8000
```

Then open: http://localhost:8000/docs-viewer/

#### Option 3: Node.js HTTP Server

```bash
# Install http-server globally (one time)
npm install -g http-server

# From the project root directory (important!)
http-server -p 8000
```

Then open: http://localhost:8000/docs-viewer/

#### Option 4: PHP Built-in Server

```bash
# From the project root directory (important!)
php -S localhost:8000
```

Then open: http://localhost:8000/docs-viewer/

## GitHub Pages Deployment

The documentation can be automatically deployed to GitHub Pages!

### Setup Steps

1. **Enable GitHub Pages:**
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

See [GitHub Pages Setup Guide](GITHUB_PAGES.md) for detailed instructions.

## Features

- 🔍 Full-text search across all documentation
- 🌓 Dark/light theme toggle
- 💻 Syntax highlighting for code blocks
- 📑 Auto-generated table of contents
- 📱 Mobile-responsive design
- 📋 Copy code button for code blocks
- 🧭 Sidebar navigation

## File Structure

The viewer expects markdown files in `../docs/` relative to the viewer directory:
- `docs-viewer/` - Viewer files (HTML, CSS, JS)
- `docs/` - Documentation markdown files

## Troubleshooting

### CORS Errors

If you see CORS errors, make sure you're running a web server (not opening the file directly). The browser blocks `fetch()` requests from `file://` URLs.

### Files Not Loading

**Important:** The server must be run from the **project root directory**, not from `docs-viewer/`. 

The viewer looks for files at `/docs/[path].md` (relative to project root).

If you see 404 errors:
1. Make sure you're running the server from the project root
2. Access the viewer at `http://localhost:8000/docs-viewer/`
3. The `docs/` folder should be at the project root level

### GitHub Pages Issues

- Check that GitHub Pages is enabled in repository settings
- Verify the workflow ran successfully in the Actions tab
- Ensure paths are correct (should be `/repository-name/docs-viewer/`)
- Check browser console for any path-related errors

## Development

To modify the viewer:
- `index.html` - Main HTML structure
- `css/main.css` - Main styles
- `css/syntax.css` - Code highlighting styles
- `js/app.js` - Main application logic
- `js/markdown-parser.js` - Markdown to HTML parser
- `js/code-highlight.js` - Syntax highlighting
- `js/navigation.js` - Navigation functionality
- `js/search.js` - Search functionality
