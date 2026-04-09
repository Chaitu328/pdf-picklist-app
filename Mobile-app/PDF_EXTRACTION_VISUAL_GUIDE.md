# PDF Text Extraction Feature - Visual Guide

## UI Layout Structure

```
┌─────────────────────────────────────────┐
│           Dashboard (AppBar)             │
└─────────────────────────────────────────┘
│                                         │
│  [Upload Media Button]                  │
│  [Scan QR Code Button]                  │
│                                         │
│  ┌──────────────────────────────────┐   │
│  │  Upload Progress (0-100%)        │   │
│  └──────────────────────────────────┘   │
│                                         │
│  ┌─────── Uploaded Documents ──────┐   │
│  │                                 │   │
│  │ 📄 document.pdf                 │   │
│  │ 2.5 MB • 5/3/2026         [🗑️] │   │
│  │                                 │   │
│  │ 📄 report.pdf                   │   │
│  │ 1.8 MB • 5/3/2026         [🗑️] │   │
│  │                                 │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─ Extracted Text from PDFs ──────┐   │
│  │                                 │   │
│  │ 📄 document.pdf                 │   │
│  │   Text extracted • 5000 chars   │   │
│  │                                 │ ▼ │
│  │ ┌─────────────────────────────┐ │   │
│  │ │ This is the extracted...    │ │   │
│  │ │ text from your PDF file.    │ │   │
│  │ │ It supports multiple pages. │ │   │
│  │ │                             │ │   │
│  │ │ Page 2 content starts here  │ │   │
│  │ │ More extracted text...      │ │   │
│  │ │                             │ │   │
│  │ │              [📋 Copy]       │ │   │
│  │ └─────────────────────────────┘ │   │
│  │                                 │   │
│  │ 📄 report.pdf                   │   │
│  │   Text extracted • 3200 chars   │   │
│  │                                 │   │
│  └─────────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘
```

## Component Breakdown

### 1. Uploaded Documents Section
```
┌────────────────────────────────────────┐
│ Uploaded Documents                     │
├────────────────────────────────────────┤
│ ┌──────────────────────────────────┐   │
│ │ 📄 │ document.pdf          [🗑️]  │   │
│ │    │ 2.5 MB • 5/3/2026             │   │
│ └──────────────────────────────────┘   │
├────────────────────────────────────────┤
│ ┌──────────────────────────────────┐   │
│ │ 📄 │ report.pdf            [🗑️]  │   │
│ │    │ 1.8 MB • 5/3/2026             │   │
│ └──────────────────────────────────┘   │
└────────────────────────────────────────┘
```

### 2. Extracted Text Section (Collapsed)
```
┌────────────────────────────────────────┐
│ 📄 document.pdf                     ▶️  │
│ Text extracted • 5000 characters       │
└────────────────────────────────────────┘
```

### 3. Extracted Text Section (Expanded)
```
┌────────────────────────────────────────┐
│ 📄 document.pdf                     ▼️  │
│ Text extracted • 5000 characters       │
├────────────────────────────────────────┤
│ ┌──────────────────────────────────┐   │
│ │ This is the extracted text from   │   │
│ │ your PDF file. It supports        │   │
│ │ multiple pages and displays       │   │
│ │ all content in a readable format. │   │
│ │                                  │   │
│ │ Page 2 begins here...             │   │
│ │ More content follows...           │   │
│ │                                  │   │
│ │ This text can be selected and    │   │
│ │ copied for other uses.            │   │
│ │                    [📋 Copy]      │   │
│ └──────────────────────────────────┘   │
└────────────────────────────────────────┘
```

## Color Scheme

| Element | Color | Usage |
|---------|-------|-------|
| Primary Icon Background | `cAppPrimaryColor` (0.1 opacity) | Document icons |
| Primary Text | `cPrimaryButtonColor` | Copy button |
| Background | Light Gray (0xFFF5F5F5) | Text display area |
| Text | `blackColor` | Main content |
| Secondary Text | `secondaryTextColor` | Metadata |
| Border | `lightGreyColor` | Card borders |
| Delete Icon | Red | Delete buttons |

## Font Specifications

| Component | Font | Size | Weight |
|-----------|------|------|--------|
| Section Title | System | 16 | 600 |
| File Name | System | 14 | 600 |
| Subtitle | System | 12 | 400 |
| Extracted Text | Courier | 13 | 400 |
| Line Height (Text) | Courier | 13 | 1.6 |

## User Interaction Flow

### Scenario 1: Upload and View Extracted Text
```
1. User clicks "Upload Media"
   ↓
2. Select PDF from camera/gallery/files
   ↓
3. Upload progress bar appears (0-100%)
   ↓
4. File appears in "Uploaded Documents"
   ↓
5. If extraction successful:
   → Document appears in "Extracted Text from PDFs"
   → User can expand/collapse
   → Can copy text to clipboard
```

### Scenario 2: No Text Extracted
```
1. User uploads image-based PDF
   ↓
2. File appears in "Uploaded Documents"
   ↓
3. File NOT shown in "Extracted Text from PDFs"
   (Section only shows if text was extracted)
   ↓
4. "Extracted Text from PDFs" section remains hidden
```

### Scenario 3: Copy Extracted Text
```
1. User expands extracted text card
   ↓
2. Reads the extracted content
   ↓
3. Clicks [📋 Copy] button
   ↓
4. Text copied to system clipboard
   ↓
5. Snackbar notification shows:
   "Text copied to clipboard"
```

### Scenario 4: Delete Document
```
1. User clicks [🗑️] on document card
   ↓
2. Delete confirmation dialog appears
   ↓
3. User confirms deletion
   ↓
4. Document removed from both lists:
   - "Uploaded Documents"
   - "Extracted Text from PDFs" (if applicable)
   ↓
5. Success snackbar: "Document deleted"
```

## Responsive Behavior

### Mobile Layout
- Full width utilization
- Single column layout
- Touch-friendly button sizes
- Collapsible cards for space efficiency
- Scrollable text area with fixed height

### Tablet Layout
- Same as mobile (Material Design responsive)
- Proper padding and margins maintained
- Touch targets remain 48dp minimum

## Accessibility Features

✅ **Included:**
- High contrast colors
- Large, readable fonts
- Proper semantic structure
- Touch-friendly buttons
- Clear icons with labels
- SelectableText for text extraction

⚠️ **Future Improvements:**
- Semantic labels for screen readers
- ARIA labels for web platform
- Keyboard navigation support

## Animation & Feedback

| Action | Feedback |
|--------|----------|
| Upload PDF | Progress bar animation (0-100%) |
| Expand text | ExpansionTile expansion animation |
| Copy text | Snackbar toast notification |
| Delete doc | Dialog confirmation, then snackbar |
| Hover (web) | Button color change |

## Error States

### PDF Extraction Fails
```
┌────────────────────────────────────────┐
│ Uploaded Documents                     │
├────────────────────────────────────────┤
│ ┌──────────────────────────────────┐   │
│ │ 📄 │ scan.pdf              [🗑️]  │   │
│ │    │ 3.2 MB • 5/3/2026             │   │
│ └──────────────────────────────────┘   │
└────────────────────────────────────────┘

Note: scan.pdf doesn't appear in 
"Extracted Text from PDFs" (image-based PDF)
```

### Empty Extracted Text
- If extraction returns empty string, document is not shown
- "Extracted Text from PDFs" section hidden if no PDFs have text

## Performance Indicators

- Upload progress: 0-100% with visual bar
- Extraction happens silently in background
- No blocking of UI during processing
- Snackbar notifications for completion

---

**Visual Design System**: Material Design 3
**Color Scheme**: Consistent with App Theme
**Responsive**: Mobile-first approach

