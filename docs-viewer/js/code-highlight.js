// Code syntax highlighting
window.codeHighlighter = {
    highlightAll(container) {
        const codeBlocks = container.querySelectorAll('pre code');
        codeBlocks.forEach(block => {
            // Only highlight if not already highlighted
            if (block.querySelector('span.keyword, span.string, span.comment')) {
                return; // Already highlighted
            }
            this.highlight(block);
        });
    },
    
    highlight(block) {
        const language = block.className.match(/language-(\w+)/);
        if (!language) return;
        
        const lang = language[1];
        if (lang === 'lua') {
            this.highlightLua(block);
        }
    },
    
    highlightLua(block) {
        // Get the raw, unescaped text content
        const code = block.textContent;
        
        // Keywords
        const keywords = ['function', 'local', 'if', 'then', 'else', 'elseif', 'end', 'for', 'while', 'do', 'repeat', 'until', 'return', 'and', 'or', 'not', 'nil', 'true', 'false', 'in', 'self'];
        
        // Build highlighted version character by character to avoid regex conflicts
        let highlighted = '';
        let i = 0;
        const len = code.length;
        
        while (i < len) {
            // Check for strings
            if (code[i] === '"' || code[i] === "'") {
                const quote = code[i];
                let string = quote;
                i++;
                while (i < len && code[i] !== quote) {
                    if (code[i] === '\\' && i + 1 < len) {
                        string += code[i] + code[i + 1];
                        i += 2;
                    } else {
                        string += code[i];
                        i++;
                    }
                }
                if (i < len) {
                    string += code[i];
                    i++;
                }
                highlighted += `<span class="string">${this.escapeHtml(string)}</span>`;
                continue;
            }
            
            // Check for comments
            if (i < len - 1 && code[i] === '-' && code[i + 1] === '-') {
                let comment = '--';
                i += 2;
                while (i < len && code[i] !== '\n' && code[i] !== '\r') {
                    comment += code[i];
                    i++;
                }
                highlighted += `<span class="comment">${this.escapeHtml(comment)}</span>`;
                continue;
            }
            
            // Check for keywords
            let matched = false;
            for (const keyword of keywords) {
                if (i + keyword.length <= len && 
                    code.substring(i, i + keyword.length) === keyword &&
                    (i === 0 || !/\w/.test(code[i - 1])) &&
                    (i + keyword.length >= len || !/\w/.test(code[i + keyword.length]))) {
                    highlighted += `<span class="keyword">${keyword}</span>`;
                    i += keyword.length;
                    matched = true;
                    break;
                }
            }
            if (matched) continue;
            
            // Check for function calls
            const funcMatch = code.substring(i).match(/^(\w+)\s*\(/);
            if (funcMatch && !keywords.includes(funcMatch[1])) {
                highlighted += `<span class="function">${this.escapeHtml(funcMatch[1])}</span>`;
                i += funcMatch[1].length;
                continue;
            }
            
            // Check for numbers
            const numMatch = code.substring(i).match(/^\d+\.?\d*/);
            if (numMatch) {
                highlighted += `<span class="number">${numMatch[0]}</span>`;
                i += numMatch[0].length;
                continue;
            }
            
            // Regular character - escape HTML
            highlighted += this.escapeHtml(code[i]);
            i++;
        }
        
        // Set the HTML content
        block.innerHTML = highlighted;
    },
    
    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
};

