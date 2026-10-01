# Interna

Interna is a cross-platform mobile and web internship discovery platform built with Flutter. It connects students and job seekers with internship opportunities, supporting direct company exploration, real-time messaging, application tracking, and profile management with cloud-synced resume uploads.

---

## Table of Contents

- [System Architecture](#system-architecture)
- [1. Verify Environment](#1-verify-environment)
- [2. Clone the Repository](#2-clone-the-repository)
- [3. Install Dependencies](#3-install-dependencies)
- [4. Environment Configuration](#4-environment-configuration)
- [5. Running the Application](#5-running-the-application)
- [6. Project Structure Overview](#6-project-structure-overview)
- [7. Troubleshooting](#7-troubleshooting)

---

## System Architecture

The application is structured around a feature-first **MVVM (Model-View-ViewModel)** architecture:

- **Model**: Data transfer objects, JSON parsing, and repository abstractions (`lib/features/*/data/`).
- **View**: Responsive presentation screens and reusable widgets (`lib/features/*/presentation/`).
- **ViewModel**: State management through Dart's native `ChangeNotifier` and `ListenableBuilder` (`lib/features/*/viewmodel/`), avoiding heavyweight third-party framework overhead.
- **Backend & Storage**:
  - **REST API**: NestJS backend handling business logic and application records.
  - **Auth & Storage**: Supabase handling user authentication and public document storage (`resumes` bucket).
  - **Document Preview**: `url_launcher` handling 1-tap in-app viewing via Chrome Custom Tabs (Android), SFSafariViewController (iOS), and browser tabs (Web).

---

## 1. Verify Environment

Verify your Flutter installation:
```bash
flutter doctor
```

---

## 2. Clone the Repository

```bash
git clone https://github.com/sokthonsar01/Mobile-App-Capstone.git
cd interna
```

---

## 3. Install Dependencies

Fetch all project packages:
```bash
flutter pub get
```

---

## 4. Environment Configuration

The project uses `--dart-define-from-file` to load runtime environment configurations from the `config/` directory.

Ensure the configuration files exist:

### `config/env_dev.json` (Development)
```json
{
  "ENVIRONMENT": "development",
  "APP_NAME": "Interna (Dev)",
  "API_BASE_URL": "https://interna-backend-b6hy.onrender.com",
  "SUPABASE_URL": "https://fujimqtgrthnslpwjkqf.supabase.co",
  "SUPABASE_ANON_KEY": "YOUR_SUPABASE_ANON_KEY",
  "DEBUG_MODE": "true"
}
```

### `config/env_prod.json` (Production)
```json
{
  "ENVIRONMENT": "production",
  "APP_NAME": "Interna (Prod)",
  "API_BASE_URL": "https://interna-backend-b6hy.onrender.com",
  "SUPABASE_URL": "https://fujimqtgrthnslpwjkqf.supabase.co",
  "SUPABASE_ANON_KEY": "YOUR_SUPABASE_ANON_KEY",
  "DEBUG_MODE": "false"
}
```

---

## 5. Running the Application

### Option A: Via VS Code (Recommended)
1. Open the project in VS Code.
2. Open the Run & Debug panel (`Ctrl + Shift + D`).
3. Select **Interna (Dev)** or **Interna (Prod)** from the dropdown.
4. Press `F5` to start debugging.

### Option B: Via Terminal

#### Run on Web (Chrome):
```bash
# Development
flutter run -d chrome --dart-define-from-file=config/env_dev.json

# Production
flutter run -d chrome --dart-define-from-file=config/env_prod.json
```

#### Run on Android / iOS / Connected Device:
```bash
# List available devices
flutter devices

# Run on specific target
flutter run -d <DEVICE_ID> --dart-define-from-file=config/env_dev.json
```

---

## 6. Project Structure Overview

```text
├── config/
│   ├── env_dev.json         # Dev environment variables
│   └── env_prod.json        # Prod environment variables
├── lib/
│   ├── config/              # AppEnv mapping runtime variables
│   ├── features/            # Feature modules (MVVM structure)
│   │   ├── applications/    # Job application tracking
│   │   ├── auth/            # Sign in, sign up, password recovery
│   │   ├── chat/            # In-app messaging
│   │   ├── company/         # Company profiles and listings
│   │   ├── home/            # Dashboard and job discovery
│   │   ├── notifications/   # System and activity alerts
│   │   ├── profile/         # User profile and CV management
│   │   ├── saved/           # Bookmarked jobs
│   │   └── splash/          # App initialization screen
│   ├── shared/              # Reusable design tokens and theme colors
│   └── main.dart            # Application entry point
├── .vscode/
│   └── launch.json          # Pre-configured debug profiles
├── pubspec.yaml             # Dependencies and assets
└── README.md                # Project documentation
```

---

## 7. Troubleshooting

<details>
<summary><b>1. Supabase 400 Bad Request: Invalid file URL / bucket name mismatch</b></summary>
<br/>

- **Symptom**: Backend rejects the uploaded CV with `Invalid file URL. Resumes must be uploaded to the official Interna storage bucket.`
- **Cause**: The NestJS backend enforces strict regex validation on the resume URL. It expects the plural bucket name `resumes`. Uploading to `resume` (singular) fails this check.
- **Fix**: Ensure the upload target bucket in `cv_viewmodel.dart` and `resume_repository.dart` is set to `resumes`. The URL must follow the format:
  `https://<project-ref>.supabase.co/storage/v1/object/public/resumes/<filename>`
</details>

<details>
<summary><b>2. Supabase 403 Forbidden: Row-level security (RLS) violation</b></summary>
<br/>

- **Symptom**: Upload fails with `statusCode: 403, error: Unauthorized, message: new row violates row-level security policy`.
- **Cause**: The Supabase `resumes` bucket lacks storage policies allowing authenticated uploads or public reads.
- **Fix**: Open Supabase Dashboard > Storage > `resumes` bucket > Configuration > Policies:
  1. Add an `INSERT` policy for `authenticated` users: `bucket_id = 'resumes'`.
  2. Add a `SELECT` policy allowing public read access: `bucket_id = 'resumes'`.
</details>

<details>
<summary><b>3. MissingPluginException on Flutter Web</b></summary>
<br/>

- **Symptom**: Runtime crash `MissingPluginException(No implementation found for method ... on channel ...)` after adding a new dependency.
- **Cause**: Flutter Web compiles platform channel bindings on initial launch. Hot reload (`r`) or hot restart (`R`) cannot bind newly installed native/web packages into an already running session.
- **Fix**: Stop the dev server (`q` in the terminal) and run a full cold restart:
  ```bash
  flutter run -d chrome --dart-define-from-file=config/env_dev.json
  ```
</details>

<details>
<summary><b>4. Flutter Web Keyboard Assertion Error (_viewInsets.isNonNegative)</b></summary>
<br/>

- **Symptom**: Browser console logs `DartError: Assertion failed: _viewInsets.isNonNegative "ViewInsets cannot be negative"`.
- **Cause**: A known Flutter Web engine issue triggered when the browser window is resized rapidly or when mobile emulation dismisses the virtual keyboard before the layout pass finishes.
- **Fix**: This is an engine-level debug assertion that does not crash production builds. In development, avoid rapid browser devtools toggles, or click into an input field to let the layout recalculate.
</details>

<details>
<summary><b>5. Missing Environment Variables on App Launch</b></summary>
<br/>

- **Symptom**: API calls point to localhost or default fallbacks fail with connection refused.
- **Cause**: The app was launched with a bare `flutter run` command without passing the `--dart-define-from-file` flag.
- **Fix**: Always specify the config file during launch:
  ```bash
  flutter run -d chrome --dart-define-from-file=config/env_dev.json
  ```
  Or select the **Interna (Dev)** profile in VS Code Run & Debug.
</details>
