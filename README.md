# City Empire — Starter 0.1

An offline Android city-builder prototype built with Flutter and `three_js`.

## Prototype features
- Real 3D scene with a simple modern district
- One-finger camera panning
- Two-finger camera rotation and zoom
- Build-house button with a basic money cost
- Local save for money, building count and population

## Requirements
- Flutter stable
- Android SDK
- Android device with OpenGL ES support

## Run locally
```bash
flutter create --platforms=android --project-name city_empire .
flutter pub get
flutter run
```

## Build APK locally
```bash
flutter build apk --release
```

## Build APK on GitHub
1. Create a GitHub repository named `city-empire`.
2. Upload the contents of this folder to the repository root.
3. Push to the `main` branch, or open Actions and run **Build City Empire APK** manually.
4. Download the `city-empire-android-apk` artifact from the workflow run.

## Notes
This is a first technical prototype, not a finished game. The 3D renderer package and Android build must be tested on the target device. The current save stores basic counters; city layout persistence, proper tile placement, offline income, sound, assets and performance tuning are later milestones.
