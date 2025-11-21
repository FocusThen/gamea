// Search functionality
window.search = {
    index: [],
    
    async init() {
        await this.buildIndex();
        this.setupSearch();
    },
    
    async buildIndex() {
        // Build search index from documentation files
        // This would ideally be pre-generated, but for now we'll build it on load
        const docs = [
            'api/core/camera', 'api/core/constants', 'api/core/colors', 'api/core/utils',
            'api/objects/trigger', 'api/objects/player', 'api/objects/box', 'api/objects/coin',
            'api/objects/door', 'api/objects/teleporter', 'api/objects/saw', 'api/objects/cutscene',
            'api/states/stateMachine', 'api/states/game',
            'api/systems/particles', 'api/systems/shaders', 'api/systems/sceneEffects',
            'api/systems/saveSystem', 'api/systems/inputConfig',
            'api/game/loadMap', 'api/game/resources',
            'api/main', 'api/conf',
            'guides/getting-started', 'guides/trigger-system', 'guides/camera-guide', 'guides/tiled-integration',
            'architecture/project-structure'
        ];
        
        // Get base path from app
        const basePath = window.app ? window.app.basePath : '';
        
        for (const doc of docs) {
            try {
                const response = await fetch(`${basePath}/docs/${doc}.md`);
                if (response.ok) {
                    const text = await response.text();
                    const title = this.extractTitle(text);
                    this.index.push({
                        path: doc,
                        title: title,
                        content: text.substring(0, 500) // First 500 chars for preview
                    });
                }
            } catch (e) {
                console.warn('Failed to index:', doc);
            }
        }
    },
    
    extractTitle(text) {
        const match = text.match(/^#\s+(.+)$/m);
        return match ? match[1] : 'Untitled';
    },
    
    setupSearch() {
        const input = document.getElementById('searchInput');
        const results = document.getElementById('searchResults');
        
        input.addEventListener('input', (e) => {
            const query = e.target.value.trim().toLowerCase();
            if (query.length < 2) {
                results.classList.remove('active');
                return;
            }
            
            const matches = this.search(query);
            this.displayResults(matches, results);
        });
        
        // Close on outside click
        document.addEventListener('click', (e) => {
            if (!input.contains(e.target) && !results.contains(e.target)) {
                results.classList.remove('active');
            }
        });
    },
    
    search(query) {
        return this.index
            .map(doc => {
                const titleScore = doc.title.toLowerCase().includes(query) ? 10 : 0;
                const contentScore = (doc.content.toLowerCase().match(new RegExp(query, 'g')) || []).length;
                return {
                    ...doc,
                    score: titleScore + contentScore
                };
            })
            .filter(doc => doc.score > 0)
            .sort((a, b) => b.score - a.score)
            .slice(0, 10);
    },
    
    displayResults(matches, container) {
        if (matches.length === 0) {
            container.innerHTML = '<div class="search-result-item">No results found</div>';
            container.classList.add('active');
            return;
        }
        
        container.innerHTML = matches.map(doc => `
            <div class="search-result-item" data-path="${doc.path}">
                <strong>${doc.title}</strong><br>
                <small>${doc.path}</small>
            </div>
        `).join('');
        
        container.querySelectorAll('.search-result-item').forEach(item => {
            item.addEventListener('click', () => {
                const path = item.getAttribute('data-path');
                window.app.loadDocumentation(path);
                container.classList.remove('active');
                document.getElementById('searchInput').value = '';
            });
        });
        
        container.classList.add('active');
    }
};

// Initialize search
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        window.search.init();
    });
} else {
    window.search.init();
}

