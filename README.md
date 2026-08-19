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

The project demo is stored at `assets/demo/demo.mp4`. After committing and pushing that file, use this link:

```md
[Watch the SmartHome demo](assets/demo/demo.mp4)
```

You can also use a hosted video link, such as YouTube or a GitHub Release asset:

```md
[Watch the SmartHome demo](https://example.com/your-video)
```

If you add a thumbnail image, make it clickable:

```md
[![SmartHome Demo](assets/demo/thumbnail.png)](assets/demo/demo.mp4)
```

GitHub will not show a local file until it is committed and pushed. A relative MP4 link usually opens the video or downloads it; a hosted video page gives the best README experience.
