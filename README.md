# SmartHome Mobile App

Flutter mobile app for the SmartHome project. It is the front-end used to sign in, view live system data, and control home devices.

## What it does

- User login with backend authentication.
- Biometric sign-in with secure credential storage.
- Live dashboard for temperature, soil moisture, gas level, visitor status, security, garage, lights, and pump.
- Smart home controls through the backend API.
- Voice assistant, notifications, and alert handling for active events.

## Main screens

- Login page
- Dashboard page
- Control page
- Settings page

## Requirements

- Flutter SDK 3.x
- Android Studio, Xcode, or the platform tools you use for Flutter
- Backend server reachable from the phone or emulator

## Configuration

Check the app configuration in the project and update the backend URL or IP address if needed. The app expects the backend to be reachable on the local network when testing on a physical device.

## Install

```bash
flutter pub get
```

## Run

```bash
flutter run
```

If you use the Android helper script provided in the repo:

```powershell
.\run_android.ps1
```

## Demo video

The project demonstration is available here:

[Watch the SmartHome demo](assets/demo/demo.mp4)

The video is stored in `assets/demo/demo.mp4` and tracked with Git LFS. GitHub may display it as a file link instead of an embedded player because it is a large MP4.
