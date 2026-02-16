# Data Model: Photo Album Organizer

**Feature**: Photo Album Organizer  
**Branch**: 001-photo-albums  
**Date**: 2026-02-16

## Overview

This document defines the data model for the photo album organizer, including SQLite schema for metadata and IndexedDB structure for photo storage.

## Entity Relationships

```
┌─────────────┐         ┌──────────────────┐         ┌─────────────┐
│   albums    │         │  album_photos    │         │   photos    │
├─────────────┤         ├──────────────────┤         ├─────────────┤
│ id (PK)     │────────<│ album_id (FK)    │>────────│ id (PK)     │
│ name        │         │ photo_id (FK)    │         │ filename    │
│ date        │         │ created_at       │         │ file_size   │
│ created_at  │         └──────────────────┘         │ width       │
│ display_ord │                                       │ height      │
└─────────────┘                                       │ upload_date │
                                                      │ idb_key     │
                                                      └─────────────┘
                                                            │
                                                            │ references
                                                            ▼
                                                   ┌──────────────────┐
                                                   │   IndexedDB      │
                                                   │  "photo-files"   │
                                                   ├──────────────────┤
                                                   │ key: photo.id    │
                                                   │ value: {         │
                                                   │   original: Blob │
                                                   │   thumbnail: Blob│
                                                   │ }                │
                                                   └──────────────────┘
```

## SQLite Schema

### Table: albums

Stores album metadata.

```sql
CREATE TABLE IF NOT EXISTS albums (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  date TEXT NOT NULL,  -- ISO format: YYYY-MM-DD
  created_at TEXT NOT NULL,  -- ISO 8601: YYYY-MM-DDTHH:MM:SSZ
  display_order INTEGER DEFAULT 0
);

CREATE INDEX idx_albums_date ON albums(date DESC);
CREATE INDEX idx_albums_display_order ON albums(display_order ASC);
```

**Fields**:
- `id`: Auto-increment primary key
- `name`: Album name (user-provided, required)
- `date`: Album date in ISO format (YYYY-MM-DD), used for grouping on main page
- `created_at`: Timestamp when album was created (ISO 8601)
- `display_order`: Integer for custom ordering (future drag-drop feature); lower values first

**Validation Rules**:
- `name`: Non-empty string, max 255 characters
- `date`: Valid ISO date format (YYYY-MM-DD)
- `display_order`: Non-negative integer

**Indexes**:
- `idx_albums_date`: Enables fast date-grouped queries
- `idx_albums_display_order`: Enables fast custom-order sorting

### Table: photos

Stores photo metadata. Actual photo files stored in IndexedDB.

```sql
CREATE TABLE IF NOT EXISTS photos (
  id TEXT PRIMARY KEY,  -- UUID v4
  filename TEXT NOT NULL,
  file_size INTEGER NOT NULL,  -- bytes
  width INTEGER,  -- pixels, null until loaded
  height INTEGER,  -- pixels, null until loaded
  upload_date TEXT NOT NULL,  -- ISO 8601: YYYY-MM-DDTHH:MM:SSZ
  idb_key TEXT NOT NULL  -- IndexedDB key (same as id)
);

CREATE INDEX idx_photos_upload_date ON photos(upload_date DESC);
```

**Fields**:
- `id`: UUID v4 string (e.g., "550e8400-e29b-41d4-a716-446655440000")
- `filename`: Original filename from user's device
- `file_size`: File size in bytes (for validation, display)
- `width`: Image width in pixels (nullable; populated after image loads)
- `height`: Image height in pixels (nullable; populated after image loads)
- `upload_date`: Timestamp when photo was added (ISO 8601)
- `idb_key`: Key used to retrieve photo from IndexedDB (always equals `id`)

**Validation Rules**:
- `id`: Valid UUID v4 format
- `filename`: Non-empty string
- `file_size`: Positive integer, max 10485760 (10MB per spec)
- `width`, `height`: Positive integers or NULL
- `idb_key`: Must match `id`

**Indexes**:
- `idx_photos_upload_date`: Enables sorting photos by upload time

### Table: album_photos (Junction Table)

Many-to-many relationship between albums and photos.

```sql
CREATE TABLE IF NOT EXISTS album_photos (
  album_id INTEGER NOT NULL,
  photo_id TEXT NOT NULL,
  created_at TEXT NOT NULL,  -- ISO 8601: when photo added to this album
  PRIMARY KEY (album_id, photo_id),
  FOREIGN KEY (album_id) REFERENCES albums(id) ON DELETE CASCADE,
  FOREIGN KEY (photo_id) REFERENCES photos(id) ON DELETE CASCADE
);

CREATE INDEX idx_album_photos_album ON album_photos(album_id);
CREATE INDEX idx_album_photos_photo ON album_photos(photo_id);
```

**Fields**:
- `album_id`: Foreign key to `albums.id`
- `photo_id`: Foreign key to `photos.id`
- `created_at`: Timestamp when photo was added to album

**Constraints**:
- Primary key on (album_id, photo_id): Prevents duplicate photo in same album
- ON DELETE CASCADE: Deleting album removes its photo associations; deleting photo removes all album associations

**Indexes**:
- `idx_album_photos_album`: Fast lookup of all photos in an album
- `idx_album_photos_photo`: Fast lookup of all albums containing a photo

## IndexedDB Schema

### Object Store: photo-files

Stores original photo files and thumbnails.

**Configuration**:
```javascript
const db = indexedDB.open('photo-album-db', 1);
db.createObjectStore('photo-files', { keyPath: 'id' });
```

**Structure**:
```javascript
{
  id: "550e8400-e29b-41d4-a716-446655440000",  // UUID (matches photos.id)
  original: Blob,  // Original photo file
  thumbnail: Blob  // Generated thumbnail (200px wide, auto height)
}
```

**Fields**:
- `id`: Photo UUID (primary key)
- `original`: Original photo Blob/File (as uploaded by user)
- `thumbnail`: Thumbnail Blob (generated via Canvas API, JPEG quality 0.8)

**Size Constraints**:
- `original`: Max 10MB (10485760 bytes)
- `thumbnail`: Typically 10-50KB (depends on original aspect ratio)

## State Transitions

### Album Lifecycle

```
[Create Album] → Empty Album → [Add Photos] → Album with Photos
                     │                              │
                     │                              │
                     └──────────[Delete Album]──────┘
                              (CASCADE deletes album_photos entries)
```

**States**:
1. **Empty Album**: Album exists with no photos (displays "empty" message per FR-010)
2. **Album with Photos**: Album has one or more photos (displays tile grid)

**Transitions**:
- Create: User fills album form (name, date) → INSERT into albums
- Add Photos: User selects files → INSERT into photos + album_photos
- Remove Last Photo: User removes all photos → Album returns to Empty state
- Delete Album: User deletes album → DELETE from albums (CASCADE to album_photos)

### Photo Lifecycle

```
[Select File] → Validate → Upload → [Generate Thumbnail] → Photo Available
                    │                                             │
                    │                                             │
                 Invalid                                    [Remove from Album]
                    │                                             │
                 Reject                                           ▼
                                                           Remove album_photos entry
                                                                   │
                                                                   │
                                                           [Check: Photo in any album?]
                                                              Yes  │  No
                                                               │   │
                                                            Keep   │
                                                                   ▼
                                                          DELETE from photos + IndexedDB
```

**States**:
1. **Validation**: Check file type and size (sync)
2. **Upload**: Read file as ArrayBuffer (async)
3. **Thumbnail Generation**: Create thumbnail via Canvas (async)
4. **Available**: Photo stored in IndexedDB and SQLite, visible in albums

**Transitions**:
- Select File: User picks file from device
- Validate: Check MIME type, extension, size → Reject if invalid
- Upload: Read file, generate UUID, store in IndexedDB
- Generate Thumbnail: Canvas resizing, store thumbnail in IndexedDB
- Remove from Album: DELETE from album_photos
- Orphan Check: If photo not in any album, optionally DELETE (or keep for "all photos" view)

## Queries

### Common Queries

**Q1: Get all albums grouped by date**
```sql
SELECT id, name, date, created_at, display_order,
       (SELECT COUNT(*) FROM album_photos WHERE album_id = albums.id) AS photo_count
FROM albums
ORDER BY date DESC, display_order ASC;
```

**Q2: Get all photos in an album**
```sql
SELECT p.id, p.filename, p.file_size, p.width, p.height, p.upload_date
FROM photos p
JOIN album_photos ap ON p.id = ap.photo_id
WHERE ap.album_id = ?
ORDER BY ap.created_at ASC;
```

**Q3: Check if photo exists in multiple albums**
```sql
SELECT COUNT(*) AS album_count
FROM album_photos
WHERE photo_id = ?;
```

**Q4: Get all orphan photos (not in any album)**
```sql
SELECT p.*
FROM photos p
LEFT JOIN album_photos ap ON p.id = ap.photo_id
WHERE ap.photo_id IS NULL;
```

**Q5: Delete album and cascade**
```sql
DELETE FROM albums WHERE id = ?;
-- album_photos entries automatically deleted via CASCADE
```

**Q6: Remove photo from album (keep photo if in other albums)**
```sql
DELETE FROM album_photos WHERE album_id = ? AND photo_id = ?;
-- Then check if photo is orphan (Q3) and optionally delete
```

## Validation Rules Summary

### Album Validation
- `name`: Required, 1-255 characters, non-empty after trim
- `date`: Required, valid ISO date (YYYY-MM-DD), can be past/present/future

### Photo Validation
- `file`: Required File/Blob object
- `file.type`: Must be in ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
- `file.name`: Must end with ['.jpg', '.jpeg', '.png', '.gif', '.webp']
- `file.size`: Must be ≤ 10485760 bytes (10MB)

### Business Rules
- Album names can be duplicated (no uniqueness constraint)
- Photo cannot be added to same album twice (PRIMARY KEY constraint)
- Photo can exist in multiple albums (many-to-many)
- Empty albums are allowed (per FR-010)
- Albums cannot be nested (enforced by absence of parent_id field)

## Migration Strategy

**Version 1 (Initial)**:
- Create albums, photos, album_photos tables
- Create all indexes
- Initialize IndexedDB object store

**Future Versions** (if schema changes):
- Use sql.js migration pattern with version checks
- IndexedDB onupgradeneeded for object store changes
- Backward compatibility for existing data
