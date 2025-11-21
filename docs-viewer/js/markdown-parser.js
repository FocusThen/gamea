// Simple markdown parser
window.markdownParser = {
    parse(markdown) {
        let html = markdown;
        
        // Headers
        html = html.replace(/^### (.*$)/gim, '<h3>$1</h3>');
        html = html.replace(/^## (.*$)/gim, '<h2>$1</h2>');
        html = html.replace(/^# (.*$)/gim, '<h1>$1</h1>');
        
        // Bold
        html = html.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
        
        // Italic
        html = html.replace(/\*(.*?)\*/g, '<em>$1</em>');
        
        // Code blocks - preserve content as-is (will be escaped by browser)
        html = html.replace(/```(\w+)?\n([\s\S]*?)```/g, (match, lang, code) => {
            // Escape HTML entities in code
            const escaped = code
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#39;');
            return `<pre><code class="language-${lang || ''}">${escaped}</code></pre>`;
        });
        
        // Inline code
        html = html.replace(/`([^`]+)`/g, '<code>$1</code>');
        
        // Links
        html = html.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>');
        
        // Lists
        html = html.replace(/^\- (.*$)/gim, '<li>$1</li>');
        html = html.replace(/^(\d+)\. (.*$)/gim, '<li>$2</li>');
        
        // Wrap consecutive list items
        html = html.replace(/(<li>.*<\/li>\n?)+/g, (match) => {
            return '<ul>' + match + '</ul>';
        });
        
        // Paragraphs
        html = html.split('\n\n').map(para => {
            if (para.trim() && !para.match(/^<[hul]/)) {
                return '<p>' + para.trim() + '</p>';
            }
            return para;
        }).join('\n');
        
        // Blockquotes
        html = html.replace(/^> (.*$)/gim, '<blockquote>$1</blockquote>');
        
        // Tables (basic)
        const tableRegex = /^\|(.+)\|$/gm;
        const tableRows = [];
        let inTable = false;
        const lines = html.split('\n');
        
        html = lines.map((line, i) => {
            if (line.match(tableRegex)) {
                if (!inTable) {
                    inTable = true;
                    return '<table><tbody>' + this.parseTableRow(line);
                }
                return this.parseTableRow(line);
            } else if (inTable) {
                inTable = false;
                return '</tbody></table>' + line;
            }
            return line;
        }).join('\n');
        
        if (inTable) {
            html += '</tbody></table>';
        }
        
        // Horizontal rules
        html = html.replace(/^---$/gm, '<hr>');
        
        return html;
    },
    
    parseTableRow(line) {
        const cells = line.split('|').filter(cell => cell.trim());
        const isHeader = line.includes('---');
        if (isHeader) return '';
        
        const tag = isHeader ? 'th' : 'td';
        return '<tr>' + cells.map(cell => `<${tag}>${cell.trim()}</${tag}>`).join('') + '</tr>';
    }
};

