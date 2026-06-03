# 🎙️ Apex Speech — Virtual AI Public Speaking Coach

A **production-quality Flutter application** built with Clean Architecture, MVVM, and full Firebase backend integration.

---

## 🏗️ Architecture Overview

```
lib/
├── core/
│   ├── constants/        → AppConstants (single source of truth)
│   ├── di/               → Dependency injection (get_it)
│   ├── router/           → AppRouter (named routes + transitions)
│   ├── themes/           → AppTheme (design system)
│   └── utils/            → Validators, formatters
│
├── domain/               ← PURE DART. No Flutter/Firebase imports
│   ├── entities/         → Speech, AppUser (immutable value objects)
│   ├── repositories/     → Abstract contracts (AuthRepository, SpeechRepository)
│   └── usecases/         → Business logic (SignInUseCase, UploadSpeechUseCase...)
│
├── data/                 ← Firebase implementations
│   ├── models/           → SpeechModel, UserModel (Firestore DTOs)
│   ├── repositories/     → FirebaseAuthRepository, FirebaseSpeechRepository
│   └── services/         → AudioRecordingService
│
├── presentation/         ← Flutter UI
│   ├── screens/          → 5 screens (Login, Signup, Home, Feedback, Playback)
│   ├── viewmodels/       → AuthViewModel, HomeViewModel, FeedbackViewModel, PlaybackViewModel
│   └── widgets/          → GlassCard, GoldButton, ScoreRing, AmplitudeBar
│
└── main.dart             → App entry point + MultiProvider setup
```

---

## 🎯 OOP Principles Applied

| Principle | Where Applied |
|---|---|
| **Encapsulation** | `AudioRecordingService`, `FirebaseAuthRepository` — hide internal details |
| **Abstraction** | `AuthRepository`, `SpeechRepository` — abstract contracts |
| **Inheritance** | `ChangeNotifier` extended by all ViewModels |
| **Polymorphism** | `FirebaseSpeechRepository implements SpeechRepository` |
| **DRY** | `GlassCard`, `GoldButton`, `ApexScaffold` widgets |
| **SOLID** | DIP via DI container, SRP in use cases, ISP in repositories |
| **Repository Pattern** | `SpeechRepository` / `AuthRepository` |
| **Singleton** | `AudioRecordingService`, GetIt service locator |
| **Factory** | `SpeechModel.fromFirestore()`, `UserModel.fromEntity()` |

---

## 🚀 Setup Instructions

### 1. Prerequisites
- Flutter SDK ≥ 3.0.0
- Android Studio (with Flutter & Dart plugins)
- Firebase account

### 2. Clone & Install
```bash
git clone <repo>
cd apex_speech
flutter pub get
```

### 3. Firebase Setup
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (follow prompts)
flutterfire configure

# This generates lib/firebase_options.dart automatically
```

Then add to `main.dart`:
```dart
import 'firebase_options.dart';

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### 4. Firebase Console Setup
Enable in Firebase Console:
- ✅ Authentication → Email/Password
- ✅ Firestore Database (create in test mode first)
- ✅ Storage

Deploy security rules:
```bash
firebase deploy --only firestore:rules,storage
```

### 5. Android Permissions
Already configured in `AndroidManifest.xml`:
- `RECORD_AUDIO`
- `INTERNET`
- `CAMERA` (for future posture AI)

### 6. Run
```bash
flutter run
```

---

## 📱 Screens

| Screen | Route | Purpose |
|---|---|---|
| Login | `/login` | Email/password auth with validation |
| Signup | `/signup` | Account creation with full validation |
| Home | `/home` | Recording interface + session history |
| Feedback | `/feedback` | AI analysis: tone, pace, clarity, fillers |
| Playback | `/playback` | Audio player with timeline slider |

---

## 🔌 State Management

Uses **Provider** with `ChangeNotifier`:
- `AuthViewModel` — auth state + user session
- `HomeViewModel` — recording lifecycle + speech history
- `FeedbackViewModel` — real-time speech analysis via Firestore stream
- `PlaybackViewModel` — audio player state

---

## 🎨 Design System

| Token | Value |
|---|---|
| Primary | `#0A0A0A` |
| Gold Accent | `#D4AF37` |
| Card BG | `#2F2F2F` |
| Style | Glassmorphism + Luxury Minimal |
| Typography | Cormorant Garamond (display) + DM Sans (body) |
| Animations | `flutter_animate` with staggered reveals |

---

## 🔮 Future Roadmap (Architecture Ready)

- [ ] Real AI speech analysis (Whisper API / Google Speech-to-Text)
- [ ] Posture detection via camera (ML Kit / TensorFlow Lite)
- [ ] Cloud Functions for backend processing
- [ ] Progress charts and trend analysis
- [ ] Social sharing of improvement scores

---

## 📁 Key Files

| File | Purpose |
|---|---|
| `lib/core/di/injection_container.dart` | All dependency wiring |
| `lib/core/router/app_router.dart` | Named route management |
| `lib/domain/entities/speech.dart` | Core Speech + SpeechFeedback entities |
| `lib/data/repositories/firebase_speech_repository.dart` | Firebase implementation |
| `lib/presentation/viewmodels/home_viewmodel.dart` | Recording business logic |
| `firestore.rules` | Firestore security rules |
| `storage.rules` | Firebase Storage security rules |

---

Built as a startup-level MVP. Clean. Scalable. Maintainable.
