// Navigation functionality
window.navigation = {
    init() {
        this.setupNavSections();
    },
    
    setupNavSections() {
        // Make nav sections collapsible
        document.querySelectorAll('.nav-section-title, .nav-subsection > span').forEach(title => {
            title.style.cursor = 'pointer';
            title.addEventListener('click', () => {
                const ul = title.nextElementSibling;
                if (ul && ul.tagName === 'UL') {
                    ul.style.display = ul.style.display === 'none' ? 'block' : 'none';
                }
            });
        });
    }
};

// Initialize navigation
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        window.navigation.init();
    });
} else {
    window.navigation.init();
}

