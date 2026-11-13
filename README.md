# Offline TikTok Player

A local offline video player (scrolls like TikTok) with a personal About/Settings page.

## Features
- Vertical swipe video feed, auto-plays local `.mp4` files from Camera / Movies / Download folders
- Tap a video to pause/resume
- Top-right ⓘ button opens **About & Settings**:
  - Developer photo and partner photo (bundled in the app itself — see below)
  - "Developed by Suleyman Abdu"
  - Tappable Email → opens mail app addressed to `suleymanabdu0931@gmail.com`
  - Tappable Phone → opens dialer with `0931798929`
  - Partnership box with Tesnim Nuru's photo and name, for orders/collaboration

## Profile photo (user-uploaded)

The side avatar on the feed and the **Profile** tab use a photo you pick from your
gallery. Tap the avatar (+) on a video, or open **Profile → Upload profile photo**.
The image is saved on the device only (not bundled in the APK).

Developer / partner photos on the About screen are still bundled assets for branding:
- `assets/images/img_smia61tj.png` → developer photo (Suleyman Abdu)
- `assets/images/img_pfpuooh0.png` → partner photo (Tesnim Nuru) / default avatar fallback

## Project layout note

This zip contains only the app-specific files (not a full Flutter scaffold — no
`android/gradle`, `ios/`, etc). If you don't already have a Flutter project set up:

```
flutter create offline_tiktok_player
```

Then copy these files into it, overwriting the generated ones:
- `pubspec.yaml` → project root
- `lib/main.dart` → `lib/main.dart`
- `assets/images/` → project root (new folder)
- `android/app/src/main/AndroidManifest.xml` → same path
- `android/app/src/main/res/values/styles.xml` → same path
- `android/app/src/main/res/values-night/styles.xml` → same path

## How to run

```
flutter pub get
flutter run
```

Make sure you have some `.mp4` files in your phone's Camera, Movies, or Download folder
so the feed has something to show.
