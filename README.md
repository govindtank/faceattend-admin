# FaceAttend Admin

> 🖥️ Admin dashboard for the FaceAttend AI-powered face recognition attendance system.

[![Flutter](https://img.shields.io/badge/Flutter-3.24.0-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Web-42A5F5?logo=web)](https://flutter.dev/web)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## ✨ Features

- **📊 Dashboard** — Real-time overview with key metrics: total employees, active staff, attendance records
- **👥 Employee Management** — Add, edit, search, and manage employees with department & position details
- **📋 Attendance Reports** — View and filter attendance records by date with check-in/out tracking
- **⚙️ Settings** — Account, notifications, sync, and security configuration
- **📱 Responsive Design** — Optimized for desktop, tablet, and mobile screens
- **🎨 Material 3 UI** — Clean, professional blue-themed interface with sidebar navigation

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | [Flutter 3.24.0](https://flutter.dev) |
| State Management | [Provider](https://pub.dev/packages/provider) |
| HTTP Client | [http](https://pub.dev/packages/http) |
| Date Formatting | [intl](https://pub.dev/packages/intl) |
| Local Storage | [shared_preferences](https://pub.dev/packages/shared_preferences) |
| Platform | Web (Flutter Web) |

---

## 📁 Project Structure

```
admin_panel/
├── lib/
│   ├── main.dart                    # App entry point & theme config
│   ├── screens/
│   │   ├── login_screen.dart        # Authentication screen
│   │   ├── dashboard_screen.dart     # Main dashboard with stats
│   │   ├── employee_management_screen.dart  # Employee CRUD
│   │   ├── attendance_reports_screen.dart   # Attendance logs
│   │   └── settings_screen.dart      # App settings
│   ├── services/
│   │   ├── auth_service.dart         # Authentication logic
│   │   ├── employee_service.dart     # Employee API calls
│   │   └── attendance_service.dart   # Attendance API calls
│   └── models/
│       └── employee_model.dart       # Employee data model
├── build/web/                       # Production web build
└── pubspec.yaml                     # Dependencies
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.24.0 or higher
- Chrome (for web development)

### Installation

```bash
# Clone the repository
git clone https://github.com/govindtank/faceattend-admin.git
cd faceattend-admin

# Install dependencies
flutter pub get

# Run the app
flutter run -d chrome
```

### Build for Web

```bash
# Release build with base-href for GitHub Pages
flutter build web --release --base-href /faceattend-admin/

# Serve locally
cd build/web && python3 -m http.server 8080
```

---

## 🔌 API Configuration

The app connects to a backend API at `http://localhost:5000`. Update the endpoints in:

- `lib/services/auth_service.dart`
- `lib/services/employee_service.dart`
- `lib/services/attendance_service.dart`

**Expected Endpoints:**

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | Admin login |
| GET | `/api/employees` | List employees |
| POST | `/api/employees` | Add employee |
| GET | `/api/attendance/reports` | Get attendance records |
| POST | `/api/attendance` | Record attendance |

---

## 🌐 Live Demo

🔗 **https://govindtank.github.io/faceattend-admin/**

---

## 🤝 Companion App

The mobile companion app for employees is available at:

📱 [govindtank/faceattend-mobile](https://github.com/govindtank/faceattend-mobile)

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

Built with ❤️ using Flutter · Powered by Face Recognition AI
