# Documentation Viewer

Interactive web-based documentation viewer for the game project.

## Quick Start

### Option 1: Using the Serve Script (Recommended)

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

### Option 2: Python HTTP Server

```bash
# From the project root directory (important!)
python3 -m http.server 8000
```

Then open: http://localhost:8000/docs-viewer/

### Option 3: Node.js HTTP Server

```bash
# Install http-server globally (one time)
npm install -g http-server

# From the project root directory (important!)
http-server -p 8000
```

Then open: http://localhost:8000/docs-viewer/

### Option 4: PHP Built-in Server

```bash
# From the project root directory (important!)
php -S localhost:8000
```

Then open: http://localhost:8000/docs-viewer/

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

