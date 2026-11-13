# Agent Context & Instructions

This document records the instructions and persistent guidelines for the **Aviation Tracker** project.

---

### 1. Persona & Role
- **Client / Product Owner**: Shoyeb Ahammed
- **Agent Role**: Software Manager and primary technical heavy lifter in code.
- **Responsibility**: Write clean, scalable, error-free, and well-architected Flutter code that strictly meets or exceeds all academic/rubric requirements.

---

### 2. Core Directives & Rules
1. **Version Documentation**:
   - Maintain `version_documentation.md` across versions (`ver 1.x.x`).
   - Each entry must have its exact date and detailed changelog.
   - Check before doing a major version bump (`ver 1.x.x` to `2.x.x`).
   - Record every small detail for future context.
2. **Agent Context**:
   - Maintain this file (`agent_context.md`) with instructions.
3. **GitHub Readme**:
   - Keep `readme.md` clean, human-written, and simple.
   - Explain app workflow, setup steps, and features.
4. **Git Ignore**:
   - Maintain a comprehensive `.gitignore` for Flutter/Dart and IDE files. Check whenever adding new files.
5. **New Version & APK on Every Update**:
   - Every single update must have a new version number incremented in `pubspec.yaml` (e.g. `1.0.0+1` -> `1.0.1+2`), recorded in `version_documentation.md`, and a new release APK generated with the version in the filename (e.g. `apk/skytrack_pro_v1.0.1.apk`), keeping previous versions preserved in `apk/`.

---

### 3. Project Requirements (From `Flutter test 1.docx`)
- **Evaluation Rubric (100 Marks)**:
  - UI Design (15 Marks)
  - API Integration (20 Marks)
  - CRUD Functionality (20 Marks)
  - Local Cache (15 Marks)
  - Pagination (10 Marks)
  - State Management (10 Marks)
  - Code Quality & Clean Architecture (5 Marks)
  - Documentation (5 Marks)
- **API**: Aviationstack API (`https://aviationstack.com`)
  - Target: Real-time flights endpoint (`/v1/flights`).
- **Primary Constraints & Key Focus**:
  - **Minimal API Usage**: Free tier has limited requests (e.g. 100-500 requests/month) and HTTP restrictions. We must implement smart caching, offline first fallback, bundled seed data for zero-API testing, and debounced/local queries.
  - **Visualization Focus**: Route progress visualization, airport coordinate plotting / interactive route map, flight delay and status distribution charts (`fl_chart`), boarding pass UI.
  - **Full Local CRUD**: Aviationstack is read-only. Store flights locally (Hive or SQLite), allow users to Add custom tracked flights / itineraries, Edit notes/tags/status, and Delete flights.
