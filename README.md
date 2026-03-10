# TodoFlow — Flutter To-Do App

<div align="center">

![TodoFlow Banner](https://img.shields.io/badge/TodoFlow-Flutter%20App-6C63FF?style=for-the-badge&logo=flutter&logoColor=white)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Realtime%20DB-FFCA28?style=flat-square&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Provider](https://img.shields.io/badge/State-Provider-6C63FF?style=flat-square)](https://pub.dev/packages/provider)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

**A production-quality To-Do List app built with Flutter, Firebase Authentication, and Firebase Realtime Database — using pure REST API calls.**

[Features](#features) •  [Architecture](#architecture) • [Setup](#setup) • [Running](#running) • [Tech Stack](#tech-stack)

</div>

---

## ✨ Features

### 🔐 Authentication
- ✅ Email & Password Sign Up
- ✅ Email & Password Sign In
- ✅ Secure Sign Out
- ✅ Session persistence — stays logged in after app restart
- ✅ Auto token refresh — seamless re-authentication
- ✅ Login status stored in Firebase Database

### ✅ Task Management
- ✅ View all personal tasks
- ✅ Add new tasks with a clean bottom sheet
- ✅ Edit task titles inline
- ✅ Toggle task completion (with optimistic updates)
- ✅ Delete tasks (swipe or menu)
- ✅ Filter tasks — All / Active / Completed
- ✅ Task progress statistics card
- ✅ Pull-to-refresh

### 📱 Responsiveness
- ✅ Mobile, Tablet and Desktop layouts
- ✅ Adaptive content width per screen size
- ✅ Keyboard-aware bottom sheet

---

## 🗂 Project Structure

```
flutter_todo_app/
│
├── lib/
│   ├── main.dart                          # App entry point
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_config.dart            # Firebase credentials & URLs
│   │   ├── theme/
│   │   │   └── app_theme.dart             # Material 3 theme & colors
│   │   └── utils/
│   │       └── app_utils.dart             # Responsive helpers, date format
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── auth_model.dart            # User session model
│   │   │   └── task_model.dart            # Task entity model
│   │   └── services/
│   │       ├── auth_service.dart          # Firebase Auth REST API
│   │       ├── task_service.dart          # Firebase DB REST CRUD
│   │       └── user_service.dart          # User login status service
│   │
│   ├── providers/
│   │   ├── auth_provider.dart             # Auth state management
│   │   └── task_provider.dart             # Task state management
│   │
│   └── presentation/
│       ├── app_router.dart                # Auth-aware navigator
│       ├── auth/screens/
│       │   ├── login_screen.dart
│       │   └── signup_screen.dart
│       ├── home/screens/
│       │   └── home_screen.dart
│       ├── home/widgets/
│       │   ├── task_tile.dart
│       │   ├── add_task_sheet.dart
│       │   ├── filter_tab_bar.dart
│       │   ├── task_stats_header.dart
│       │   └── empty_state.dart
│       └── shared/widgets/
│           ├── loading_button.dart
│           └── auth_text_field.dart
│
├── firebase_rules.json                    # Firebase security rules
├── pubspec.yaml
└── README.md
```

---

## 🏗 Architecture

The app follows a clean **4-layer architecture**:

```
┌─────────────────────────────────┐
│        Presentation Layer        │  Screens & Widgets
│  (UI only — reads & dispatches) │
└──────────────┬──────────────────┘
               │ context.watch / context.read
┌──────────────▼──────────────────┐
│          Provider Layer          │  AuthProvider, TaskProvider
│  (Business logic + app state)   │
└──────────────┬──────────────────┘
               │ calls services
┌──────────────▼──────────────────┐
│           Service Layer          │  AuthService, TaskService
│    (Pure HTTP — no state)       │
└──────────────┬──────────────────┘
               │ HTTP REST calls
┌──────────────▼──────────────────┐
│      Firebase (External)         │  Auth API + Realtime Database
└─────────────────────────────────┘
```

---

## 🔥 Firebase Database Structure

```
Firebase Realtime Database
│
├── users/
│   └── {userId}/
│       ├── email: "user@example.com"
│       ├── isLoggedIn: true
│       └── lastUpdated: 1710000000000
│
└── tasks/
    └── {userId}/
        └── {taskId}/
            ├── title: "Buy groceries"
            ├── completed: false
            └── createdAt: 1710000000000
```

---

## 🛠 Tech Stack

| Technology | Purpose |
|---|---|
| **Flutter 3.x** | UI framework |
| **Dart 3.x** | Programming language |
| **Provider** | State management |
| **Firebase Auth REST API** | User authentication |
| **Firebase Realtime DB REST API** | Task & user data storage |
| **http** | HTTP requests |
| **shared_preferences** | Local session persistence |
| **intl** | Date formatting |

> 💡 No Firebase SDK is used — all Firebase communication is done via pure REST API calls using the `http` package.

---

## ⚙️ Setup

### Prerequisites

| Tool | Version |
|---|---|
| Flutter SDK | 3.x (stable) |
| Dart SDK | ≥ 3.0.0 |
| Android Studio | Latest |
| VS Code | Latest |

### Step 1 — Clone the repository

```bash
git clone https://github.com/YourUsername/flutter_todo_app.git
cd flutter_todo_app
```

### Step 2 — Create your Firebase project

1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Click **Add project** → name it `TodoFlow`
3. Enable **Email/Password Authentication**
   - Authentication → Sign-in method → Email/Password → Enable
4. Create **Realtime Database**
   - Realtime Database → Create Database → Locked mode
5. Apply security rules from `firebase_rules.json`

### Step 3 — Add your Firebase credentials

Copy the example config file:

```bash
cp lib/core/constants/app_config.example.dart lib/core/constants/app_config.dart
```

Open `lib/core/constants/app_config.dart` and fill in your values:

```dart
static const String firebaseDbUrl =
    'https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com';

static const String firebaseApiKey = 'YOUR_FIREBASE_WEB_API_KEY';
```

**Where to find these values:**
- **Database URL** → Firebase Console → Realtime Database → Data tab (URL at top)
- **API Key** → Firebase Console → Project Settings → Your apps → Web app → `apiKey`

### Step 4 — Install dependencies

```bash
flutter pub get
```

---

## 🚀 Running

### Run on Chrome (Web)
```bash
flutter run -d chrome
```

### Run on Android (Debug APK)
```bash
flutter run -d android
```

### Build APK
```bash
flutter build apk --debug
```
APK location: `build/app/outputs/flutter-apk/app-debug.apk`

### Install APK on connected phone
```bash
flutter install --use-application-binary build\app\outputs\flutter-apk\app-debug.apk
```

---

## 🔒 Firebase Security Rules

```json
{
  "rules": {
    "tasks": {
      "$uid": {
        ".read": "auth != null && auth.uid == $uid",
        ".write": "auth != null && auth.uid == $uid"
      }
    },
    "users": {
      "$uid": {
        ".read": "auth != null && auth.uid == $uid",
        ".write": "auth != null && auth.uid == $uid"
      }
    }
  }
}
```

Each user can only read and write their own data.

---

## 🧠 State Management

### AuthProvider
Manages the full authentication lifecycle:

| State | Meaning |
|---|---|
| `uninitialized` | App just launched, checking stored session |
| `loading` | Sign in / sign up in progress |
| `authenticated` | User is logged in — show HomeScreen |
| `unauthenticated` | User is logged out — show LoginScreen |

### TaskProvider
Manages all task operations with optimistic UI updates:

| Operation | Behaviour |
|---|---|
| Fetch | Loads all tasks from Firebase on login |
| Add | Adds to UI instantly, then syncs to Firebase |
| Toggle | Updates UI immediately, rolls back if API fails |
| Delete | Removes from UI immediately, rolls back if API fails |
| Filter | All / Active / Completed — no new API call needed |

---

## 📋 Available Scripts

```bash
# Run on web
flutter run -d chrome

# Run on Android
flutter run -d android

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Clean build cache
flutter clean

# Install dependencies
flutter pub get

# Check Flutter installation
flutter doctor
```

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

---

<div align="center">

Built with ❤️ using Flutter & Firebase

By Kausalya N P

10/3/2026

</div>
