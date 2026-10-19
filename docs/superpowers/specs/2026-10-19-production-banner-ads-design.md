# Production Banner Ads Design

**Date:** 2026-10-19
**Status:** Approved for implementation
**Scope:** Production-ready AdMob banners only. Interstitial, native, rewarded,
rewarded-interstitial, and app-open ads are explicitly out of scope.

## Intent

WorkProof should monetize substantial content surfaces with banner ads without
interrupting work, obscuring controls, encouraging accidental clicks, or
exposing production ads during development. A successful implementation:

- uses the supplied Android AdMob app and banner IDs in release builds;
- uses Google's platform-specific test IDs in debug and profile builds;
- never treats an app ID (`~`) as an ad-unit ID (`/`);
- shows at most one banner on the currently visible eligible surface;
- reserves real layout space instead of floating over app content;
- suppresses ads during consent, lock, keyboard, modal, tutorial, background,
  and critical-operation states;
- fails closed: unavailable, rejected, or unconfigured ads collapse without
  blocking any WorkProof feature.

## Product and Policy Boundaries

"Full app" means the app's eligible, substantial content areas. It does not
mean every route. Google discourages banners next to navigation or frequently
tapped controls, prohibits banners that overlap content, and restricts ads on
low-value or primarily navigational/behavioral screens.

Eligible production surfaces:

- Home dashboard (`/home`)
- Work overview (`/work`)
- Money overview (`/money`)
- Proof/audit overview (`/proof`)
- People directory (`/people`)
- Work calendar (`/work-calendar`)
- Reports (`/reports`)

Always ad-free surfaces:

- startup and onboarding;
- the More/settings root, About, notification settings, preferences, security,
  and backup/restore;
- all create/edit forms and detail workspaces;
- job/shift clocks and correction dialogs;
- pay-period details, payslip and evidence editors;
- marketing and code/camera tools;
- app-lock/privacy shield and mandatory-update UI;
- dialogs, sheets, guided showcases, error-only and confirmation-only states.

The final policy audit intentionally excludes More, About, and Notifications
even though they appeared in an early conversational list: those screens are
primarily navigation, configuration, or low-value informational UI, so keeping
them ad-free is the production-safe interpretation of the user's requirement.

## Ad Placement Architecture

### Shared host

Create one reusable authenticated `AppBannerFrame` component that owns a top,
anchored-adaptive `BannerAdWidget` and a child surface. It accepts an explicit
`enabled` input, and router/screen builders apply it only to the eligible
surfaces above. Each mounted route can own a frame instance, but route
visibility and `TickerMode` guarantee that at most one instance can request or
display an ad at a time.

- The indexed tab shell receives one persistent frame, shared by Home, Work,
  Money, and Proof. More remains in the shell, but the frame receives
  `enabled: false` when the current branch is More and immediately disposes and
  collapses its banner.
- People and Calendar receive the same reusable frame at their root route.
  Reports owns the frame at screen level so its controller state can pass
  `enabled: false` while a report is being generated or exported.
- Descendant editors remain unwrapped. Root-navigator detail routes continue to
  cover the shell and suppress the underlying banner.
- Existing screen-local banners are removed so a route can never render two ad
  slots. Legacy redirect-only screens are not given new placements.

The frame places the banner above the routed `Scaffold`, inside the top safe
area. On wide layouts it occupies only the content pane, not the navigation
rail. It never sits between interactive content and the bottom navigation bar,
never overlaps content, and never uses a collapsible/overlay banner.

The slot reserves the SDK-reported anchored-adaptive height while loading so
successful loads do not shift controls. A failure, timeout, no-fill, denied
consent, or unsupported platform collapses the slot completely.

### Visibility policy

Banner eligibility is the conjunction of:

1. the frame's explicit `enabled` input and an eligible surface/branch;
2. UMP `canRequestAds` and successful Mobile Ads initialization;
3. app lifecycle is `resumed`;
4. the enclosing route is current and has no popup route above it;
5. `TickerMode` is enabled;
6. the app is not locked or privacy-shielded;
7. no showcase/tutorial is active;
8. the keyboard is closed;
9. a platform-valid banner ad-unit ID is configured.

`AppLockGate` adds a disabled `TickerMode` around its retained child while
blocked. `BannerAdWidget` observes app lifecycle and current `ModalRoute` in
addition to its existing consent, ticker, keyboard, width, and ID checks.
`AppShowcaseCoordinator` exposes a reactive active-state listenable so the
banner can disappear before a tutorial overlay starts and reload only after it
finishes.

Reports additionally disables the slot while generating/exporting. The native
share sheet backgrounds or covers the app, so lifecycle/route suppression
keeps the banner inactive during sharing.

## Identifier and Build Configuration

### Android release

- Native app ID: `ca-app-pub-2681549212751095~2564398166`
- Banner ad-unit ID: `ca-app-pub-2681549212751095/2645338964`

`android/app/build.gradle.kts` keeps Gradle-property and environment overrides
for release `ADMOB_APP_ID`, with the supplied real app ID as the release
fallback. Debug and profile resolve the manifest placeholder to Google's sample
Android app ID regardless of release overrides.

`AdUnitConfig` reads `ADMOB_ANDROID_BANNER_ID` with the supplied real banner ID
as its release default. It selects Google's Android anchored-adaptive test unit
outside release mode. A pure resolver validates platform, build mode, and ID
shape; an app ID containing `~` is never returned as a banner unit.

### iOS

Debug and profile use Google's iOS test IDs. Production iOS banners remain
disabled until distinct iOS app and banner IDs are supplied through the
existing iOS configuration and `ADMOB_IOS_BANNER_ID`. Android production IDs
must never be reused on iOS.

### SDK ownership

The Flutter `google_mobile_ads` plugin remains the sole dependency owner. Do
not add a second raw `play-services-ads` dependency from the native Android
quick-start guide. UMP continues to complete before `MobileAds.initialize()`,
and the SDK initializes once only when consent permits requests.

## Loading, Refresh, and Failure Behavior

- Keep a loaded banner alive while its shared eligible frame remains current.
- Do not issue a new request merely because the user changes eligible tabs.
- Let AdMob manage banner refresh; do not add app timers or manual refresh.
- Cancel/dispose an in-flight or loaded banner when the host becomes
  ineligible, changes width/orientation, or is disposed.
- Preserve the existing bounded load timeout and stale-callback generation
  guard.
- Log `LoadAdError.code`, `domain`, `message`, and `responseInfo` in debug mode;
  production UI remains silent and collapses the failed slot.
- Do not add automatic retry loops. A later legitimate lifecycle or layout
  transition may create a fresh request, subject to the single-host rules.

## Consent and Privacy

The existing UMP flow remains authoritative. No ad request occurs until
`ConsentInformation.canRequestAds()` is true and Mobile Ads initialization has
completed. Privacy Choices remains available when UMP reports it is required.
Ads are optional: any consent or SDK error leaves the local-first workspace
fully usable.

No interstitial, app-open, native, rewarded, or rewarded-interstitial manager
is introduced in this release. Each would require its own AdMob ad unit and a
separate UX/policy design.

## Test Strategy

Tests are written before production changes where executable behavior is
involved.

1. **ID resolver tests**
   - Android debug/profile resolve the official Android test app/banner pair.
   - Android release resolves the supplied production pair and honors explicit
     overrides.
   - App IDs containing `~` are rejected as banner units.
   - iOS debug/profile use iOS test values; iOS release without configuration
     returns no banner.
   - web and unsupported platforms return no banner.

2. **Visibility-policy tests**
   - eligible content routes/branches allow a slot;
   - More and all excluded routes do not;
   - keyboard, inactive lifecycle, popup route, lock, showcase, and denied
     consent each suppress the slot;
   - only one banner host is visible after tab and route transitions.

3. **Widget/lifecycle tests**
   - unavailable ads occupy zero height;
   - lock and tutorial activation remove the slot without exposing controls;
   - failed loads dispose the ad and expose no error UI;
   - a tab change does not create a second request.

4. **Native build verification**
   - debug and profile merged manifests contain Google's sample Android app ID;
   - release merged manifest contains the supplied production app ID;
   - INTERNET, ACCESS_NETWORK_STATE, and AD_ID declarations remain present via
     manifest merging;
   - the release bundle builds with the existing signing configuration.

5. **Repository verification**
   - format touched Dart files;
   - run focused ads/router/widget tests;
   - run the full Flutter test suite;
   - run static analysis and a release build/manifest inspection.

## Documentation and Operational Readiness

Update `ADMOB_SETUP.md` and the README to document:

- the distinction between app IDs (`~`) and ad-unit IDs (`/`);
- release defaults and supported build-time overrides;
- test-only debug/profile behavior;
- eligible and excluded surfaces;
- how to read complete load errors;
- that app-ads.txt is live at
  `https://workproof-tracker.web.app/app-ads.txt` and the same developer domain
  appears in the Google Play listing.

Code readiness cannot activate an AdMob account or guarantee fill. Before
production serving, the operator must confirm the AdMob account is active, the
WorkProof app has passed readiness review, app-ads.txt is verified, and the
release in Google Play uses package `com.workproof.workhelper`.

## Non-Goals

- no full-screen or rewarded ad formats;
- no mediation adapters;
- no paid ad-removal entitlement;
- no ad display on every route;
- no manual banner-refresh scheduler;
- no changes to core WorkProof functionality, records, exports, or security.

## Primary References

- [Google Mobile Ads Flutter quick start](https://developers.google.com/admob/flutter/quick-start)
- [Flutter banner implementation guide](https://developers.google.com/admob/flutter/banner)
- [Flutter test ads guide](https://developers.google.com/admob/flutter/test-ads)
- [Discouraged banner implementations](https://support.google.com/admob/answer/6275345?hl=en)
- [Recommended banner implementations](https://support.google.com/admob/answer/6275335?hl=en-GB)
- [Ads interfering with content policy](https://support.google.com/publisherpolicies/answer/11035030)
- [Google Play ads policy](https://support.google.com/googleplay/android-developer/answer/9857753?hl=en)
