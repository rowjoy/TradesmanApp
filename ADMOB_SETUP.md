# Fixing "app doesn't launch / stuck after build" — AdMob setup

The `google_mobile_ads` plugin **requires** an AdMob App ID declared in the
native project files. Without it, `MobileAds.instance.initialize()` throws,
and since that ran before `runApp()`, nothing ever drew on screen.

Two things fixed this:

1. `lib/main.dart` now wraps the ad-SDK init in try/catch, so a missing/bad
   AdMob config can never block the app from launching (already applied in
   this updated zip).
2. You still need to add the App ID to the native manifests — **do this now**:

## Android

Open `android/app/src/main/AndroidManifest.xml` (this file only exists after
you ran `flutter create .`). Inside `<application>`, add:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>
```

That value above is **Google's official test App ID** — safe to use while
developing. Replace it with your real AdMob App ID (from the AdMob console →
App settings) before release.

## iOS

Open `ios/Runner/Info.plist` and add:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>
```

That's Google's official iOS test App ID.

## After adding these

```bash
flutter clean
flutter pub get
flutter run
```

If it still doesn't launch, run `flutter run -v` and share the last ~30
lines of output before it hangs — that'll show the exact exception.


# AdMob status — intentionally disabled in Module 01

No Mobile Ads package is linked in Module 01, and the eligible layout slots are
safe no-op widgets. This is deliberate: production ads must not be requested
before current UK/EEA consent state and Free/Pro entitlement are known.

The ads module will later add:

1. Google UMP consent information refresh on launch;
2. a permanent Privacy Choices entry when required;
3. debug-only Google test IDs and environment-separated production IDs;
4. one route-aware anchored adaptive top slot on eligible passive screens;
5. a hard deny-list for onboarding, timers, forms, money review, proof,
   backup/restore, permissions, purchases, and help;
6. Pro/Business ad removal, no-fill handling, reserved height, and tests.

Do not add production IDs or initialize an ad SDK before that module.


# AdMob status — intentionally disabled in Module 01

No Mobile Ads package is linked in Module 01, and the eligible layout slots are
safe no-op widgets. This is deliberate: production ads must not be requested
before current UK/EEA consent state and Free/Pro entitlement are known.

The ads module will later add:

1. Google UMP consent information refresh on launch;
2. a permanent Privacy Choices entry when required;
3. debug-only Google test IDs and environment-separated production IDs;
4. one route-aware anchored adaptive top slot on eligible passive screens;
5. a hard deny-list for onboarding, timers, forms, money review, proof,
   backup/restore, permissions, purchases, and help;
6. Pro/Business ad removal, no-fill handling, reserved height, and tests.

Do not add production IDs or initialize an ad SDK before that module.

No Mobile Ads package is linked in Module 01, and the eligible layout slots are
safe no-op widgets. This is deliberate: production ads must not be requested
before current UK/EEA consent state and Free/Pro entitlement are known.

The ads module will later add:

1. Google UMP consent information refresh on launch;
2. a permanent Privacy Choices entry when required;
3. debug-only Google test IDs and environment-separated production IDs;
4. one route-aware anchored adaptive top slot on eligible passive screens;
5. a hard deny-list for onboarding, timers, forms, money review, proof,
   backup/restore, permissions, purchases, and help;
6. Pro/Business ad removal, no-fill handling, reserved height, and tests.

Do not add production IDs or initialize an ad SDK before that module.