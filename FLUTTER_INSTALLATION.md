# Flutter Installation Guide for Windows

## Quick Installation (Recommended)

### Option 1: Automated Installation Script

Run the provided installation script:

```powershell
# Run in PowerShell (Administrator mode recommended)
cd d:\wordflow
.\install_flutter.ps1
```

The script will:
1. Download Flutter SDK to `C:\src\flutter`
2. Extract the files
3. Add Flutter to your PATH
4. Run `flutter doctor` to verify installation

After the script completes:
1. **Close and reopen PowerShell** to refresh PATH
2. Verify: `flutter --version`
3. Continue with project setup

---

### Option 2: Manual Installation

If the script doesn't work, follow these manual steps:

#### Step 1: Download Flutter SDK

1. Visit: https://docs.flutter.dev/get-started/install/windows
2. Download the latest stable release (currently 3.27.1)
3. Or download directly: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.27.1-stable.zip

#### Step 2: Extract Flutter

```powershell
# Create directory
New-Item -ItemType Directory -Path "C:\src" -Force

# Extract downloaded zip to C:\src\flutter
# You should now have: C:\src\flutter\bin\flutter.bat
```

#### Step 3: Add to PATH

**Method A: Using PowerShell (Administrator)**

```powershell
# Add Flutter to User PATH
$flutterPath = "C:\src\flutter\bin"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$newPath = "$currentPath;$flutterPath"
[Environment]::SetEnvironmentVariable("Path", $newPath, "User")

# Refresh current session
$env:Path = [Environment]::GetEnvironmentVariable("Path", "User") + ";" + [Environment]::GetEnvironmentVariable("Path", "Machine")
```

**Method B: Using Windows Settings**

1. Open Start Menu → Search "Environment Variables"
2. Click "Edit the system environment variables"
3. Click "Environment Variables" button
4. Under "User variables", select "Path" → Click "Edit"
5. Click "New" → Add `C:\src\flutter\bin`
6. Click "OK" on all dialogs
7. **Restart PowerShell**

#### Step 4: Verify Installation

```powershell
# Close and reopen PowerShell, then:
flutter --version
flutter doctor
```

---

## After Flutter Installation

### 1. Run Flutter Doctor

```powershell
flutter doctor
```

This will show what additional tools you need:

```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.27.1, on Microsoft Windows)
[✗] Windows Version (Unable to confirm if installed Windows version is 10 or greater)
[!] Android toolchain - develop for Android devices
[!] Chrome - develop for the web
[!] Visual Studio - develop Windows apps
[✓] VS Code (version 1.85.0)
[✓] Connected device (1 available)
[✓] Network resources
```

### 2. Install Required Tools

#### For Windows Development (Required for this project)
```powershell
# Install Visual Studio 2022 Community Edition
# Download from: https://visualstudio.microsoft.com/downloads/

# During installation, select:
# - "Desktop development with C++"
# - Windows 10 SDK

# After installation:
flutter doctor
```

#### For Android Development (Optional)
```powershell
# Install Android Studio
# Download from: https://developer.android.com/studio

# After installation, run:
flutter doctor --android-licenses
```

### 3. Setup WordFlow Project

Once Flutter is installed:

```powershell
# Navigate to project
cd d:\wordflow

# Get dependencies
flutter pub get

# Run on Windows
flutter run -d windows
```

---

## Troubleshooting

### Issue: "flutter: command not found" after installation

**Solution 1:** Restart PowerShell
```powershell
# Close PowerShell completely and open a new window
```

**Solution 2:** Manually refresh PATH
```powershell
$env:Path = [Environment]::GetEnvironmentVariable("Path", "User") + ";" + [Environment]::GetEnvironmentVariable("Path", "Machine")
flutter --version
```

**Solution 3:** Use full path temporarily
```powershell
C:\src\flutter\bin\flutter.bat --version
C:\src\flutter\bin\flutter.bat pub get
```

### Issue: Slow download or network error

**Solution:** Use a mirror (for users in China or with slow connections)
```powershell
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"
flutter doctor
```

### Issue: "Windows version not detected"

**Solution:** This is usually safe to ignore on Windows 10/11
```powershell
# Verify your Windows version
winver

# Continue with development if you're on Windows 10 or 11
```

### Issue: Permission denied during installation

**Solution:** Run PowerShell as Administrator
1. Right-click PowerShell
2. Select "Run as Administrator"
3. Run installation script again

### Issue: Visual Studio not detected

**Solution:** Ensure Visual Studio 2022 with C++ tools is installed
```powershell
# Download and install Visual Studio 2022 Community
# https://visualstudio.microsoft.com/downloads/

# Select "Desktop development with C++" workload
# Then run:
flutter doctor
```

---

## Quick Reference Commands

```powershell
# Check Flutter version
flutter --version

# Check system requirements
flutter doctor

# Get project dependencies
flutter pub get

# Run app on Windows
flutter run -d windows

# List available devices
flutter devices

# Clean build cache
flutter clean

# Update Flutter
flutter upgrade
```

---

## Estimated Time

- **Download Flutter**: 5-10 minutes (depends on internet speed)
- **Installation**: 2-3 minutes
- **Visual Studio 2022**: 30-60 minutes (if needed)
- **Project setup**: 1-2 minutes

**Total for basic Windows dev**: ~10-15 minutes  
**Total with Visual Studio**: ~45-75 minutes

---

## Need Help?

1. **Flutter Documentation**: https://docs.flutter.dev/
2. **Flutter Installation Guide**: https://docs.flutter.dev/get-started/install/windows
3. **Troubleshooting**: https://docs.flutter.dev/get-started/install/windows#troubleshooting

After installation, proceed with the project setup in [QUICKSTART.md](QUICKSTART.md)
