# iOS Search Field Best Practices

This document outlines Apple Human Interface Guidelines (HIG) best practices for implementing search in iOS applications, as implemented in the `CNSearchField` component.

## Apple HIG Best Practices

### 1. Use Descriptive Placeholder Text

**❌ Don't:**
```dart
CNSearchField(placeholder: 'Search')
```

**✅ Do:**
```dart
CNSearchField(placeholder: 'Shows, Movies, and More')
CNSearchField(placeholder: 'Search in Mail')
CNSearchField(placeholder: 'Songs, Albums, Artists')
```

**Why:** Descriptive placeholder text helps users understand what type of information they can search for, making the search experience more intuitive.

### 2. Search Immediately as User Types

**✅ Enabled by default:**
```dart
CNSearchField(
  searchImmediately: true, // This is the default
  onChanged: (text) => performSearch(text),
)
```

**Why:** Immediate search makes the experience feel more responsive and provides continuously refined results as the text becomes more specific.

### 3. Show Suggested Search Terms

**✅ Display suggestions:**
```dart
CNSearchField(
  showSuggestions: true,
  suggestions: [
    'From: John Doe',
    'Subject: Meeting',
    'Has Attachments',
    'Flagged',
    'Unread',
  ],
  onSuggestionTapped: (suggestion) => searchFor(suggestion),
)
```

**Why:** Suggestions help users search faster by showing common search terms, even when the search doesn't begin immediately.

### 4. Provide Scope Controls for Filtering

**✅ Add scope options:**
```dart
CNSearchField(
  scopeOptions: ['All Mailboxes', 'Current Mailbox'],
  selectedScope: 0,
  onScopeChanged: (scope) => updateSearchScope(scope),
)
```

**Why:** Scope controls help users narrow their search from a broader scope to a more specific one, like filtering from all mailboxes to just the current one.

### 5. Simplify Search Results

- Provide the most relevant results first
- Consider categorizing results
- Minimize the need for scrolling

### 6. Consider Voice Search Support

**✅ Add microphone button:**
```dart
CNSearchField(
  showMicButton: true,
  onMicPressed: () => startVoiceSearch(),
)
```

## Search Placement Options (Apple HIG)

### 1. Search in a Tab Bar
Place search as a visually distinct tab on the trailing side of a tab bar. This keeps search visible and always available as people switch between sections.

**Use cases:**
- Apps with multiple main sections
- When search should be always accessible
- Example: Apple Music, App Store

### 2. Search in a Toolbar

#### Bottom Toolbar
- Can be an expanded field or a toolbar button
- Animates into a search field above the keyboard
- **Use when:** Search is a priority and there's room at the bottom
- **Examples:** Settings, Mail, Notes

#### Top Toolbar (Navigation Bar)
- Appears as a toolbar button
- Animates into a search field (above keyboard or inline at top)
- **Use when:** Need to defer to content at the bottom or there's no bottom toolbar
- **Examples:** Wallet app

### 3. Search as an Inline Field
Place search directly next to the content it searches.

**Use when:**
- Searching within a single view
- The position alongside content strengthens their relationship
- Filtering a subset of content
- **Example:** Music app library filtering

## Component Features

### CNSearchField

A standalone iOS-style search field that follows all Apple HIG best practices.

```dart
CNSearchField(
  placeholder: 'Shows, Movies, and More',
  showSuggestions: true,
  suggestions: ['Popular', 'New Releases', 'Trending'],
  scopeOptions: ['All', 'Movies', 'TV Shows'],
  showMicButton: true,
  searchImmediately: true,
  onChanged: (text) => performSearch(text),
  onSuggestionTapped: (suggestion) => searchFor(suggestion),
  onScopeChanged: (scope) => updateScope(scope),
)
```

**Features:**
- ✅ Descriptive placeholder text
- ✅ Immediate search as user types
- ✅ Search suggestions
- ✅ Scope control integration
- ✅ Voice search support
- ✅ Clear button
- ✅ Focus state management

### CNTransformingToolbar

A bottom toolbar that transforms between search mode and tab bar mode, following the Apple HIG pattern for search in a tab bar.

```dart
CNTransformingToolbar(
  leadingIcon: CupertinoIcons.square_grid_2x2,
  searchPlaceholder: 'Shows, Movies, and More',
  trailingAction: Icon(CupertinoIcons.mic),
  showSuggestions: true,
  suggestions: ['Popular', 'New Releases'],
  scopeOptions: ['All', 'Movies', 'TV Shows'],
  tabs: [
    ToolbarTab(label: 'Home', icon: CupertinoIcons.house_fill),
    ToolbarTab(label: 'Browse', icon: CupertinoIcons.square_grid_2x2),
  ],
  onTabSelected: (index) => switchTab(index),
)
```

**States:**
- **Unfocused:** Shows icon + search field + trailing action
- **Focused:** Shows full tab bar + search button on trailing edge

## Examples

### Example 1: Mail-style Search

```dart
CNSearchField(
  placeholder: 'Search in Mail',
  showSuggestions: true,
  suggestions: [
    'From: John Doe',
    'Subject: Meeting',
    'Contains: Project',
    'Has Attachments',
    'Flagged',
    'Unread',
  ],
  scopeOptions: ['All Mailboxes', 'Current Mailbox'],
  showMicButton: true,
  onChanged: (text) => searchEmails(text),
)
```

### Example 2: Media App Search

```dart
CNTransformingToolbar(
  leadingIcon: CupertinoIcons.square_grid_2x2,
  searchPlaceholder: 'Shows, Movies, and More',
  trailingAction: Icon(CupertinoIcons.mic),
  showSuggestions: true,
  suggestions: ['Popular', 'New Releases', 'Trending', 'My List'],
  scopeOptions: ['All', 'Movies', 'TV Shows', 'Sports'],
  tabs: [
    ToolbarTab(label: 'Home', icon: CupertinoIcons.house_fill),
    ToolbarTab(label: 'Browse', icon: CupertinoIcons.square_grid_2x2),
    ToolbarTab(label: 'Library', icon: CupertinoIcons.folder_fill),
  ],
)
```

### Example 3: Settings-style Search

```dart
CNSearchField(
  placeholder: 'Search Settings',
  searchImmediately: true,
  onChanged: (text) => filterSettings(text),
)
```

## Anti-Patterns to Avoid

### ❌ Generic Placeholder Text
```dart
// Don't use generic text like "Search"
CNSearchField(placeholder: 'Search')
```

### ❌ Delayed Search Without Reason
```dart
// Don't disable immediate search unless there's a good reason
CNSearchField(
  searchImmediately: false, // Usually avoid this
  onChanged: (text) => ...,
)
```

### ❌ Missing Scope Control for Complex Searches
```dart
// For complex searches (like Mail), always provide scope
CNSearchField(
  placeholder: 'Search in Mail',
  // Missing: scopeOptions: ['All Mailboxes', 'Current Mailbox']
)
```

### ❌ Not Providing Suggestions
```dart
// When appropriate, always show suggestions
CNSearchField(
  placeholder: 'Shows, Movies, and More',
  // Missing: showSuggestions, suggestions list
)
```

## Implementation Checklist

When implementing search in your app, ensure:

- [ ] Placeholder text describes what can be searched
- [ ] Search begins immediately as user types (unless there's a good reason not to)
- [ ] Suggestions are displayed when appropriate
- [ ] Scope controls are provided for complex searches
- [ ] Most relevant results appear first
- [ ] Results are categorized when appropriate
- [ ] Clear button is visible when there's text
- [ ] Voice search is supported (when appropriate)
- [ ] Focus states are properly managed
- [ ] Keyboard dismisses appropriately

## Resources

- [Apple HIG - Search](https://developer.apple.com/design/human-interface-guidelines/search)
- [Apple HIG - iOS Search Patterns](https://developer.apple.com/design/human-interface-guidelines/search#iOS)
