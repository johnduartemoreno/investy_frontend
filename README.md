# Invessty - Flutter Mobile App

**Mobile-only (Android/iOS). Web and macOS are out of scope.**

This project is a production-ready Flutter application using Clean Architecture, Riverpod, and GoRouter.

## Architecture

The project follows Clean Architecture principles:

- **Presentation**: UI widgets, State Management (Riverpod providers).
- **Domain**: Business Logic, Entities, Use Cases, Repository Interfaces.
- **Data**: Data Sources (API/Local), Models, Repository Implementations.

### Structure
```
lib/
├── core/           # Core utilities (network, router, errors, theme)
├── features/       # Feature-based organization
│   ├── auth/       # Authentication feature
│   ├── home/       # Dashboard/Home feature
│   ├── goals/      # Financial goals feature
│   ├── portfolio/  # Portfolio tracking feature
│   └── settings/   # User settings feature
└── main.dart       # Entry point
```

## Setup & Installation

1. **Prerequisites**: Ensure you have Flutter SDK installed.
2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```
3. **Code Generation** (Required for Riverpod, Freezed, Hive, JSON):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. **Run the App**:
   ```bash
   flutter run -d android   # For Android
   flutter run -d ios       # For iOS (requires macOS + Xcode)
   ```

## Key Libraries

- **State Management**: `flutter_riverpod`, `riverpod_annotation`
- **Navigation**: `go_router`
- **Networking**: `dio`
- **Local Storage**: `hive`, `hive_flutter`
- **Functional Programming**: `fpdart`
- **Code Gen**: `freezed`, `json_serializable`

## Testing

Run unit and widget tests:
```bash
flutter test
```

## Linting

Code analysis is strictly configured in `analysis_options.yaml`. Run linter:
```bash
flutter analyze
```
