-- Photo Album Organizer - SQLite Schema
-- Version: 1.0.0
-- Date: 2026-02-16
-- 
-- This schema defines the relational structure for albums and photos.
-- Actual photo files are stored in IndexedDB (see file-storage-api.md).

-- ============================================================================
-- ALBUMS TABLE
-- ============================================================================
-- Stores album metadata including name, date, and display order.

CREATE TABLE IF NOT EXISTS albums (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL CHECK(length(trim(name)) > 0),
  date TEXT NOT NULL CHECK(date LIKE '____-__-__'),  -- YYYY-MM-DD format
  created_at TEXT NOT NULL,  -- ISO 8601: YYYY-MM-DDTHH:MM:SSZ
  display_order INTEGER DEFAULT 0 CHECK(display_order >= 0)
);

-- Index for date-grouped queries (newest first)
CREATE INDEX IF NOT EXISTS idx_albums_date 
  ON albums(date DESC);

-- Index for custom ordering within date groups
CREATE INDEX IF NOT EXISTS idx_albums_display_order 
  ON albums(display_order ASC);

-- ============================================================================
-- PHOTOS TABLE
-- ============================================================================
-- Stores photo metadata. Actual files stored in IndexedDB.
-- id is UUID v4 for stable references across IndexedDB.

CREATE TABLE IF NOT EXISTS photos (
  id TEXT PRIMARY KEY CHECK(length(id) = 36),  -- UUID v4 format
  filename TEXT NOT NULL CHECK(length(trim(filename)) > 0),
  file_size INTEGER NOT NULL CHECK(file_size > 0 AND file_size <= 10485760),  -- Max 10MB
  width INTEGER CHECK(width IS NULL OR width > 0),
  height INTEGER CHECK(height IS NULL OR height > 0),
  upload_date TEXT NOT NULL,  -- ISO 8601: YYYY-MM-DDTHH:MM:SSZ
  idb_key TEXT NOT NULL CHECK(idb_key = id)  -- IndexedDB key (must match id)
);

-- Index for sorting by upload date (newest first)
CREATE INDEX IF NOT EXISTS idx_photos_upload_date 
  ON photos(upload_date DESC);

-- ============================================================================
-- ALBUM_PHOTOS TABLE (Junction)
-- ============================================================================
-- Many-to-many relationship between albums and photos.
-- Allows photos to appear in multiple albums without duplication.

CREATE TABLE IF NOT EXISTS album_photos (
  album_id INTEGER NOT NULL,
  photo_id TEXT NOT NULL,
  created_at TEXT NOT NULL,  -- ISO 8601: when photo added to this album
  PRIMARY KEY (album_id, photo_id),
  FOREIGN KEY (album_id) REFERENCES albums(id) ON DELETE CASCADE,
  FOREIGN KEY (photo_id) REFERENCES photos(id) ON DELETE CASCADE
);

-- Index for retrieving all photos in an album (critical for album view)
CREATE INDEX IF NOT EXISTS idx_album_photos_album 
  ON album_photos(album_id);

-- Index for finding all albums containing a specific photo
CREATE INDEX IF NOT EXISTS idx_album_photos_photo 
  ON album_photos(photo_id);

-- ============================================================================
-- COMMON QUERIES (for reference)
-- ============================================================================

-- Query 1: Get all albums with photo counts, grouped by date
-- SELECT id, name, date, created_at, display_order,
--        (SELECT COUNT(*) FROM album_photos WHERE album_id = albums.id) AS photo_count
-- FROM albums
-- ORDER BY date DESC, display_order ASC;

-- Query 2: Get all photos in a specific album
-- SELECT p.id, p.filename, p.file_size, p.width, p.height, p.upload_date
-- FROM photos p
-- JOIN album_photos ap ON p.id = ap.photo_id
-- WHERE ap.album_id = ?
-- ORDER BY ap.created_at ASC;

-- Query 3: Count albums containing a specific photo
-- SELECT COUNT(*) AS album_count
-- FROM album_photos
-- WHERE photo_id = ?;

-- Query 4: Find orphan photos (not in any album)
-- SELECT p.*
-- FROM photos p
-- LEFT JOIN album_photos ap ON p.id = ap.photo_id
-- WHERE ap.photo_id IS NULL;

-- Query 5: Delete album (CASCADE automatically removes album_photos entries)
-- DELETE FROM albums WHERE id = ?;

-- Query 6: Remove photo from album
-- DELETE FROM album_photos WHERE album_id = ? AND photo_id = ?;

-- ============================================================================
-- MIGRATION NOTES
-- ============================================================================
-- Version 1.0.0 (Initial):
-- - Created albums, photos, album_photos tables
-- - Created all indexes
-- - Added CHECK constraints for data validation
--
-- Future migrations should increment version and include ALTER statements.
