# AdMob setup

WorkProof uses the Flutter `google_mobile_ads` plugin and Google UMP consent.
The first eligible banner frame starts the memoized consent/SDK initialization;
no ad request is made until UMP allows requests and Mobile Ads is initialized.
Consent, configuration, network, and no-fill failures never block the local
workspace.

Banner ads are intentionally limited to passive browse/report surfaces:

- Home
- Work
- Money
- Proof
- People (Contacts & Services)
- Work Calendar
- Reports & Statements

More/Settings, About, notifications, onboarding, forms, editors, detail
workspaces, timers, pay review, evidence, backup/restore, security/App Lock,
marketing, code/camera tools, update UI, dialogs, sheets, and guided tutorials
remain ad-free.

## App IDs and banner-unit IDs are different

- An AdMob **App ID** contains `~` and belongs only in the native Android or
  iOS configuration. Android release default:
  `ca-app-pub-2681549212751095~2564398166`.
- A banner **ad-unit ID** contains `/` and is passed to `BannerAd`. Android
  release default: `ca-app-pub-2681549212751095/2645338964`.

The build rejects a `/`-shaped value supplied as Android `ADMOB_APP_ID`, and
the Dart resolver rejects `~`, malformed units, unsupported platforms, and an
Android production unit reused on iOS.

## Build matrix

| Platform/mode | Native App ID | Banner unit |
| --- | --- | --- |
| Android debug/profile | Google sample `ca-app-pub-3940256099942544~3347511713` | Google anchored-adaptive sample `ca-app-pub-3940256099942544/9214589741` |
| Android release | WorkProof default `ca-app-pub-2681549212751095~2564398166` | WorkProof default `ca-app-pub-2681549212751095/2645338964` |
| iOS debug/profile | Google sample `ca-app-pub-3940256099942544~1458002511` | Google sample `ca-app-pub-3940256099942544/2435281174` |
| iOS release | Configure a distinct iOS App ID | Disabled until a distinct `ADMOB_IOS_BANNER_ID` is supplied |

## Development

Debug **and profile** builds always use Google's platform-specific sample App
and banner IDs. Android native debug/profile ignore release overrides. This
prevents a developer or CI profile build from requesting live inventory.

Do not click live ads or use production units while developing. Google's sample
IDs are expected to render a visible **Test Ad** label.

## Android release configuration

The supplied WorkProof App ID and banner unit above are built-in release
defaults, so the normal production command is:

```bash
flutter build appbundle --release
```

To override both values for another AdMob app, use an environment variable for
the native App ID and a Dart compile-time define for the banner unit:

```bash
ADMOB_APP_ID=ca-app-pub-0000000000000000~0000000000 \
flutter build appbundle --release \
  --dart-define=ADMOB_ANDROID_BANNER_ID=ca-app-pub-0000000000000000/0000000000
```

Gradle can also receive the App ID directly when invoked from `android/`:

```bash
./gradlew -PADMOB_APP_ID=ca-app-pub-0000000000000000~0000000000 bundleRelease
```

`String.fromEnvironment` does not read an ordinary shell environment variable;
the banner ID must be passed with `--dart-define` (or an equivalent define
file). AdMob IDs identify inventory but are not secret credentials.

## iOS release configuration

Create the ignored file `ios/Flutter/AdMob.release.xcconfig`:

```text
ADMOB_APP_ID=ca-app-pub-0000000000000000~0000000000
```

Then build with the real banner unit ID:

```bash
flutter build ipa \
  --dart-define=ADMOB_IOS_BANNER_ID=ca-app-pub-0000000000000000/0000000000
```

Keep production identifiers outside source control. Complete the current iOS
Google Mobile Ads release checklist, including any required SKAdNetwork IDs,
before submitting the app. Never place the Android App ID or Android banner
unit in the iOS release configuration. Without a distinct iOS banner unit,
release banners fail closed and occupy no space.

## Runtime behavior

- UMP refreshes consent and shows a form only when required.
- Settings shows **Privacy Choices** only when UMP requires that entry point.
- Home, Work, Money, and Proof share one stable banner owner across eligible
  tab changes; People, Calendar, and Reports own route-local frames.
- At most one banner can be visible. Banners collapse for denied/unready
  consent, unsupported or unconfigured platforms, covered/non-current routes,
  popup routes, background lifecycle, App Lock/privacy shield, tutorials,
  keyboard input, Reports export/share, timeout, or load failure.
- The top anchored-adaptive slot reserves layout space and never overlays
  content, the navigation rail, or the bottom navigation bar.
- A failed ad never leaves controls covered or prevents app use.
- There is no custom retry/refresh timer; AdMob owns normal banner refresh.
- Interstitial, app-open, native, rewarded, and rewarded-interstitial ads are
  not implemented in this release.

## Diagnose a failed request

In debug mode, WorkProof logs the complete banner failure: placement, unit ID,
`LoadAdError.code`, `domain`, `message`, and `responseInfo`. Use that full line
instead of the abbreviated Android message such as `Ad failed to load : 1`.
Release UI remains silent and collapses the optional slot.

## app-ads.txt and AdMob Console readiness

The authorized seller file is published at
<https://workproof-tracker.web.app/app-ads.txt> and must contain exactly:

```text
google.com, pub-2681549212751095, DIRECT, f08c47fec0942fa0
```

Keep `workproof-tracker.web.app` as the developer website/domain in the Google
Play listing so AdMob can associate and crawl the file. Before expecting live
fill, confirm in AdMob that:

1. the account is active (code cannot reactivate an inactive account);
2. the WorkProof app/package `com.workproof.workhelper` is linked and has passed
   app readiness review;
3. app-ads.txt shows as found/authorized; and
4. the published Google Play release contains the production configuration.

Correct integration cannot guarantee ad fill. A new or reactivated account,
app review, inventory availability, and AdMob policy checks remain controlled
by Google.

See Google's [Flutter quick start](https://developers.google.com/admob/flutter/quick-start),
[UMP privacy guide](https://developers.google.com/admob/flutter/privacy), and
[banner guide](https://developers.google.com/admob/flutter/banner).
