# Implementation Plan: Photo Album Organizer

**Branch**: `001-photo-albums` | **Date**: 2026-02-16 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-photo-albums/spec.md`

## Summary

Build a single-user web application for organizing photos into date-grouped albums with tile-based viewing. The application uses Vite with vanilla HTML, CSS, and JavaScript. Photos remain local on the user's device and are not uploaded to any server. Album and photo metadata is stored in a local SQLite database for persistence.

## Technical Context

**Language/Version**: JavaScript ES2022+ (vanilla)  
**Primary Dependencies**: Vite (build tool), sql.js (SQLite for browser)  
**Storage**: SQLite (in-browser via sql.js) for metadata; photos stored as File objects with FileReader API  
**Testing**: Vitest (ships with Vite, minimal config)  
**Target Platform**: Modern web browsers (Chrome 90+, Firefox 88+, Safari 14+, Edge 90+)  
**Project Type**: Single web application  
**Performance Goals**: 
- Tile view renders 100 photos in <500ms
- Photo selection/full view in <1 second
- Database queries in <100ms
**Constraints**: 
- Client-side only (no backend server)
- Photos never leave user's device
- Must work offline after initial load
- Support files up to 10MB per spec
**Scale/Scope**: 
- Single user per browser/device
- Support up to 1000 photos across albums
- Up to 100 albums

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### I. Code Quality Standards
- ✅ **Consistency**: Use consistent ES6+ patterns, CSS naming conventions (BEM), HTML semantic structure
- ✅ **Simplicity**: Minimal dependencies (Vite + sql.js only); vanilla JS avoids framework complexity
- ✅ **Documentation**: JSDoc for all functions; README with setup and usage
- ✅ **Type Safety**: JSDoc type annotations for IDE support (no TypeScript to keep simple)
- ✅ **Error Handling**: Try-catch for file operations, DB operations; user-friendly error messages
- ✅ **Security**: No secrets (client-only); validate file types and sizes; sanitize user inputs

### II. Testing Standards (NON-NEGOTIABLE)
- ✅ **Test-First Development**: Write Vitest tests before implementation
- ✅ **Coverage Expectations**:
  - Unit tests: Database service, photo service, validation logic
  - Integration tests: Album creation flow, photo add/remove flow
  - Contract tests: Database schema migrations, LocalStorage contracts
- ✅ **Test Quality**: Vitest provides fast, isolated tests; use mocks for File API
- ✅ **Test Organization**: tests/unit/, tests/integration/, tests/contract/
- ✅ **Continuous Validation**: npm run test before commits

### III. User Experience Consistency
- ✅ **Design Patterns**: CSS Grid for tile layout; consistent card components for albums
- ✅ **Accessibility**: Keyboard navigation, ARIA labels, focus management, alt text for photos
- ✅ **Feedback**: Loading spinners during photo processing; progress bars for batch operations; toast notifications
- ⚠️ **Progressive Enhancement**: Requires JavaScript for core functionality (SQLite, File API); fallback message for no-JS
- ✅ **Responsive Design**: CSS Grid auto-fit for tiles; mobile-first breakpoints (320px, 768px, 1024px, 1920px)
- ✅ **Internationalization Ready**: Separate strings object for all UI text

### IV. Performance Requirements
- ✅ **Response Time**: IndexedDB for photo blob storage (faster than sql.js for large blobs); lazy loading for tiles
- ✅ **Resource Efficiency**: Virtual scrolling for albums with >50 photos; thumbnail generation to reduce memory
- ✅ **Scalability**: Indexed DB queries; pagination for album lists if >100 albums
- ✅ **Measurement**: Performance API to track render times; console warnings if thresholds exceeded
- ✅ **Optimization Strategy**: Profile with Chrome DevTools; optimize tile rendering first (critical path)

### Quality Gates Status
1. ✅ Constitution Compliance: All principles addressed
2. ✅ Test Coverage: Strategy defined for unit/integration/contract
3. ✅ Code Review: Will verify vanilla JS patterns, minimal dependencies
4. ✅ Performance Validation: Metrics defined (SC-002, SC-004, SC-006)
5. ✅ Accessibility Check: Keyboard nav, ARIA, focus management planned

### ⚠️ Progressive Enhancement Note
**Justification for Complexity**: Core functionality (SQLite, File API, Canvas for thumbnails) requires JavaScript. A no-JS fallback would require a completely different architecture (server-side). Per spec, this is a single-user web app, so JS requirement is acceptable. Fallback will display a clear message directing users to enable JavaScript.

## Project Structure

### Documentation (this feature)

```text
specs/001-photo-albums/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
│   ├── database-schema.sql
│   └── file-storage-api.md
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
src/
├── db/
│   ├── init.js          # SQLite initialization and migrations
│   └── queries.js       # All database queries
├── services/
│   ├── album-service.js # Album CRUD operations
│   ├── photo-service.js # Photo add/remove/retrieve
│   └── storage-service.js # File/IndexedDB storage abstraction
├── ui/
│   ├── components/
│   │   ├── album-card.js
│   │   ├── photo-tile.js
│   │   ├── photo-modal.js
│   │   └── album-form.js
│   ├── pages/
│   │   ├── home.js      # Album list page
│   │   └── album-view.js # Photo tile view page
│   └── utils/
│       ├── router.js    # Hash-based routing
│       └── dom.js       # DOM manipulation helpers
├── lib/
│   ├── validation.js    # File type/size validation
│   └── date-utils.js    # Date grouping logic
├── styles/
│   ├── base.css         # Reset, variables, typography
│   ├── components.css   # Component-specific styles
│   └── layouts.css      # Grid, responsive layouts
├── main.js              # App entry point
└── index.html           # SPA shell

tests/
├── contract/
│   ├── database-schema.test.js
│   └── storage-api.test.js
├── integration/
│   ├── album-workflow.test.js
│   └── photo-workflow.test.js
└── unit/
    ├── album-service.test.js
    ├── photo-service.test.js
    ├── validation.test.js
    └── date-utils.test.js

public/
└── sql-wasm.wasm        # SQLite WebAssembly binary
```

**Structure Decision**: Single web application structure (Option 1) with UI separation. Since this is a client-side only application with no backend, we use a single src/ directory with clear separation between database layer (db/), business logic (services/), and UI (ui/). The lib/ folder contains pure utility functions that are framework-agnostic.

## Complexity Tracking

> No violations detected. Progressive Enhancement partial compliance is justified above.
