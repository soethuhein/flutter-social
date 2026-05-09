# flutter_social_app

A Flutter message management app for blog/wiki/social-style posts with on-device SQLite storage.

## Features

1. Create, edit, view, and delete text messages.
2. View individual messages and the full message list.
3. Search message text (case-insensitive) and show matching results.
4. Delete a single message.
5. Select and delete multiple messages.
6. Store all messages in on-device SQLite.
7. Attach an image from gallery or camera.
8. Share an individual message (text or text+image) through the system share sheet (Facebook, Instagram, LinkedIn, X, etc. if installed).

## Tech Stack

- Flutter + Material 3
- `sqflite` for local database
- `provider` for state management
- `image_picker` for camera/gallery image selection
- `share_plus` for sharing

## Project Structure

- `lib/main.dart` app bootstrap + dependency injection
- `lib/models/message.dart` message model
- `lib/data/database_helper.dart` SQLite init and schema
- `lib/data/message_store.dart` data access API and sqflite implementation
- `lib/controllers/message_controller.dart` app state and business logic
- `lib/screens/message_list_screen.dart` list, search, and multi-delete UI
- `lib/screens/message_form_screen.dart` create/edit + image attach UI
- `lib/screens/message_detail_screen.dart` single message view + share/delete
- `lib/services/image_service.dart` camera/gallery abstraction
- `lib/services/message_share_service.dart` share abstraction

## Setup

1. Install Flutter SDK.
2. From project root, run:

```bash
flutter pub get
```

3. Run app:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
flutter run
flutter build apk --release
build/app/outputs/flutter-apk/
flutter run -d emulator-5554

```

## Platform Permissions

Already configured:

- Android: camera + media read permissions in `android/app/src/main/AndroidManifest.xml`
- iOS: camera/photo library usage descriptions in `ios/Runner/Info.plist`

## Run Tests

```bash
flutter test
```

## Test Coverage Mapping

- CRUD + SQLite persistence + search + single delete + bulk delete:
  - `test/data/message_store_test.dart`
- Controller behavior for create/edit/search/delete/bulk delete and image path handling:
  - `test/controllers/message_controller_test.dart`
- List UI behaviors (view list, search, select and delete chosen messages):
  - `test/widgets/message_list_screen_test.dart`
- Form UI behaviors (create/edit validation and image picker triggers):
  - `test/widgets/message_form_screen_test.dart`
- Detail UI behaviors (view one message and share action):
  - `test/widgets/message_detail_screen_test.dart`

## Validation Status

- `flutter analyze`: passed
- `flutter test`: passed (12 tests)
