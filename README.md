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

For GitHub, use one of these approaches:

1. Upload the video to YouTube, Google Drive, or GitHub Releases, then link it in this README.
2. Put the file in the repo, for example `mobile_app/assets/demo/demo.mp4`, and link it like this:

```md
[Watch the demo video](assets/demo/demo.mp4)
```

3. If you add a thumbnail image, make it clickable:

```md
[![SmartHome Demo](assets/demo/thumbnail.png)](assets/demo/demo.mp4)
```

For the best GitHub README experience, use a hosted video page or a release asset. Raw MP4 links work, but GitHub usually shows them as links rather than an embedded player.
