```
   .--------------------.
  /  $   ⇄   €   ¥      \
 |      CURRENSEE        |
  \   Currency tools    /
   '--------------------'
```

# 💱 CurrenSee

A Flutter app for currency conversion and finance-related tools. CurrenSee uses Firebase for authentication and cloud data, with Riverpod for state management and local storage options for preferences and app data.

## ✨ Project highlights

- 🔐 Firebase Authentication and Google Sign-In dependencies
- ☁️ Cloud Firestore integration
- 🔄 Riverpod state management
- 💾 Shared Preferences and SQLite storage
- 🔔 Local notifications
- 🌓 Light and dark themes
- 📱 Flutter app with Android and iOS platform projects

## 🧰 Built with

- Flutter and Dart
- Firebase Core, Authentication, and Cloud Firestore
- Riverpod
- Google Sign-In
- Shared Preferences and sqflite
- Flutter Local Notifications
- WebView Flutter

## 🚀 Get started

### Prerequisites

- Flutter SDK with Dart 3.8.1 or later
- A configured Android or iOS development environment
- A Firebase project configured for the platforms you want to run

### Install and run

```bash
git clone https://github.com/Abbas-Abubakar/currensee.git
cd currensee
flutter pub get
flutter run
```

To choose a specific connected device:

```bash
flutter devices
flutter run -d <device-id>
```

### Firebase configuration

The app initializes Firebase using `DefaultFirebaseOptions`. To connect the app to your own Firebase project, configure the supported platforms with FlutterFire CLI:

```bash
flutterfire configure
```

Follow Firebase’s platform setup instructions, then run the app again:

```bash
flutter run
```

## 🗂️ Project layout

```text
lib/
├── core/        # Shared app configuration, including theming
├── providers/   # Riverpod state providers
├── screens/     # App screens
├── services/    # App services
└── main.dart    # App entry point and initialization
```

## 🧪 Useful commands

```bash
flutter analyze   # Check for Dart and Flutter issues
flutter test      # Run tests
flutter run       # Launch the app
```

## 📝 Notes

Some features require valid Firebase and platform-specific configuration. Keep any local secrets and credentials out of version control.

---

Made with Flutter 💙
