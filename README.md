<div align="center">

#  Stellantis Dealer Hygiene App

### *Intelligent Audit Management System for Stellantis Dealerships*

[![Flutter](https://img.shields.io/badge/Flutter-3.10.8-02569B?style=flat&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10.8-0175C2?style=flat&logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-brightgreen.svg)](https://flutter.dev)

[Features](#-features) • [Getting Started](#-getting-started) • [Installation](#-installation) • [Architecture](#-architecture) • [Documentation](#-documentation)

---

</div>

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Screenshots](#-screenshots)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Getting Started](#-getting-started)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Project Structure](#-project-structure)
- [API Documentation](#-api-documentation)
- [Development](#-development)
- [Testing](#-testing)
- [Deployment](#-deployment)
- [Contributing](#-contributing)
- [Team](#-team)
- [License](#-license)

---

## 🎯 Overview

The **Stellantis Dealer Hygiene App** is a comprehensive mobile application designed to streamline and modernize hygiene audit processes across Stellantis dealership networks. Built with Flutter for cross-platform compatibility, the app provides an intuitive interface for conducting, managing, and analyzing facility hygiene audits in real-time.

### 🎯 Key Objectives

- **Digitize** traditional paper-based audit processes
- **Standardize** hygiene compliance across all dealerships
- **Accelerate** audit completion with AI-powered analysis
- **Enhance** data accuracy and reporting capabilities
- **Empower** managers with real-time insights and analytics

---

## ✨ Features

### 🔐 Authentication & Authorization
- Secure user login and registration
- Role-based access control (Dealer & Manager roles)
- Session persistence and auto-login
- Password encryption and secure storage

### 📸 AI-Powered Audit Analysis
- Camera integration for on-site photo capture
- Real-time AI analysis of hygiene conditions
- Automated compliance scoring
- Confidence-based assessment recommendations
- Support for both camera and gallery image sources

### 📝 Manual Audit Management
- Comprehensive multi-level audit hierarchy:
  - **Zones** → **Facilities** → **Levels** → **Subcategories** → **Checkpoints**
- Dynamic audit entry with customizable checkpoints
- Real-time compliance tracking
- Progress indicators and status monitoring
- Detailed checkpoint annotations and comments

### 👔 Manager Portal
- Facility-wide audit overview
- Zone-based audit management
- Historical audit data and trends
- Team performance analytics
- Audit approval and review workflow

### 📊 Reporting & Analytics
- Compliance score calculation
- Visual progress indicators
- Audit history and timeline
- Export capabilities for reporting
- Real-time synchronization with backend

### 🌐 Offline Support
- Local data persistence
- Sync when connectivity restored
- Cached audit data for field operations

### 🎨 User Experience
- Modern Material Design UI
- Stellantis brand-compliant color scheme
- Intuitive navigation and workflows
- Responsive design for tablets and phones
- Dark mode support (planned)



## 🏗️ Architecture

### System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Mobile App                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   UI Layer   │  │  Services    │  │    Models    │      │
│  │  (Screens &  │─▶│  (Business   │─▶│  (Data      │      │
│  │   Widgets)   │  │    Logic)    │  │   Classes)   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                  │                  │              │
│         └──────────────────┼──────────────────┘              │
│                            │                                 │
└────────────────────────────┼─────────────────────────────────┘
                             │
                    ┌────────▼─────────┐
                    │   API Gateway    │
                    │  (REST/JSON)     │
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │  EC2 Backend     │
                    │ 54.204.123.13    │
                    │    Port 8000     │
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │    Database      │
                    │  (PostgreSQL)    │
                    └──────────────────┘
```

### Design Patterns

- **Service Layer Pattern**: Separation of business logic from UI
- **Repository Pattern**: Data access abstraction
- **Singleton Pattern**: Service instance management
- **Observer Pattern**: State management and reactivity
- **Factory Pattern**: Object creation and initialization

---

## 🛠️ Tech Stack

### Frontend
- **Framework**: Flutter 3.10.8
- **Language**: Dart 3.10.8
- **UI**: Material Design Components
- **State Management**: StatefulWidget with async operations

### Backend Integration
- **API Protocol**: RESTful API
- **HTTP Client**: Dio + HTTP package
- **Serialization**: JSON
- **Authentication**: Token-based (JWT)

### Local Storage
- **Shared Preferences**: User settings and session data
- **File System**: Image caching

### Media
- **Image Picker**: Camera and gallery integration
- **Image Processing**: Real-time compression and optimization

### Development Tools
- **Version Control**: Git
- **IDE**: VS Code / Android Studio
- **Build Tool**: Flutter CLI
- **Linting**: flutter_lints 6.0.0

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK**: 3.10.8 or higher
  ```bash
  flutter --version
  ```
- **Dart SDK**: 3.10.8 or higher (bundled with Flutter)
- **Android Studio** (for Android development) or **Xcode** (for iOS)
- **Git**: For version control
- **VS Code** or **Android Studio** (recommended IDEs)

### System Requirements

#### Android Development
- Android SDK 21 or higher
- Android Studio with Android SDK tools
- Java Development Kit (JDK) 11 or higher

#### iOS Development (macOS only)
- macOS 10.15 or higher
- Xcode 12 or higher
- CocoaPods 1.11 or higher

---

## 📥 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/stellantis-dealer-hygeine.git
cd stellantis-dealer-hygeine
```

### 2. Install Dependencies

```bash
flutter pub get
```

This will install all required packages defined in `pubspec.yaml`:
- `http` & `dio`: API communication
- `shared_preferences`: Local storage
- `image_picker`: Camera integration
- `intl`: Internationalization

### 3. Verify Installation

```bash
flutter doctor
```

Ensure all checks pass. Fix any issues reported.

### 4. Run the Application

#### For Android
```bash
flutter run
```

#### For iOS
```bash
flutter run -d ios
```

#### For Web
```bash
flutter run -d chrome
```

#### For Production Build
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## ⚙️ Configuration

### API Configuration

The app connects to a production EC2 backend by default. Configuration is in [lib/config/api_config.dart](lib/config/api_config.dart):

```dart
static const String _productionUrl = 'http://54.204.123.13:8000';
static const String apiPrefix = '/api/v1';
```

### Feature Flags

Enable/disable features using [lib/config/feature_flags.dart](lib/config/feature_flags.dart):

```dart
class FeatureFlags {
  // Bypass authentication for development
  static const bool bypassAuth = bool.fromEnvironment('BYPASS_AUTH', defaultValue: false);
}
```

**Run with bypassed auth:**
```bash
flutter run --dart-define=BYPASS_AUTH=true
```

### Environment Variables

Create a `.env` file (not tracked in git) for sensitive configuration:

```env
API_BASE_URL=http://54.204.123.13:8000
API_VERSION=v1
ENABLE_LOGGING=true
```

---

## 📁 Project Structure

```
stellantis-dealer-hygeine/
│
├── lib/
│   ├── main.dart                    # Application entry point
│   ├── app.dart                     # Root app widget
│   │
│   ├── config/                      # Configuration files
│   │   ├── api_config.dart          # API endpoints and URLs
│   │   ├── auth_mode.dart           # Authentication modes
│   │   └── feature_flags.dart       # Feature toggles
│   │
│   ├── constants/                   # App-wide constants
│   │   ├── app_colors.dart          # Color palette
│   │   ├── app_text_styles.dart     # Typography styles
│   │   └── stellantis_colors.dart   # Brand colors
│   │
│   ├── models/                      # Data models
│   │   ├── audit.dart               # Audit entity
│   │   ├── facility.dart            # Facility entity
│   │   ├── shift.dart               # Shift model
│   │   └── user_role.dart           # User roles enum
│   │
│   ├── screens/                     # UI screens
│   │   ├── login_page.dart          # Authentication
│   │   ├── signup_page.dart         # Registration
│   │   ├── dealer_home_page.dart    # Dealer dashboard
│   │   ├── manager_home_page.dart   # Manager dashboard
│   │   ├── audit_entry_page.dart    # Main audit screen
│   │   ├── ai_audit_analysis_page.dart  # AI analysis results
│   │   └── ...                      # Other screens
│   │
│   ├── services/                    # Business logic
│   │   ├── api_client.dart          # HTTP client wrapper
│   │   ├── auth_service.dart        # Authentication logic
│   │   ├── audit_service.dart       # Audit operations
│   │   ├── camera_ai_service.dart   # AI camera integration
│   │   ├── manual_audit_service.dart # Manual audit logic
│   │   └── storage_service.dart     # Local storage
│   │
│   └── widgets/                     # Reusable components
│       ├── custom_text_field.dart   # Styled input field
│       ├── custom_dropdown.dart     # Dropdown component
│       ├── role_card.dart           # Role selection card
│       └── stellantis_logo.dart     # Brand logo widget
│
├── assets/                          # Static assets
│   └── images/                      # Image files
│       ├── stellantis_logo.png
│       └── debabrata-das.png
│
├── android/                         # Android-specific code
├── ios/                             # iOS-specific code
├── web/                             # Web-specific code
├── test/                            # Test files
│
├── pubspec.yaml                     # Package dependencies
├── analysis_options.yaml            # Linter rules
└── README.md                        # This file
```

---

## 🔌 API Documentation

### Base URL
```
Production: http://54.204.123.13:8000/api/v1
```

### Authentication Endpoints

#### Login
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "username": "dealeChinr@example.com",
  "password": "Password123"
}

Response:
{
  "token": "eyJhbGciOiJIUzI1...",
  "user": {
    "id": "uuid",
    "name": "Chin",
    "role": "dealer"
  }
}
```

#### Register
```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "name": "Chin",
  "email": "dealerChin@example.com",
  "password": "Password123",
  "role": "dealer"
}
```

### Audit Endpoints

#### Get Audits
```http
GET /api/v1/audits?dealerId={dealerId}
Authorization: Bearer {token}
```

#### Create Audit
```http
POST /api/v1/audits
Authorization: Bearer {token}
Content-Type: application/json

{
  "dealerId": "uuid",
  "facilityId": "uuid",
  "checkpoints": [...]
}
```

#### AI Analysis
```http
POST /api/v1/ai/analyze
Authorization: Bearer {token}
Content-Type: multipart/form-data

image: [binary]
checkpointId: "uuid"
dealerId: "uuid"
```

### Error Handling

All API responses follow a consistent error format:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid credentials provided",
    "details": {}
  }
}
```

---

## 💻 Development

### Code Style

This project follows the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style).

**Run linter:**
```bash
flutter analyze
```

**Format code:**
```bash
dart format lib/
```

### Git Workflow

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make changes and commit:**
   ```bash
   git add .
   git commit -m "feat: add new audit analysis feature"
   ```

3. **Push and create PR:**
   ```bash
   git push origin feature/your-feature-name
   ```

### Commit Message Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting)
- `refactor:` Code refactoring
- `test:` Test additions or changes
- `chore:` Build process or auxiliary tool changes

---

## 🧪 Testing

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/widget_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### Widget Testing Example
```dart
testWidgets('Login page renders correctly', (WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: LoginPage()));
  
  expect(find.text('Login'), findsOneWidget);
  expect(find.byType(TextField), findsNWidgets(2));
});
```

---

## 🚢 Deployment

### Android Deployment

1. **Update version** in `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2
   ```

2. **Build signed APK:**
   ```bash
   flutter build apk --release
   ```

3. **Build App Bundle** (recommended for Play Store):
   ```bash
   flutter build appbundle --release
   ```

4. **Output location:**
   ```
   build/app/outputs/bundle/release/app-release.aab
   build/app/outputs/apk/release/app-release.apk
   ```

### iOS Deployment

1. **Update build number** in `ios/Runner/Info.plist`

2. **Build iOS app:**
   ```bash
   flutter build ios --release
   ```

3. **Open Xcode and Archive:**
   ```bash
   open ios/Runner.xcworkspace
   ```

4. **Upload to App Store Connect** via Xcode

### Web Deployment

```bash
flutter build web --release
```

Deploy the `build/web` directory to your hosting provider.

---

## 🤝 Contributing

We welcome contributions from the Stellantis development team!

### Guidelines

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'feat: add amazing feature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

### Pull Request Process

- Ensure your code passes all tests: `flutter test`
- Update documentation if needed
- Follow the existing code style
- Add meaningful commit messages
- Request review from at least one team member

### Code Review Checklist

- [ ] Code follows style guidelines
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No console errors or warnings
- [ ] Builds successfully on all platforms
- [ ] UI/UX approved by design team

---


### Acknowledgments
- Stellantis Engineering Team
- Flutter Community
- Open Source Contributors

---

## 📄 License

```
Copyright © 2026 STELLANTIS N.V. - INTERNAL USE ONLY

This software is proprietary and confidential.
Unauthorized copying, distribution, or use is strictly prohibited.

For licensing inquiries, contact: legal@stellantis.com
```

---

## 📞 Contact & Support

### Technical Support
- **Email**: dev-support@stellantis.com
- **Slack**: #stellantis-hygiene-app
- **Issue Tracker**: [GitHub Issues](https://github.com/your-org/stellantis-dealer-hygeine/issues)

### Documentation
- **Wiki**: [Project Wiki](https://github.com/your-org/stellantis-dealer-hygeine/wiki)
- **API Docs**: [API Reference](https://api.stellantis.com/docs)
- **User Guide**: [End-User Documentation](https://docs.stellantis.com/hygiene-app)

---

## 🎉 Acknowledgments

Special thanks to:

- **Stellantis Leadership** for supporting this digital transformation initiative
- **Dealership Network** for valuable feedback and testing
- **Flutter Team** for an excellent cross-platform framework
- **Open Source Community** for the amazing packages and tools

---

<div align="center">

### Made with ❤️ for Stellantis

**[Website](https://www.stellantis.com/)** • **[Documentation](https://docs.stellantis.com)** • **[Support](mailto:dev-support@stellantis.com)**

</div>
