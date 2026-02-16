# Research: Photo Album Organizer

**Feature**: Photo Album Organizer  
**Branch**: 001-photo-albums  
**Date**: 2026-02-16

## Overview

This document captures research findings and technical decisions for implementing a client-side photo album organizer using Vite, vanilla JavaScript, and SQLite.

## Key Technical Decisions

### 1. Client-Side Storage Strategy

**Decision**: Use IndexedDB for photo blobs + sql.js for metadata

**Rationale**:
- sql.js provides SQLite API in browser via WebAssembly
- SQLite excellent for relational data (albums, photos, many-to-many relationships)
- IndexedDB better for large binary blobs (photos) than SQLite BLOB columns
- Hybrid approach: SQLite for metadata, IndexedDB for actual image files
- Both are persistent and work offline

**Alternatives Considered**:
- **LocalStorage**: Too limited (5-10MB limit), no structured queries
- **sql.js BLOB columns**: Slower for large files; entire DB must load into memory
- **Pure IndexedDB**: Possible but requires manual relationship management; SQLite provides better query capabilities

**Implementation Notes**:
- Use sql.js-httpvfs for lazy loading database pages (better memory)
- IndexedDB object store keyed by photo UUID
- SQLite stores photo UUID foreign keys

### 2. Photo Storage Format

**Decision**: Store original files + generate thumbnails

**Rationale**:
- Store original File/Blob in IndexedDB for full-size view
- Generate thumbnails (200px wide) using Canvas API for tile view
- Thumbnails reduce memory pressure when rendering 100+ photos
- Lazy load full-size only when user clicks

**Alternatives Considered**:
- **Original only**: Would work but heavy memory usage for tile view
- **Thumbnail only**: Loses quality for full-size view
- **Multiple sizes**: Over-engineering for this use case

**Implementation Notes**:
- Canvas API: `canvas.toBlob()` with quality 0.8
- Store thumbnails in separate IndexedDB object store
- Thumbnail generation happens during photo upload

### 3. File Type Validation

**Decision**: Client-side validation using MIME type + file extension

**Rationale**:
- Spec requires JPEG, PNG, GIF, WebP support
- Check both `file.type` (MIME) and extension (filename)
- Both checks needed (MIME can be spoofed, extension can be wrong)
- Reject files >10MB per spec (SC-004)

**Allowed Types**:
```javascript
const ALLOWED_MIMES = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
const ALLOWED_EXTS = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
```

**Alternatives Considered**:
- **Magic number validation**: Read file header bytes; more secure but overkill for client-side personal app
- **Image load test**: Try to load as `<img>`; good but slower (async)

**Implementation Notes**:
- Validate in `validation.js` before accepting upload
- Display user-friendly error if file rejected
- File size check: `file.size <= 10 * 1024 * 1024`

### 4. Database Schema Design

**Decision**: Three tables: albums, photos, album_photos (junction)

**Rationale**:
- Albums: id, name, date, created_at, display_order
- Photos: id (UUID), filename, file_size, width, height, upload_date, indexeddb_key
- album_photos: album_id, photo_id (many-to-many)
- Allows photos in multiple albums without duplication (per spec assumption)
- display_order enables custom album ordering (for future drag-drop feature)

**Alternatives Considered**:
- **One-to-many**: Photo belongs to one album; rejected because spec says photos can be in multiple albums
- **Embedded JSON**: Store photo IDs as JSON array in albums table; rejected because no relational queries

**Implementation Notes**:
- Use INTEGER PRIMARY KEY for albums (auto-increment)
- Use TEXT PRIMARY KEY (UUID) for photos (stable across IndexedDB)
- Index on album_photos(album_id) for fast photo retrieval
- Index on albums(date) for date grouping

### 5. Date Grouping Strategy

**Decision**: Group albums by ISO date string (YYYY-MM-DD), sort by date descending

**Rationale**:
- Spec requires "albums grouped by date"
- Display newest albums first (more intuitive)
- SQL: `SELECT * FROM albums ORDER BY date DESC, display_order ASC`
- Client groups consecutive same-date albums in UI

**Alternatives Considered**:
- **Group by month/year**: Spec says "by date" not "by period"
- **Oldest first**: Less common for photo apps

**Implementation Notes**:
- Store date as TEXT in ISO format (YYYY-MM-DD)
- Use `date-utils.js` to format dates for display
- Grouping logic in home page component

### 6. Responsive Tile Layout

**Decision**: CSS Grid with `auto-fit` and fixed column width

**Rationale**:
- CSS Grid `auto-fit` automatically calculates columns based on viewport
- Set min column width (e.g., 150px) and Grid handles responsive layout
- Maintain aspect ratio using `aspect-ratio` CSS property
- No JavaScript needed for layout (performance)

**CSS Pattern**:
```css
.photo-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 1rem;
}
```

**Alternatives Considered**:
- **Flexbox**: Works but Grid better for 2D layouts
- **JavaScript masonry**: Overkill and performance cost
- **Fixed columns**: Not responsive

**Implementation Notes**:
- Use `object-fit: cover` for thumbnail images
- Let aspect ratio vary per spec (FR-013)

### 7. Routing Strategy

**Decision**: Hash-based routing (no server needed)

**Rationale**:
- `#/` - home (album list)
- `#/album/:id` - album detail (photo tiles)
- Works without server configuration
- Simple router in ~50 lines of vanilla JS
- Browser back/forward works naturally

**Alternatives Considered**:
- **History API**: Requires server config for SPA; rejected because spec is client-only
- **No routing**: Single page with show/hide; rejected because harder to share album links

**Implementation Notes**:
- Listen to `hashchange` event
- Simple regex-based route matching
- Router in `ui/utils/router.js`

### 8. Testing Strategy

**Decision**: Vitest with mocked File/Blob/IndexedDB APIs

**Rationale**:
- Vitest ships with Vite (zero config)
- Fast, Jest-compatible API
- Mock File API using `new File([], 'test.jpg', {type: 'image/jpeg'})`
- Mock IndexedDB using `fake-indexeddb` package
- Mock sql.js using in-memory database

**Test Coverage Plan**:
- **Unit**: validation.js, date-utils.js, service layer
- **Integration**: Full workflow from album creation to photo add
- **Contract**: Database schema tests, IndexedDB key formats

**Alternatives Considered**:
- **Jest**: Requires more config than Vitest
- **Playwright**: Overkill for this app; no complex UI interactions

**Implementation Notes**:
- Use `beforeEach` to reset database state
- Test file: `tests/setup.js` initializes mocks
- Run tests with `npm run test`

### 9. Performance Optimizations

**Decision**: Lazy load photos + thumbnail caching + virtual scrolling

**Rationale**:
- Lazy load: Only fetch/render photos in viewport
- Thumbnails cached in IndexedDB (don't regenerate)
- Virtual scrolling if album has >50 photos (IntersectionObserver)
- Meets SC-002 (100 photos smooth render)

**Implementation Notes**:
- Use IntersectionObserver for lazy load
- Cache thumbnails by photo UUID
- Debounce scroll events

### 10. Accessibility Requirements

**Decision**: Keyboard navigation + ARIA labels + focus management

**Keyboard Shortcuts**:
- Tab/Shift+Tab: Navigate between albums/photos
- Enter/Space: Open album or view photo
- Escape: Close modal/photo view
- Arrow keys: Navigate within photo grid

**ARIA Labels**:
- Album cards: `aria-label="Album: {name}, Date: {date}, {count} photos"`
- Photo tiles: `aria-label="Photo: {filename}"`
- Modal: `role="dialog"`, `aria-modal="true"`

**Focus Management**:
- Trap focus in modal when open
- Return focus to trigger element on modal close
- Visible focus indicators (outline)

## Dependencies

### Production
- **vite**: ^5.0.0 (build tool, dev server)
- **sql.js**: ^1.10.0 (SQLite in browser)

### Development
- **vitest**: ^1.0.0 (test runner)
- **fake-indexeddb**: ^5.0.0 (IndexedDB mock for tests)

## Browser Compatibility

**Minimum Requirements**:
- Chrome 90+ (May 2021)
- Firefox 88+ (April 2021)
- Safari 14+ (September 2020)
- Edge 90+ (May 2021)

**Required APIs**:
- ES2022 features (const, arrow functions, async/await, optional chaining)
- CSS Grid (all modern browsers)
- File API (all modern browsers)
- IndexedDB (all modern browsers)
- WebAssembly (for sql.js, all modern browsers)
- Canvas API (for thumbnails, all modern browsers)

## Security Considerations

**Client-Side Only**:
- No server = no server vulnerabilities
- Photos never transmitted over network
- All data stays in browser storage

**Input Validation**:
- File type validation (MIME + extension)
- File size limits (10MB)
- Sanitize album names (prevent XSS in innerHTML)

**XSS Prevention**:
- Use `textContent` not `innerHTML` for user input
- If HTML needed, sanitize with DOMPurify (add if needed)

## Open Questions

None - all technical decisions resolved based on user constraints:
- Vite ✅
- Vanilla JS ✅
- SQLite (sql.js) ✅
- No photo upload (local only) ✅
- Minimal dependencies ✅
