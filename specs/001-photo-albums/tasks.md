# Tasks: Photo Album Organizer

**Input**: Design documents from `/specs/001-photo-albums/`
**Prerequisites**: plan.md, spec.md, data-model.md, contracts/, research.md, quickstart.md

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

## Path Conventions

- **Single project**: `src/`, `tests/` at repository root
- Paths shown below use single project structure per plan.md

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create project directory structure (src/, tests/, public/) per plan.md
- [ ] T002 Initialize package.json with project metadata
- [ ] T003 [P] Install Vite and Vitest in package.json devDependencies
- [ ] T004 [P] Install sql.js in package.json dependencies
- [ ] T005 [P] Install fake-indexeddb in package.json devDependencies for test mocks
- [ ] T006 [P] Create vite.config.js with dev server and build configuration
- [ ] T007 [P] Create vitest.config.js with jsdom environment and test setup
- [ ] T008 [P] Create tests/setup.js with IndexedDB and crypto.randomUUID mocks
- [ ] T009 [P] Add npm scripts to package.json (dev, build, test, test:watch, test:coverage)
- [ ] T010 [P] Download sql-wasm.wasm to public/ directory
- [ ] T011 [P] Create src/index.html with SPA shell and noscript fallback message
- [ ] T012 [P] Create src/styles/base.css with CSS reset, variables, and typography
- [ ] T013 [P] Create src/styles/components.css placeholder file
- [ ] T014 [P] Create src/styles/layouts.css with CSS Grid responsive layout patterns

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T015 Write test for database initialization in tests/contract/database-schema.test.js
- [ ] T016 Implement database initialization in src/db/init.js with SQLite schema from contracts/database-schema.sql
- [ ] T017 [P] Implement database query functions in src/db/queries.js for albums, photos, and album_photos tables
- [ ] T018 [P] Create validation utility in src/lib/validation.js for file type and size checking
- [ ] T019 [P] Create date utility in src/lib/date-utils.js for date formatting and grouping logic
- [ ] T020 Write test for storage service initialization in tests/contract/storage-api.test.js
- [ ] T021 Implement IndexedDB initialization and photo storage in src/services/storage-service.js
- [ ] T022 Implement thumbnail generation function in src/services/storage-service.js using Canvas API
- [ ] T023 [P] Create DOM utility helpers in src/ui/utils/dom.js for element creation and manipulation
- [ ] T024 [P] Create hash-based router in src/ui/utils/router.js for navigation between home and album views
- [ ] T025 Create main entry point in src/main.js that initializes database, storage, and router

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Create and View Albums (Priority: P1) 🎯 MVP

**Goal**: Users can create albums, add photos to them, and view photos in a tile interface

**Independent Test**: Create a new album with a name and date, add photos to it, open the album to view photos in tile grid, click a photo to view full-size

### Tests for User Story 1 (TDD - Test First!)

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T026 [P] [US1] Write contract test for album CRUD operations in tests/contract/database-schema.test.js
- [ ] T027 [P] [US1] Write unit test for album service in tests/unit/album-service.test.js
- [ ] T028 [P] [US1] Write unit test for photo service in tests/unit/photo-service.test.js
- [ ] T029 [P] [US1] Write unit test for validation logic in tests/unit/validation.test.js
- [ ] T030 [P] [US1] Write unit test for date utilities in tests/unit/date-utils.test.js
- [ ] T031 [US1] Write integration test for album creation workflow in tests/integration/album-workflow.test.js

### Implementation for User Story 1

- [ ] T032 [P] [US1] Implement album service with create, read, delete methods in src/services/album-service.js
- [ ] T033 [P] [US1] Implement photo service with addToAlbum and getPhotosInAlbum methods in src/services/photo-service.js
- [ ] T034 [US1] Create album form component in src/ui/components/album-form.js with name and date inputs
- [ ] T035 [US1] Create album card component in src/ui/components/album-card.js displaying album name, date, and photo count
- [ ] T036 [US1] Create photo tile component in src/ui/components/photo-tile.js with lazy-loaded thumbnail
- [ ] T037 [US1] Create photo modal component in src/ui/components/photo-modal.js for full-size photo view with keyboard navigation
- [ ] T038 [US1] Implement home page in src/ui/pages/home.js showing albums grouped by date
- [ ] T039 [US1] Implement album view page in src/ui/pages/album-view.js displaying photo tile grid
- [ ] T040 [US1] Add album card styles to src/styles/components.css with BEM naming
- [ ] T041 [US1] Add photo tile grid styles to src/styles/components.css with responsive CSS Grid
- [ ] T042 [US1] Add photo modal styles to src/styles/components.css with overlay and focus trap
- [ ] T043 [US1] Add empty album message handling in src/ui/pages/album-view.js per FR-010
- [ ] T044 [US1] Add ARIA labels and keyboard navigation to album cards per constitution accessibility requirements
- [ ] T045 [US1] Add ARIA labels and keyboard navigation to photo tiles and modal

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Add and Remove Photos (Priority: P1)

**Goal**: Users can populate albums with photos from their device and remove unwanted photos

**Independent Test**: Open an album, select photos from device, verify they appear in tile view, select photos to remove, verify they disappear from album

### Tests for User Story 2 (TDD - Test First!)

- [ ] T046 [P] [US2] Write unit test for photo add/remove in tests/unit/photo-service.test.js
- [ ] T047 [P] [US2] Write contract test for storage service file operations in tests/contract/storage-api.test.js
- [ ] T048 [US2] Write integration test for photo add/remove workflow in tests/integration/photo-workflow.test.js

### Implementation for User Story 2

- [ ] T049 [P] [US2] Extend photo service with addPhotosToAlbum (batch) method in src/services/photo-service.js
- [ ] T050 [P] [US2] Extend photo service with removePhotoFromAlbum method in src/services/photo-service.js
- [ ] T051 [US2] Implement orphan photo cleanup logic in src/services/photo-service.js (delete photo if not in any album)
- [ ] T052 [US2] Add file input component to src/ui/pages/album-view.js with multiple file selection
- [ ] T053 [US2] Add file upload progress indicator to src/ui/pages/album-view.js per FR-008
- [ ] T054 [US2] Add photo selection UI (checkboxes) to src/ui/components/photo-tile.js for batch operations
- [ ] T055 [US2] Add remove photos button to src/ui/pages/album-view.js with confirmation dialog
- [ ] T056 [US2] Implement file type validation using src/lib/validation.js before upload per FR-009
- [ ] T057 [US2] Implement file size validation (10MB limit) per FR-009 with user-friendly error message
- [ ] T058 [US2] Add error handling for invalid file types with toast notification
- [ ] T059 [US2] Add error handling for file size violations with toast notification
- [ ] T060 [US2] Style file upload UI in src/styles/components.css with upload button and progress bar
- [ ] T061 [US2] Style photo selection checkboxes in src/styles/components.css
- [ ] T062 [US2] Add keyboard shortcuts for photo selection (Shift+click for range, Ctrl+click for individual)

**Checkpoint**: All P1 user stories complete - MVP is now functional

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T063 [P] Add loading spinner component in src/ui/components/loading-spinner.js
- [ ] T064 [P] Add toast notification component in src/ui/components/toast.js for user feedback
- [ ] T065 [P] Implement lazy loading for photo tiles using IntersectionObserver in src/ui/components/photo-tile.js
- [ ] T066 [P] Implement virtual scrolling for albums with >50 photos in src/ui/pages/album-view.js
- [ ] T067 [P] Add performance tracking using Performance API in src/main.js
- [ ] T068 [P] Create strings object for i18n-ready UI text in src/lib/strings.js
- [ ] T069 [P] Add JSDoc comments to all service functions per constitution code quality standards
- [ ] T070 [P] Add JSDoc comments to all UI component functions
- [ ] T071 [P] Add focus trap implementation to photo modal in src/ui/components/photo-modal.js
- [ ] T072 [P] Add keyboard shortcut for closing modal (Escape key) in src/ui/components/photo-modal.js
- [ ] T073 [P] Test responsive layouts on mobile (320px), tablet (768px), and desktop (1920px) breakpoints
- [ ] T074 [P] Test accessibility with screen reader (VoiceOver/NVDA)
- [ ] T075 [P] Test keyboard navigation through all interactive elements
- [ ] T076 [P] Create README.md with setup instructions, usage, and architecture overview
- [ ] T077 Run test suite (npm run test) and ensure all tests pass
- [ ] T078 Run test coverage report (npm run test:coverage) and verify >80% coverage
- [ ] T079 Build production bundle (npm run build) and verify no errors
- [ ] T080 Test production build (npm run preview) in browser

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational phase completion
- **User Story 2 (Phase 4)**: Depends on Foundational phase completion (can run parallel with US1 if staffed)
- **Polish (Phase 5)**: Depends on User Story 1 and 2 completion

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) - Requires album view from US1 but should be independently testable

### Within Each User Story

- Tests (TDD) MUST be written and FAIL before implementation
- Services before UI components
- UI components before page integration
- Core implementation before polish features
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, User Story 1 and 2 can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Models/services within a story marked [P] can run in parallel

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together (TDD - write failing tests first):
Task T026: "Write contract test for album CRUD operations in tests/contract/database-schema.test.js"
Task T027: "Write unit test for album service in tests/unit/album-service.test.js"
Task T028: "Write unit test for photo service in tests/unit/photo-service.test.js"
Task T029: "Write unit test for validation logic in tests/unit/validation.test.js"
Task T030: "Write unit test for date utilities in tests/unit/date-utils.test.js"

# Launch all service implementations together (after tests fail):
Task T032: "Implement album service with create, read, delete methods in src/services/album-service.js"
Task T033: "Implement photo service with addToAlbum and getPhotosInAlbum methods in src/services/photo-service.js"
```

---

## Implementation Strategy

### MVP First (User Stories 1 & 2 Only - Both P1)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (Create and View Albums)
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Complete Phase 4: User Story 2 (Add and Remove Photos)
6. **STOP and VALIDATE**: Test User Story 2 independently
7. Complete Phase 5: Polish
8. Deploy/demo MVP

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP core!)
3. Add User Story 2 → Test independently → Deploy/Demo (MVP complete!)
4. Add Polish features → Deploy/Demo (production ready)
5. Each increment adds value without breaking previous functionality

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1 (tests → services → UI)
   - Developer B: User Story 2 (tests → services → UI)
3. Stories complete and integrate independently
4. Team collaborates on Polish phase

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- **TDD REQUIRED**: Tests MUST fail before implementing per constitution testing standards
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence

---

## Task Count Summary

- **Setup (Phase 1)**: 14 tasks
- **Foundational (Phase 2)**: 11 tasks (BLOCKING)
- **User Story 1 (Phase 3)**: 20 tasks (6 tests + 14 implementation)
- **User Story 2 (Phase 4)**: 17 tasks (3 tests + 14 implementation)
- **Polish (Phase 5)**: 18 tasks
- **Total**: 80 tasks

### Parallel Opportunities

- Setup: 13 of 14 tasks parallelizable
- Foundational: 6 of 11 tasks parallelizable
- User Story 1: 5 tests + 2 services parallelizable within phase
- User Story 2: 2 tests + 2 services parallelizable within phase
- Polish: 15 of 18 tasks parallelizable

### Suggested MVP Scope

**Minimum Viable Product** (User Stories 1 & 2):
- Create albums with name and date
- View albums grouped by date on home page
- Add photos to albums from device
- View photos in responsive tile grid
- View photos full-size in modal
- Remove photos from albums
- File validation and error handling

**Total MVP Tasks**: 62 tasks (Setup + Foundational + US1 + US2)
**Estimated MVP Completion**: ~3-5 days for single developer with TDD

---

## Format Validation ✅

All tasks follow required checklist format:
- ✅ Checkbox: `- [ ]` prefix on all tasks
- ✅ Task ID: Sequential T001-T080
- ✅ [P] marker: Present on parallelizable tasks only
- ✅ [Story] label: Present on user story tasks (US1, US2)
- ✅ Description: Clear action with file path
- ✅ No story label on Setup, Foundational, or Polish phases

**Tasks are immediately executable** - each includes specific file paths and clear implementation guidance from design documents.
