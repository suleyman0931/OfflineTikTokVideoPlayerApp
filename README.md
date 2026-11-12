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

## How the developer & partner photos work

Both photos are bundled directly in the app's code (`assets/images/`), **not** uploaded
from the phone's gallery. That means every person who installs the app sees the exact
same two pictures — nothing is stored per-device.

Right now these are placeholder images:
- `assets/images/img_smia61tj.png` → developer photo (Suleyman Abdu)
- `assets/images/img_pfpuooh0.png` → partner photo (Tesnim Nuru)

### To update either photo yourself later
1. Get your real photo as a `.png` (square photos look best, e.g. 400x400).
2. Replace the corresponding file in `assets/images/` with your new photo.
   - Easiest: keep the exact same filename so you don't have to touch any code.
   - Or: give it a new filename and update the matching constant at the top of
     `lib/main.dart`:
     ```dart
     const String kDeveloperPhotoAsset = 'assets/images/YOUR_NEW_FILE.png';
     const String kPartnerPhotoAsset = 'assets/images/YOUR_NEW_FILE.png';
     ```
3. Run `flutter pub get` again (only needed if you changed filenames/added new files).
4. Rebuild the app (`flutter run` or `flutter build apk`).

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
