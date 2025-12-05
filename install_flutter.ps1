# Flutter Installation Script for Windows
# Run this script in PowerShell (Administrator mode recommended)

Write-Host "=== Flutter Installation for Windows ===" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Warning: Not running as Administrator. Some steps may require elevated privileges." -ForegroundColor Yellow
    Write-Host ""
}

# Define installation directory
$installDir = "C:\src"
$flutterPath = "$installDir\flutter"

Write-Host "Step 1: Checking installation directory..." -ForegroundColor Green
if (-not (Test-Path $installDir)) {
    Write-Host "Creating directory: $installDir"
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}

Write-Host ""
Write-Host "Step 2: Downloading Flutter SDK..." -ForegroundColor Green
Write-Host "This may take a few minutes depending on your internet connection."
Write-Host ""

# Flutter SDK download URL (stable channel)
$flutterZipUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.27.1-stable.zip"
$zipPath = "$installDir\flutter_sdk.zip"

try {
    # Download Flutter
    Write-Host "Downloading from: $flutterZipUrl"
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $flutterZipUrl -OutFile $zipPath -UseBasicParsing
    $ProgressPreference = 'Continue'
    Write-Host "Check mark Download complete!" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "Step 3: Extracting Flutter SDK..." -ForegroundColor Green
    
    # Remove existing flutter directory if it exists
    if (Test-Path $flutterPath) {
        Write-Host "Removing existing Flutter installation..."
        Remove-Item -Path $flutterPath -Recurse -Force
    }
    
    # Extract
    Expand-Archive -Path $zipPath -DestinationPath $installDir -Force
    Write-Host "Extraction complete!" -ForegroundColor Green
    
    # Clean up zip file
    Remove-Item -Path $zipPath -Force
    
    Write-Host ""
    Write-Host "Step 4: Adding Flutter to PATH..." -ForegroundColor Green
    
    $flutterBinPath = "$flutterPath\bin"
    
    # Get current PATH
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    
    # Check if Flutter is already in PATH
    if ($currentPath -like "*$flutterBinPath*") {
        Write-Host "Flutter is already in PATH" -ForegroundColor Yellow
    } else {
        # Add to user PATH
        $newPath = "$currentPath;$flutterBinPath"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Host "Added Flutter to PATH!" -ForegroundColor Green
    }
    
    # Update current session PATH
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $env:Path = $userPath + ";" + $machinePath
    
    Write-Host ""
    Write-Host "Step 5: Running Flutter doctor..." -ForegroundColor Green
    Write-Host ""
    
    # Run flutter doctor
    & "$flutterBinPath\flutter.bat" doctor
    
    Write-Host ""
    Write-Host "=== Installation Complete! ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[OK] Flutter SDK installed at: $flutterPath" -ForegroundColor Green
    Write-Host "[OK] Flutter added to PATH" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Close and reopen PowerShell to refresh PATH"
    Write-Host "2. Run: flutter doctor"
    Write-Host "3. Navigate to your project: cd d:\wordflow"
    Write-Host "4. Run: flutter pub get"
    Write-Host ""
    Write-Host "Note: You may need to install additional tools shown by 'flutter doctor':" -ForegroundColor Yellow
    Write-Host "  - Visual Studio 2022 (for Windows development)"
    Write-Host "  - Android Studio (for Android development)"
    Write-Host "  - Chrome or Edge (for web development)"
    Write-Host ""
    
} catch {
    Write-Host "Error occurred: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Manual installation steps:" -ForegroundColor Yellow
    Write-Host "1. Download Flutter SDK from: https://docs.flutter.dev/get-started/install/windows"
    Write-Host "2. Extract to C:\src\flutter"
    Write-Host "3. Add C:\src\flutter\bin to your PATH"
    Write-Host "4. Restart PowerShell"
    Write-Host "5. Run: flutter doctor"
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
