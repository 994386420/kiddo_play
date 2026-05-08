# Kiddo Play

Flutter scaffold for a preschool kids puzzle game.

## Included

- Splash-free app shell
- Home page
- Game select page
- Color match game page
- Reward page
- Shared theme and reusable action button

## Run

```bash
flutter pub get
flutter run
```

## iOS Signing

Local iOS signing is configured through `ios/Flutter/Signing.xcconfig`, which is ignored by git.

```bash
./scripts/configure_ios_signing.sh <APPLE_TEAM_ID> com.cw.kiddo.play
```

Use a bundle ID that is unique in your Apple Developer account. If Apple says `com.cw.kiddo.play` is unavailable, choose another identifier under your own prefix.
