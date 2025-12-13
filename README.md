# Services App

A secure Flutter application for storing and viewing media files with password protection and encrypted storage.

## Features

- 🔐 **Secure Lock Screen** - Password-protected access to your files
- 📁 **Safe Home** - Protected file storage and management
- 🎥 **Video Player** - Enhanced video playback with seek controls
- 🎵 **Audio Player** - Support for audio file playback
- 🖼️ **Image Viewer** - View and manage images securely
- 🔒 **Encrypted Storage** - Files stored securely using flutter_secure_storage
- 📂 **File Management** - Import and organize various file types

## Tech Stack

- **Flutter SDK**: ^3.8.1
- **Dart**: ^3.8.1
- **Key Dependencies**:
  - `flutter_secure_storage`: Encrypted local storage
  - `video_player`: Video playback functionality
  - `just_audio`: Audio playback
  - `cryptography`: Data encryption
  - `file_picker`: Import files from device
  - `permission_handler`: Manage device permissions

## Getting Started

### Prerequisites

- Flutter SDK (^3.8.1)
- Dart SDK (^3.8.1)
- Android Studio / Xcode (for mobile development)

### Installation

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd Services_App
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # Application entry point
└── src/
    ├── app.dart              # Main app widget
    ├── core/                 # Core utilities and services
    ├── features/             # Feature modules
    │   ├── lockscreen/       # Lock screen feature
    │   ├── safe_home/        # Protected file storage
    │   ├── settings/         # App settings
    │   └── video_player/     # Video playback
    └── utils/                # Utility functions
```

## Development

### Running Tests

```bash
flutter test
```

### Code Style

This project follows Flutter best practices and uses `flutter_lints` for code quality. Ensure all code adheres to:

- Performant and clean code practices
- Material Design guidelines
- Project coding standards defined in `analysis_options.yaml`

## Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Linux
- ✅ macOS
- ✅ Windows
- ✅ Web

## Contributing

Please refer to the specifications in the `specs/` directory for feature requirements and development guidelines.

## License

This project is private and not published to pub.dev.
