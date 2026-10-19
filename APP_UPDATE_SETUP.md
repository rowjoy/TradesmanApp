# App update and review setup

WorkProof uses `upgrader` on Android and iOS. It checks the public store when
the app opens and whenever it resumes. If the public store has a newer version,
the app shows a non-dismissible update dialog with only **Update Now**. The
button opens the Play Store or App Store; the app does not download or install
the update itself.

If the device is offline, the listing is unavailable, or the store request
fails, startup continues normally.

The older custom `AppUpdateCoordinator` implementation remains in the source
tree for compatibility, but it is not mounted at runtime, so users do not see
two update prompts.

## Android

`upgrader` compares the installed version with the app's public Google Play
listing. A locally installed APK, unpublished application, or release that is
only in an internal/closed track may not be discoverable through that public
listing.

For a real end-to-end check, install the production-signed app through Google
Play and make a higher version code/version available from a store listing that
the test account and country can access. Widget tests use an injected Upgrader
instead of making a live Play request.

## iOS

`upgrader` looks up the public App Store listing. The bundle identifier in the
build must match the App Store Connect application.

The permanent **Rate WorkProof** action also needs the numeric App Store ID on
iOS. Supply it at build time:

```bash
flutter build ipa --dart-define=APP_STORE_ID=1234567890
```

Without a numeric `APP_STORE_ID`, the iOS rating action is hidden. Android does
not need this value.

## In-app review policy

After a successful clock-out, WorkProof may ask the operating system for its
native review dialog only when all of these conditions are true:

- at least three nondeleted work sessions are completed;
- the first and latest completed clock-outs span at least seven days;
- WorkProof has not already attempted the native review prompt on this install;
- the app is active, unlocked, on the current route, and no showcase is open;
- the platform reports that native review is available.

The attempt is saved before requesting the native prompt. Google Play and Apple
apply their own quotas, so the request can complete without a dialog appearing.
The About screen's permanent rating button uses the store listing instead; it
does not consume the native review prompt.

Real review behavior cannot be validated on a normal emulator-only install.
Use a store-distributed test build and a physical Android/iOS device. See the
[`in_app_review` testing notes](https://pub.dev/packages/in_app_review#testing).

## Versioning

The installed version comes from `pubspec.yaml`:

```yaml
version: 0.0.1+1
```

Before each store release, increase the marketing version and build number
(Android version code). The public store version must be higher than the
installed version for `upgrader` to offer an update.
