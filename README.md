# TodoApp109 — Firebase Todo App

A simple and clean iOS task manager built with SwiftUI, Firebase Authentication, and Cloud Firestore. Built using a clean **MVVM (Models - Views - ViewModels)** architecture. Supports iPhone and iPad on iOS 17+.

## Project Architecture (MVVM)

```
tahmid109/
├── Models/
│   ├── TodoItem.swift              # Task data model & validation rules
│   ├── TaskFilter.swift            # Filter enum (All, Open, Done)
│   └── AppUser.swift               # Profile representation (Firebase / Demo)
│
├── Services/
│   ├── AuthService.swift           # AuthServiceProtocol & FirebaseAuthService
│   └── TaskService.swift           # TaskServiceProtocol & FirestoreTaskService
│
├── ViewModels/
│   ├── AppViewModel.swift          # Session coordinator, auth sync & state management
│   ├── AuthViewModel.swift         # Authentication form validation and actions
│   ├── TaskListViewModel.swift     # Workspace filtering, searching & dialog actions
│   └── TaskEditorViewModel.swift   # Task draft creation, editing & validation
│
├── Views/
│   ├── Theme/
│   │   └── NotebookTheme.swift     # Clean semantic AppTheme colors and layout metrics
│   ├── Components/
│   │   ├── WordmarkView.swift      # TodoApp109 header branding
│   │   ├── PaperButton.swift       # Simple action button with loading spinner
│   │   ├── TaskCardView.swift      # Simple task row with checkbox, title, note & options menu
│   │   └── SearchBarView.swift     # Clean search bar with clear button
│   ├── Auth/
│   │   └── AuthView.swift          # Simple Sign In / Create Account with demo access
│   ├── Workspace/
│   │   ├── WorkspaceView.swift     # Main task list dashboard (Add, Edit, Complete, Delete)
│   │   └── AccountSheetView.swift  # Profile modal with task statistics & sign out
│   └── Editor/
│       └── TaskEditorView.swift    # Clean modal Form for adding and editing tasks
│
├── ContentView.swift               # Root router between AuthView and WorkspaceView
└── tahmid109App.swift              # App lifecycle & Firebase configuration
```

## Connect your Firebase project

1. Open `tahmid109.xcodeproj` in Xcode. Swift Package Manager resolves FirebaseAuth and FirebaseFirestore.
2. Register an iOS app in Firebase with bundle ID **com.test.tahmid109** (or update the bundle identifier in Xcode).
3. Download **GoogleService-Info.plist** and place it in the **tahmid109/** source folder beside `tahmid109App.swift`.
4. In Firebase Authentication → Sign-in method, enable **Email/Password**.
5. In Cloud Firestore, create your database and publish the contents of `firestore.rules`.
6. Select an iOS Simulator or device and run.

Without `GoogleService-Info.plist`, the app automatically offers a local demo mode so you can test all features without connecting to Firebase.

## Validation

Build with Xcode:

```sh
xcodebuild -project tahmid109.xcodeproj -scheme tahmid109 \
  -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build
```
