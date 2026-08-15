Project Overview:
Smart Geo-Tagged Landmarks is a mobile application for Android built with Flutter. It interacts with the provided REST API to manage and visualize geo-tagged landmarks. The application offers a comprehensive suite of features, including a map view, offline support, background job synchronization, and robust error handling.

Features Implemented:
- Landmarks Display: Fetched from the API and stored locally for fast access.
- Map View: OpenStreetMap integration via flutter_map, showing markers colored from red to green based on their activity score.
- Visit Feature: Asynchronous GPS-based check-ins. Background workers poll the server for the calculated visit distance without blocking the UI.
- Landmarks List: Scrollable list with dynamic filtering (minimum score slider) and sorting functionality.
- Activity Screen: Tracks the history of visits in real-time, showing pending, queued, and completed jobs with distances.
- Add Landmark: Uses device GPS and camera/gallery (multipart/form-data) to create new landmarks.
- Soft Delete & Restore: Swipe-to-delete landmarks locally and remotely, with an undo option.
- Offline Mode: Full support for browsing cached landmarks and queuing visits while offline.

API Usage:
- Uses Dio for all HTTP communication to `https://labs.anontech.info/cse489/exm3/api.php`.
- API Key is injected automatically via interceptors.
- Multipart form uploads used correctly for image payload during `create_landmark`.

Offline Strategy:
- Local Database: Uses `sqflite` to mirror the server's landmark data.
- Read Operations: The UI always reads from the local database (single source of truth). Network refreshes silently update the local database.
- Write Operations: Connectivity is checked before attempting a visit. If offline, the visit is stored as `QUEUED`.
- Synchronization: A Workmanager task (`syncOfflineQueue`) is scheduled to drain the queue when connectivity is restored, featuring exponential backoff.

Architecture Used:
- Repository Pattern: Separates the UI from data fetching logic. 
- State Management: Riverpod is used for predictable dependency injection and state updates across the 4-tab Bottom Navigation shell.
- Background Work: `workmanager` handles all long-running tasks outside the application's lifecycle (both polling job statuses and syncing offline queues).

Challenges Faced:
- Implementing a shared background task mechanism for both polling `job_id` and syncing offline queues required careful state tracking in SQLite (`QUEUED` vs `PENDING` vs `DONE`).
- Ensuring the app responds well when data is soft-deleted mid-session. This was handled by executing deletions directly against the SQLite cache and invalidating the Riverpod providers to update the UI instantly.
