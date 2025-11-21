# HealthAlert Frontend

Mobile application for emergency health communication in rural and refugee settlements. Built with Flutter

##  About

A phone number-based authentication system with role-based access for:
- **VHT (Village Health Team)**: Emergency case creation, immunization tracking
- **Ambulance Drivers**: Case response, navigation
- **Clinic Staff**: Patient management, triage
- **Admins**: System monitoring, analytics

##  Target Devices

- **Minimum Android**: API 21 (Android 5.0 Lollipop, 2014)
- **Target Android**: API 34 (Android 14)
- **Coverage**: ~95% of Android devices in circulation

##  Prerequisites

- Flutter SDK (3.10.0 or higher)
- Android Studio or VS Code with Flutter extensions
- Firebase account
- Android device or emulator (API 21+)

##  Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/RichKitibwa/HealthAlertFrontEnd.git
cd health_app_frontend
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

#### a. Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

#### b. Configure Firebase

```bash
flutterfire configure
```

This will:
- Let you select/create a Firebase project
- Generate `firebase_options.dart`
- Configure Android app
- Download `google-services.json`

#### c. Enable Firebase Authentication

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Authentication** → **Sign-in method**
4. Enable **Phone** authentication
5. For testing, add test phone numbers

#### d. Enable Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
4. Select a region

### 4. Android Configuration

Update `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.yourcompany.health_app"
        minSdkVersion 21  // Supports older devices
        targetSdkVersion 34
        versionCode 1
        versionName "1.0"
        multiDexEnabled true  // Important for Firebase
    }
}
```

### 5. Run the App

#### Using Physical Android Device

```bash
# Connect Android device via USB with USB debugging enabled
flutter devices  # Check device is connected
flutter run
```

#### Using Emulator

```bash
# Create emulator with Android 5.0+ (API 21+)
# In Android Studio: Tools → Device Manager → Create Device

# Start emulator
flutter emulators --launch <emulator_name>

# Run app
flutter run
```

## 📁 Project Structure

```
lib/
├── main.dart                              # App entry point
├── data/
│   └── models/
│       └── user_model.dart               # User data model
├── services/
│   └── firebase_service.dart             # Firebase operations
└── features/                              # Feature modules
    ├── auth/                             # Authentication
    │   └── presentation/screens/
    │       ├── login_screen.dart         # Phone login
    │       └── register_screen.dart      # Registration form
    ├── vht/                              # Village Health Team
    │   └── presentation/screens/
    │       └── vht_welcome_screen.dart
    ├── ambulance/                        # Ambulance Driver
    │   └── presentation/screens/
    │       └── ambulance_welcome_screen.dart
    ├── clinic/                           # Clinic Staff
    │   └── presentation/screens/
    │       └── clinic_welcome_screen.dart
    └── admin/                            # Administrator
        └── presentation/screens/
            └── admin_welcome_screen.dart
```

