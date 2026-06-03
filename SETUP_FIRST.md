# ⚡ SETUP_FIRST — Read this before doing anything else

Before you run the app, you need to replace 4 placeholder files with real ones from Firebase.
Everything else is already done.

---

## 4 files you MUST replace

### 1. android/app/google-services.json
📍 Location in this project: `android/app/google-services.json`

Steps:
1. Go to https://console.firebase.google.com
2. Create a new project (or open an existing one)
3. Click the Android icon ➜ Add Android app
4. Enter package name: `com.apexspeech.app`
5. Download the `google-services.json` file
6. REPLACE the placeholder file at `android/app/google-services.json` with your download

---

### 2. lib/firebase_options.dart
📍 Location in this project: `lib/firebase_options.dart`

This file is auto-generated. Run this command inside the project folder:

```bash
# Install FlutterFire CLI first (one time only)
dart pub global activate flutterfire_cli

# Then run this inside apex_speech/
flutterfire configure
```

This command will overwrite `lib/firebase_options.dart` with your real Firebase config.

---

### 3. firestore.rules
📍 Location in this project: `firestore.rules`

This file is ALREADY WRITTEN and ready to use. You just need to deploy it:

```bash
# Install Firebase CLI first (one time only)
npm install -g firebase-tools
firebase login

# Then deploy from inside apex_speech/
firebase deploy --only firestore:rules
```

---

### 4. storage.rules
📍 Location in this project: `storage.rules`

Also already written. Deploy it the same way:

```bash
firebase deploy --only storage
```

Or deploy both rules at once:

```bash
firebase deploy --only firestore:rules,storage
```

---

## After replacing those 4 files, run the app

```bash
# 1. Install dependencies
flutter pub get

# 2. Run on your connected device or emulator
flutter run
```

---

## Firebase Console checklist

Make sure these are enabled in your Firebase project:

- [ ] Authentication → Sign-in method → Email/Password → Enable
- [ ] Firestore Database → Create database (start in test mode)
- [ ] Storage → Get started

---

## Project structure (for reference)

```
apex_speech/
├── SETUP_FIRST.md              ← you are here
├── pubspec.yaml                ← dependencies
├── firestore.rules             ← ✅ ready, just deploy
├── storage.rules               ← ✅ ready, just deploy
├── .gitignore
│
├── android/
│   ├── app/
│   │   ├── google-services.json   ← ⚠️  REPLACE THIS
│   │   ├── build.gradle
│   │   └── src/main/
│   │       ├── AndroidManifest.xml   ← ✅ already configured
│   │       └── kotlin/com/apexspeech/app/MainActivity.kt
│   ├── build.gradle
│   └── settings.gradle
│
├── assets/
│   ├── animations/    ← add Lottie JSON files here
│   └── images/        ← add image assets here
│
└── lib/
    ├── main.dart                   ← app entry point
    ├── firebase_options.dart       ← ⚠️  REPLACE with flutterfire configure
    │
    ├── core/
    │   ├── constants/app_constants.dart
    │   ├── themes/app_theme.dart
    │   ├── utils/validators.dart
    │   ├── di/injection_container.dart
    │   └── router/app_router.dart
    │
    ├── domain/
    │   ├── entities/speech.dart
    │   ├── entities/app_user.dart
    │   ├── repositories/auth_repository.dart
    │   ├── repositories/speech_repository.dart
    │   ├── usecases/auth_usecases.dart
    │   └── usecases/speech_usecases.dart
    │
    ├── data/
    │   ├── models/speech_model.dart
    │   ├── models/user_model.dart
    │   ├── repositories/firebase_auth_repository.dart
    │   ├── repositories/firebase_speech_repository.dart
    │   └── services/audio_recording_service.dart
    │
    └── presentation/
        ├── viewmodels/auth_viewmodel.dart
        ├── viewmodels/home_viewmodel.dart
        ├── viewmodels/feedback_viewmodel.dart
        ├── viewmodels/playback_viewmodel.dart
        ├── widgets/common_widgets.dart
        ├── screens/login_screen.dart
        ├── screens/signup_screen.dart
        ├── screens/home_screen.dart
        ├── screens/feedback_screen.dart
        └── screens/playback_screen.dart
```
