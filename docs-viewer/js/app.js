// Main application logic
class DocumentationApp {
    constructor() {
        this.currentPath = null;
        this.docsCache = new Map();
        // Detect GitHub Pages base path
        this.basePath = this.detectBasePath();
        this.init();
    }
    
    detectBasePath() {
        // Check if we're on GitHub Pages
        // GitHub Pages uses /repository-name/ as base path for project pages
        const pathname = window.location.pathname;
        
        // Match pattern: /repository-name/docs-viewer/...
        const match = pathname.match(/^\/([^\/]+)\/docs-viewer/);
        if (match) {
            return '/' + match[1];
        }
        
        // Check if docs-viewer is at root level (user/organization pages)
        if (pathname.startsWith('/docs-viewer/')) {
            return '';
        }
        
        // Default: no base path (local development)
        return '';
    }
    
    init() {
        this.setupTheme();
        this.loadInitialDoc();
        this.setupEventListeners();
    }
    
    setupTheme() {
        const theme = localStorage.getItem('theme') || 'light';
        document.documentElement.setAttribute('data-theme', theme);
        document.getElementById('themeToggle').textContent = theme === 'dark' ? '☀️' : '🌙';
    }
    
    setupEventListeners() {
        // Theme toggle
        document.getElementById('themeToggle').addEventListener('click', () => {
            const currentTheme = document.documentElement.getAttribute('data-theme');
            const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
            document.documentElement.setAttribute('data-theme', newTheme);
            localStorage.setItem('theme', newTheme);
            document.getElementById('themeToggle').textContent = newTheme === 'dark' ? '☀️' : '🌙';
        });
        
        // Sidebar toggle (mobile)
        document.getElementById('sidebarToggle').addEventListener('click', () => {
            document.getElementById('sidebar').classList.toggle('open');
        });
        
        // Navigation links
        document.querySelectorAll('.nav-list a').forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const path = link.getAttribute('data-path');
                if (path) {
                    this.loadDocumentation(path);
                    // Close sidebar on mobile
                    if (window.innerWidth <= 768) {
                        document.getElementById('sidebar').classList.remove('open');
                    }
                }
            });
        });
        
        // Hash change (for direct links)
        window.addEventListener('hashchange', () => {
            const hash = window.location.hash.substring(1);
            if (hash) {
                this.loadDocumentation(hash);
            }
        });
    }
    
    loadInitialDoc() {
        const hash = window.location.hash.substring(1);
        const path = hash || 'guides/getting-started';
        this.loadDocumentation(path);
    }
    
    async loadDocumentation(path) {
        this.currentPath = path;
        window.location.hash = path;
        
        const contentEl = document.getElementById('documentationContent');
        contentEl.innerHTML = '<div class="loading">Loading documentation...</div>';
        
        // Update active nav
        document.querySelectorAll('.nav-list a').forEach(link => {
            link.classList.remove('active');
            if (link.getAttribute('data-path') === path) {
                link.classList.add('active');
            }
        });
        
        // Check cache
        if (this.docsCache.has(path)) {
            this.renderDocumentation(this.docsCache.get(path), path);
            return;
        }
        
        try {
            // Use base path for GitHub Pages compatibility
            const response = await fetch(`${this.basePath}/docs/${path}.md`);
            if (!response.ok) throw new Error('Document not found');
            
            const markdown = await response.text();
            this.docsCache.set(path, markdown);
            this.renderDocumentation(markdown, path);
        } catch (error) {
            contentEl.innerHTML = `<div class="error">Error loading documentation: ${error.message}</div>`;
        }
    }
    
    renderDocumentation(markdown, path) {
        const contentEl = document.getElementById('documentationContent');
        const html = window.markdownParser.parse(markdown);
        contentEl.innerHTML = html;
        
        // Highlight code
        window.codeHighlighter.highlightAll(contentEl);
        
        // Generate table of contents
        this.generateTableOfContents(contentEl);
        
        // Update breadcrumbs
        this.updateBreadcrumbs(path);
        
        // Make code blocks copyable
        this.makeCodeCopyable(contentEl);
    }
    
    generateTableOfContents(contentEl) {
        const tocEl = document.getElementById('tableOfContents');
        const headings = contentEl.querySelectorAll('h2, h3');
        
        if (headings.length === 0) {
            tocEl.classList.remove('active');
            return;
        }
        
        tocEl.classList.add('active');
        const tocList = document.createElement('ul');
        
        headings.forEach(heading => {
            const id = heading.textContent.toLowerCase().replace(/\s+/g, '-').replace(/[^\w-]/g, '');
            heading.id = id;
            
            const li = document.createElement('li');
            const a = document.createElement('a');
            a.href = `#${id}`;
            a.textContent = heading.textContent;
            a.addEventListener('click', (e) => {
                e.preventDefault();
                heading.scrollIntoView({ behavior: 'smooth', block: 'start' });
            });
            li.appendChild(a);
            tocList.appendChild(li);
        });
        
        tocEl.innerHTML = '<h3>Contents</h3>';
        tocEl.appendChild(tocList);
    }
    
    updateBreadcrumbs(path) {
        const breadcrumbsEl = document.getElementById('breadcrumbs');
        const parts = path.split('/');
        let breadcrumbs = '<a href="#guides/getting-started">Home</a>';
        
        parts.forEach((part, index) => {
            if (index < parts.length - 1) {
                const subPath = parts.slice(0, index + 1).join('/');
                breadcrumbs += ` / <a href="#${subPath}">${part}</a>`;
            } else {
                breadcrumbs += ` / ${part}`;
            }
        });
        
        breadcrumbsEl.innerHTML = breadcrumbs;
    }
    
    makeCodeCopyable(contentEl) {
        const codeBlocks = contentEl.querySelectorAll('pre code');
        codeBlocks.forEach(block => {
            const pre = block.parentElement;
            if (pre.querySelector('.copy-button')) return;
            
            const button = document.createElement('button');
            button.className = 'copy-button';
            button.textContent = 'Copy';
            button.addEventListener('click', () => {
                navigator.clipboard.writeText(block.textContent).then(() => {
                    button.textContent = 'Copied!';
                    setTimeout(() => {
                        button.textContent = 'Copy';
                    }, 2000);
                });
            });
            pre.style.position = 'relative';
            button.style.position = 'absolute';
            button.style.top = '0.5rem';
            button.style.right = '0.5rem';
            button.style.padding = '0.25rem 0.5rem';
            button.style.background = 'var(--bg-primary)';
            button.style.border = '1px solid var(--border-color)';
            button.style.borderRadius = '4px';
            button.style.cursor = 'pointer';
            button.style.fontSize = '0.8rem';
            pre.appendChild(button);
        });
    }
}

// Initialize app when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        window.app = new DocumentationApp();
    });
} else {
    window.app = new DocumentationApp();
}

