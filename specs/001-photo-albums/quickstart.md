# Quickstart Guide: Photo Album Organizer

**Feature**: Photo Album Organizer  
**Branch**: 001-photo-albums  
**Date**: 2026-02-16

## Overview

This guide walks through setting up and running the Photo Album Organizer application for development.

## Prerequisites

- **Node.js**: 18.0 or higher
- **npm**: 9.0 or higher
- **Modern Browser**: Chrome 90+, Firefox 88+, Safari 14+, or Edge 90+

## Project Setup

### 1. Initialize Project

```bash
# Create project structure
mkdir -p src/{db,services,ui/{components,pages,utils},lib,styles}
mkdir -p tests/{unit,integration,contract}
mkdir -p public

# Initialize npm project
npm init -y

# Install dependencies
npm install --save-dev vite vitest fake-indexeddb
npm install sql.js
```

### 2. Configure Vite

Create `vite.config.js`:

```javascript
import { defineConfig } from 'vite';

export default defineConfig({
  server: {
    port: 3000,
    open: true
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: true
  },
  optimizeDeps: {
    exclude: ['sql.js']
  }
});
```

### 3. Configure Vitest

Create `vitest.config.js`:

```javascript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './tests/setup.js',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html'],
      exclude: ['tests/', 'node_modules/']
    }
  }
});
```

### 4. Update package.json Scripts

```json
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage"
  }
}
```

### 5. Create Test Setup

Create `tests/setup.js`:

```javascript
import 'fake-indexeddb/auto';
import { beforeEach } from 'vitest';

// Reset IndexedDB before each test
beforeEach(() => {
  indexedDB = new IDBFactory();
});

// Mock crypto.randomUUID for tests
if (typeof crypto === 'undefined') {
  global.crypto = {
    randomUUID: () => {
      return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
        const r = Math.random() * 16 | 0;
        const v = c === 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
      });
    }
  };
}
```

## Development Workflow

### Running the Application

```bash
# Start development server (with hot reload)
npm run dev

# Application opens at http://localhost:3000
```

### Running Tests

```bash
# Run all tests once
npm test

# Run tests in watch mode (re-runs on file changes)
npm run test:watch

# Run tests with coverage report
npm run test:coverage
```

### Building for Production

```bash
# Create optimized production build
npm run build

# Preview production build locally
npm run preview
```

## File Structure

```
.
├── src/
│   ├── db/
│   │   ├── init.js              # Database initialization
│   │   └── queries.js           # SQL query functions
│   ├── services/
│   │   ├── album-service.js     # Album CRUD operations
│   │   ├── photo-service.js     # Photo add/remove/retrieve
│   │   └── storage-service.js   # IndexedDB wrapper
│   ├── ui/
│   │   ├── components/
│   │   │   ├── album-card.js    # Album display component
│   │   │   ├── photo-tile.js    # Photo thumbnail component
│   │   │   ├── photo-modal.js   # Full-size photo viewer
│   │   │   └── album-form.js    # Create/edit album form
│   │   ├── pages/
│   │   │   ├── home.js          # Album list page
│   │   │   └── album-view.js    # Photo grid page
│   │   └── utils/
│   │       ├── router.js        # Hash-based routing
│   │       └── dom.js           # DOM helpers
│   ├── lib/
│   │   ├── validation.js        # File validation
│   │   └── date-utils.js        # Date formatting/grouping
│   ├── styles/
│   │   ├── base.css             # CSS reset, variables
│   │   ├── components.css       # Component styles
│   │   └── layouts.css          # Grid layouts
│   ├── main.js                  # App entry point
│   └── index.html               # HTML shell
├── tests/
│   ├── setup.js                 # Test configuration
│   ├── unit/                    # Unit tests
│   ├── integration/             # Integration tests
│   └── contract/                # Contract tests
├── public/
│   └── sql-wasm.wasm            # SQLite WebAssembly
├── vite.config.js               # Vite configuration
├── vitest.config.js             # Test configuration
└── package.json
```

## Key Development Tasks

### Task 1: Initialize Database

**File**: `src/db/init.js`

```javascript
import initSqlJs from 'sql.js';

let db = null;

export async function initDatabase() {
  const SQL = await initSqlJs({
    locateFile: file => `/sql-wasm.wasm`
  });
  
  db = new SQL.Database();
  
  // Run schema initialization
  db.run(`
    CREATE TABLE IF NOT EXISTS albums (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      date TEXT NOT NULL,
      created_at TEXT NOT NULL,
      display_order INTEGER DEFAULT 0
    );
    
    CREATE TABLE IF NOT EXISTS photos (
      id TEXT PRIMARY KEY,
      filename TEXT NOT NULL,
      file_size INTEGER NOT NULL,
      width INTEGER,
      height INTEGER,
      upload_date TEXT NOT NULL,
      idb_key TEXT NOT NULL
    );
    
    CREATE TABLE IF NOT EXISTS album_photos (
      album_id INTEGER NOT NULL,
      photo_id TEXT NOT NULL,
      created_at TEXT NOT NULL,
      PRIMARY KEY (album_id, photo_id),
      FOREIGN KEY (album_id) REFERENCES albums(id) ON DELETE CASCADE,
      FOREIGN KEY (photo_id) REFERENCES photos(id) ON DELETE CASCADE
    );
  `);
  
  return db;
}

export function getDatabase() {
  if (!db) {
    throw new Error('Database not initialized. Call initDatabase() first.');
  }
  return db;
}
```

**Test**: `tests/contract/database-schema.test.js`

```javascript
import { describe, test, expect, beforeEach } from 'vitest';
import { initDatabase, getDatabase } from '../../src/db/init.js';

describe('Database Schema', () => {
  beforeEach(async () => {
    await initDatabase();
  });
  
  test('creates albums table', () => {
    const db = getDatabase();
    const result = db.exec("SELECT name FROM sqlite_master WHERE type='table' AND name='albums'");
    expect(result).toHaveLength(1);
  });
  
  test('creates photos table', () => {
    const db = getDatabase();
    const result = db.exec("SELECT name FROM sqlite_master WHERE type='table' AND name='photos'");
    expect(result).toHaveLength(1);
  });
  
  test('creates album_photos junction table', () => {
    const db = getDatabase();
    const result = db.exec("SELECT name FROM sqlite_master WHERE type='table' AND name='album_photos'");
    expect(result).toHaveLength(1);
  });
});
```

### Task 2: Implement Storage Service

**File**: `src/services/storage-service.js`

```javascript
const DB_NAME = 'photo-album-db';
const STORE_NAME = 'photo-files';
const DB_VERSION = 1;

class StorageService {
  constructor() {
    this.db = null;
  }
  
  async init() {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open(DB_NAME, DB_VERSION);
      
      request.onerror = () => reject(request.error);
      request.onsuccess = () => {
        this.db = request.result;
        resolve();
      };
      
      request.onupgradeneeded = (event) => {
        const db = event.target.result;
        if (!db.objectStoreNames.contains(STORE_NAME)) {
          db.createObjectStore(STORE_NAME, { keyPath: 'id' });
        }
      };
    });
  }
  
  async storePhoto(file, photoId) {
    // Validate file size
    if (file.size > 10 * 1024 * 1024) {
      throw new Error('File too large (max 10MB)');
    }
    
    // Generate thumbnail
    const thumbnail = await this.generateThumbnail(file);
    
    // Store in IndexedDB
    return new Promise((resolve, reject) => {
      const tx = this.db.transaction(STORE_NAME, 'readwrite');
      const store = tx.objectStore(STORE_NAME);
      
      const record = {
        id: photoId,
        original: file,
        thumbnail: thumbnail,
        createdAt: new Date().toISOString()
      };
      
      const request = store.put(record);
      request.onsuccess = () => resolve();
      request.onerror = () => reject(request.error);
    });
  }
  
  async generateThumbnail(file) {
    return new Promise((resolve, reject) => {
      const img = new Image();
      const url = URL.createObjectURL(file);
      
      img.onload = () => {
        URL.revokeObjectURL(url);
        
        const targetWidth = 200;
        const scale = targetWidth / img.width;
        const targetHeight = img.height * scale;
        
        const canvas = document.createElement('canvas');
        canvas.width = targetWidth;
        canvas.height = targetHeight;
        
        const ctx = canvas.getContext('2d');
        ctx.drawImage(img, 0, 0, targetWidth, targetHeight);
        
        canvas.toBlob((blob) => {
          if (blob) resolve(blob);
          else reject(new Error('Thumbnail generation failed'));
        }, 'image/jpeg', 0.8);
      };
      
      img.onerror = () => {
        URL.revokeObjectURL(url);
        reject(new Error('Failed to load image'));
      };
      
      img.src = url;
    });
  }
  
  async getOriginal(photoId) {
    return new Promise((resolve, reject) => {
      const tx = this.db.transaction(STORE_NAME, 'readonly');
      const store = tx.objectStore(STORE_NAME);
      const request = store.get(photoId);
      
      request.onsuccess = () => {
        if (request.result) {
          resolve(request.result.original);
        } else {
          reject(new Error('Photo not found'));
        }
      };
      request.onerror = () => reject(request.error);
    });
  }
  
  async getThumbnail(photoId) {
    return new Promise((resolve, reject) => {
      const tx = this.db.transaction(STORE_NAME, 'readonly');
      const store = tx.objectStore(STORE_NAME);
      const request = store.get(photoId);
      
      request.onsuccess = () => {
        if (request.result) {
          resolve(request.result.thumbnail);
        } else {
          reject(new Error('Photo not found'));
        }
      };
      request.onerror = () => reject(request.error);
    });
  }
  
  async deletePhoto(photoId) {
    return new Promise((resolve, reject) => {
      const tx = this.db.transaction(STORE_NAME, 'readwrite');
      const store = tx.objectStore(STORE_NAME);
      const request = store.delete(photoId);
      
      request.onsuccess = () => resolve();
      request.onerror = () => reject(request.error);
    });
  }
}

export const storageService = new StorageService();
```

**Test**: `tests/contract/storage-api.test.js`

```javascript
import { describe, test, expect, beforeEach } from 'vitest';
import { storageService } from '../../src/services/storage-service.js';

describe('Storage Service', () => {
  beforeEach(async () => {
    await storageService.init();
  });
  
  test('stores and retrieves photo', async () => {
    const file = new File(['test'], 'test.jpg', { type: 'image/jpeg' });
    const photoId = crypto.randomUUID();
    
    await storageService.storePhoto(file, photoId);
    const retrieved = await storageService.getOriginal(photoId);
    
    expect(retrieved).toBeInstanceOf(Blob);
  });
  
  test('rejects files over 10MB', async () => {
    const largeFile = new File([new ArrayBuffer(11 * 1024 * 1024)], 'large.jpg', { type: 'image/jpeg' });
    const photoId = crypto.randomUUID();
    
    await expect(storageService.storePhoto(largeFile, photoId))
      .rejects.toThrow('File too large');
  });
});
```

## Next Steps

1. **Implement Album Service**: CRUD operations for albums (see `data-model.md`)
2. **Implement Photo Service**: Add/remove photos to albums
3. **Build UI Components**: Album cards, photo tiles, modals
4. **Implement Routing**: Hash-based navigation
5. **Add Validation**: File type and size checks
6. **Implement Date Grouping**: Group albums by date on home page
7. **Add Accessibility**: Keyboard navigation, ARIA labels
8. **Performance Optimization**: Lazy loading, virtual scrolling

## Common Issues

### Issue: sql.js WebAssembly not loading

**Solution**: Ensure `sql-wasm.wasm` is in `public/` directory and accessible at `/sql-wasm.wasm`

### Issue: IndexedDB quota exceeded

**Solution**: Implement cleanup of orphan photos; provide user warning when storage fills

### Issue: Thumbnail generation slow for large images

**Solution**: Add loading spinner; consider offloading to Web Worker for very large files

## Resources

- [Vite Documentation](https://vitejs.dev/)
- [Vitest Documentation](https://vitest.dev/)
- [sql.js Documentation](https://sql.js.org/)
- [IndexedDB API](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API)
- [Canvas API](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API)
