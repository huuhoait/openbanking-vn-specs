# Cấu Hình Mermaid Theme cho Dark Mode

## Cách 1: Sử dụng Theme Dark Built-in

Thêm directive `%%{init: {'theme':'dark'}}%%` vào đầu mỗi diagram:

```markdown
\`\`\`mermaid
%%{init: {'theme':'dark'}}%%
sequenceDiagram
    participant A as User
    participant B as System
    A->>B: Request
    B-->>A: Response
\`\`\`
```

## Cách 2: Custom Theme Variables (Khuyến Nghị)

Sử dụng theme base với custom colors phù hợp dark mode:

```markdown
\`\`\`mermaid
%%{init: {'theme':'base', 'themeVariables': {
  'primaryColor':'#1e3a8a',
  'primaryTextColor':'#e5e7eb',
  'primaryBorderColor':'#3b82f6',
  'lineColor':'#60a5fa',
  'secondaryColor':'#1e293b',
  'tertiaryColor':'#0f172a',
  'background':'#0f172a',
  'mainBkg':'#1e293b',
  'secondBkg':'#334155',
  'textColor':'#e5e7eb',
  'border1':'#475569',
  'border2':'#64748b',
  'arrowheadColor':'#60a5fa',
  'fontFamily':'ui-sans-serif, system-ui, sans-serif',
  'fontSize':'14px'
}}}%%
sequenceDiagram
    participant A as User
    participant B as System
    A->>B: Request
    B-->>A: Response
\`\`\`
```

## Color Palette cho Dark Mode

### Primary Colors (Blue)
- `#1e3a8a` - Primary dark blue
- `#3b82f6` - Primary blue
- `#60a5fa` - Light blue
- `#93c5fd` - Very light blue

### Background Colors
- `#0f172a` - Very dark (slate-950)
- `#1e293b` - Dark (slate-900)
- `#334155` - Medium dark (slate-700)
- `#475569` - Medium (slate-600)

### Text Colors
- `#e5e7eb` - Light gray (gray-200)
- `#f3f4f6` - Very light gray (gray-100)
- `#9ca3af` - Medium gray (gray-400)

### Accent Colors
- `#10b981` - Success green
- `#ef4444` - Error red
- `#f59e0b` - Warning amber
- `#8b5cf6` - Info purple

## Theme Configuration cho Từng Loại Diagram

### Sequence Diagram

```markdown
\`\`\`mermaid
%%{init: {'theme':'base', 'themeVariables': {
  'actorBkg':'#1e293b',
  'actorBorder':'#3b82f6',
  'actorTextColor':'#e5e7eb',
  'actorLineColor':'#60a5fa',
  'signalColor':'#e5e7eb',
  'signalTextColor':'#e5e7eb',
  'labelBoxBkgColor':'#334155',
  'labelBoxBorderColor':'#475569',
  'labelTextColor':'#e5e7eb',
  'loopTextColor':'#e5e7eb',
  'noteBkgColor':'#1e3a8a',
  'noteBorderColor':'#3b82f6',
  'noteTextColor':'#e5e7eb',
  'activationBkgColor':'#3b82f6',
  'activationBorderColor':'#60a5fa',
  'sequenceNumberColor':'#0f172a'
}}}%%
sequenceDiagram
    participant User
    participant System
    User->>System: Request
    System-->>User: Response
\`\`\`
```

### State Diagram

```markdown
\`\`\`mermaid
%%{init: {'theme':'base', 'themeVariables': {
  'primaryColor':'#1e3a8a',
  'primaryTextColor':'#e5e7eb',
  'primaryBorderColor':'#3b82f6',
  'lineColor':'#60a5fa',
  'secondaryColor':'#1e293b',
  'tertiaryColor':'#0f172a',
  'clusterBkg':'#1e293b',
  'clusterBorder':'#475569',
  'titleColor':'#e5e7eb',
  'edgeLabelBackground':'#334155'
}}}%%
stateDiagram-v2
    [*] --> Active
    Active --> Inactive
    Inactive --> [*]
\`\`\`
```

### Flowchart / Graph

```markdown
\`\`\`mermaid
%%{init: {'theme':'base', 'themeVariables': {
  'primaryColor':'#1e3a8a',
  'primaryTextColor':'#e5e7eb',
  'primaryBorderColor':'#3b82f6',
  'lineColor':'#60a5fa',
  'secondaryColor':'#1e293b',
  'tertiaryColor':'#0f172a',
  'clusterBkg':'#1e293b',
  'clusterBorder':'#475569',
  'defaultLinkColor':'#60a5fa',
  'titleColor':'#e5e7eb',
  'edgeLabelBackground':'#334155',
  'nodeTextColor':'#e5e7eb'
}}}%%
graph TB
    A[Start] --> B{Decision}
    B -->|Yes| C[Process]
    B -->|No| D[End]
    C --> D
\`\`\`
```

### Class Diagram

```markdown
\`\`\`mermaid
%%{init: {'theme':'base', 'themeVariables': {
  'primaryColor':'#1e3a8a',
  'primaryTextColor':'#e5e7eb',
  'primaryBorderColor':'#3b82f6',
  'lineColor':'#60a5fa',
  'secondaryColor':'#1e293b',
  'tertiaryColor':'#0f172a',
  'classText':'#e5e7eb'
}}}%%
classDiagram
    class User {
        +String name
        +String email
        +login()
    }
\`\`\`
```

## Script Tự Động Thêm Theme

Tạo file `add-mermaid-theme.sh`:

```bash
#!/bin/bash

# Theme configuration
THEME_CONFIG="%%{init: {'theme':'base', 'themeVariables': {
  'primaryColor':'#1e3a8a',
  'primaryTextColor':'#e5e7eb',
  'primaryBorderColor':'#3b82f6',
  'lineColor':'#60a5fa',
  'secondaryColor':'#1e293b',
  'tertiaryColor':'#0f172a',
  'background':'#0f172a',
  'mainBkg':'#1e293b',
  'secondBkg':'#334155',
  'textColor':'#e5e7eb',
  'border1':'#475569',
  'border2':'#64748b',
  'arrowheadColor':'#60a5fa',
  'fontFamily':'ui-sans-serif, system-ui, sans-serif',
  'fontSize':'14px'
}}}%%"

# Find all markdown files
find . -name "*.md" -type f | while read file; do
    echo "Processing: $file"
    
    # Add theme to mermaid blocks that don't have it
    sed -i '' '/^```mermaid$/a\
'"$THEME_CONFIG"'
' "$file"
done

echo "Done!"
```

## Sử dụng trong Markdown Viewer

Nếu bạn sử dụng markdown viewer hỗ trợ Mermaid, có thể set global theme:

```html
<script type="module">
  import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs';
  mermaid.initialize({
    startOnLoad: true,
    theme: 'dark',
    themeVariables: {
      primaryColor: '#1e3a8a',
      primaryTextColor: '#e5e7eb',
      primaryBorderColor: '#3b82f6',
      lineColor: '#60a5fa',
      secondaryColor: '#1e293b',
      tertiaryColor: '#0f172a'
    }
  });
</script>
```

## Khuyến Nghị

1. **Sử dụng theme 'dark' built-in** cho đơn giản
2. **Custom theme variables** nếu cần kiểm soát màu sắc chi tiết
3. **Consistent colors** - sử dụng cùng một bộ màu cho tất cả diagrams
4. **Test contrast** - đảm bảo text dễ đọc trên background tối

## Tài Liệu Tham Khảo
- [Mermaid Theming](https://mermaid.js.org/config/theming.html)
- [Mermaid Theme Variables](https://github.com/mermaid-js/mermaid/blob/develop/packages/mermaid/src/themes/theme-dark.js)
- [Tailwind CSS Colors](https://tailwindcss.com/docs/customizing-colors)
