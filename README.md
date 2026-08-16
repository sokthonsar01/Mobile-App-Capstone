

## 1. Verify environment
Verify your environment by running:
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

The project uses `--dart-define-from-file` to load environment variables from the `config/` directory.

Ensure the following files exist in `config/`:

### `config/env_dev.json` (Development)
```json
{
  "ENVIRONMENT": "development",
  "APP_NAME": "Interna (Dev)",
  "API_BASE_URL": "https://dev/v1",
  "DEBUG_MODE": "true"
}
```

### `config/env_prod.json` (Production)
```json
{
  "ENVIRONMENT": "production",
  "APP_NAME": "Interna (Prod)",
  "API_BASE_URL": "https://api/v1",
  "DEBUG_MODE": "false"
}
```

---

## 5. Running the Application

### Option A: Via VS Code (Recommended)
1. Open the project in VS Code.
2. Press `Ctrl + Shift + D` (Run & Debug panel).
3. Select **`Interna (Dev)`** or **`Interna (Prod)`** from the top dropdown.
4. Press `F5` to start debugging.

### Option B: Via Terminal / Command Line

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

# Run on specific device
flutter run -d <DEVICE_ID> --dart-define-from-file=config/env_dev.json
```

---

## 6. Project Structure Overview

```text
├── config/
│   ├── env_dev.json         # Dev environment config
│   └── env_prod.json        # Prod environment config
├── lib/
│   ├── config/
│   │   └── app_env.dart     # AppEnv class reading environment variables
│   └── main.dart            # Application entry point
├── .vscode/
│   └── launch.json          # VS Code launch profiles
├── pubspec.yaml             # Project dependencies
└── README.md                # This setup documentation
```
