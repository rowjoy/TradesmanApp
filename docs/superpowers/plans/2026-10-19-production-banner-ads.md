# Production Banner Ads Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship production-ready, consent-aware AdMob anchored-adaptive banners on WorkProof's approved content surfaces without invalid requests, duplicate ads, or interference with user work.

**Architecture:** A pure platform/build resolver supplies Google test banner units outside release and the WorkProof Android banner unit in release, while Gradle independently selects the matching native App ID. One reusable `AppBannerFrame` owns context visibility and SDK initialization; the indexed shell keeps one stable instance across Home, Work, Money, and Proof, while People, Calendar, and Reports own route-local instances.

**Tech Stack:** Flutter, Dart, Riverpod, GoRouter, `google_mobile_ads: 6.0.0`, Google UMP, Android Gradle Kotlin DSL, flutter_test.

**Spec:** `docs/superpowers/specs/2026-10-19-production-banner-ads-design.md`

## Global Constraints

- Android release App ID is `ca-app-pub-2681549212751095~2564398166`; Android release banner unit is `ca-app-pub-2681549212751095/2645338964`.
- Android/iOS debug and profile use Google's current platform-specific anchored-adaptive test IDs; live units are never requested during development.
- iOS release ads remain disabled until a distinct iOS production App ID and banner unit are configured; Android IDs are never reused on iOS.
- UMP `canRequestAds` remains authoritative and `MobileAds.initialize()` remains single-shot and post-consent.
- Show at most one banner on Home, Work, Money, Proof, People, Calendar, or Reports; every other route/state listed in the spec remains ad-free.
- Never overlay content or navigation. Reserve layout space, fail closed, and suppress for lifecycle, popup, covered route, app lock, showcase, keyboard, and export/share states.
- Keep `google_mobile_ads` as the sole SDK dependency owner; do not add raw `play-services-ads`.
- Preserve all unrelated dirty-worktree changes. Do not commit application changes from this shared worktree.

## Review Focus

- A `~` App ID, malformed unit, unsupported platform, web build, or Android unit reused on iOS must resolve to no banner; Task 1 tests every case.
- Debug/profile/release native App IDs can silently diverge from Dart banner IDs; Task 2 inspects all three freshly merged manifests and APKs.
- Retained tabs and covered routes can keep native ads alive; Tasks 3 and 4 test disposal, one-instance tab reuse, PageRoute coverage, and PopupRoute suppression.
- Keyboard, backgrounding, app lock, and tutorial overlays can expose or refresh ads at unsafe moments; Task 3 exercises the resulting TickerMode/lifecycle transitions and their conjunction.
- Reports can clear `exporting` before the native share flow finishes; Task 5 holds suppression until sharing completes and tests success and both failure paths.

---

### Task 1: Correct banner-unit resolution and preserve full load diagnostics

**Files:**
- Modify: `lib/features/ads/infrastructure/ad_unit_config.dart`
- Create: `lib/features/ads/infrastructure/ad_diagnostics.dart`
- Modify: `lib/core/widgets/banner_ad_widget.dart`
- Create: `test/features/ads/ad_unit_config_test.dart`
- Create: `test/features/ads/ad_diagnostics_test.dart`
- Test: `test/features/ads/ads_consent_controller_test.dart`

**Interfaces:**
- Produces: `AdBuildMode`, `AdUnitConfig.resolveBannerId(...)`, `AdUnitConfig.isValidBannerId(String)`, and `AdDiagnostics.logBannerLoadFailure(...)`.
- Preserves: `AdUnitConfig.bannerId(AdPlacement)` and the existing banner timeout, generation guard, disposal, collapse, and no-retry behavior.

- [ ] **Step 1: Write the failing resolver tests** using `resolveBannerId({required AdPlacement placement, required TargetPlatform platform, required AdBuildMode buildMode, required bool isWeb, required String androidReleaseBannerId, required String iosReleaseBannerId})`. Assert Android and iOS debug/profile test IDs, Android release default/override, unconfigured iOS release, web/unsupported platforms, surrounding whitespace, malformed values, `~` App IDs, and Android-ID reuse on iOS.
- [ ] **Step 2: Write the failing diagnostics tests** with test subclasses of `LoadAdError` and `ResponseInfo`. Assert one debug message contains placement, unit, code, domain, message, and response information, while `enabled: false` emits nothing.
- [ ] **Step 3: Run** `flutter test test/features/ads/ad_unit_config_test.dart test/features/ads/ad_diagnostics_test.dart` and confirm failure because the pure resolver and formatter do not exist.
- [ ] **Step 4: Implement the resolver.** Map `kReleaseMode`, `kProfileMode`, and debug to `AdBuildMode`; use `defaultTargetPlatform` rather than `dart:io`; accept only trimmed `ca-app-pub-<digits>/<digits>` banner units. Use Android test `ca-app-pub-3940256099942544/9214589741`, iOS test `ca-app-pub-3940256099942544/2435281174`, `String.fromEnvironment('ADMOB_ANDROID_BANNER_ID', defaultValue: 'ca-app-pub-2681549212751095/2645338964')`, and an empty-by-default `ADMOB_IOS_BANNER_ID`.
- [ ] **Step 5: Implement diagnostics.** `formatBannerLoadFailure(...)` returns all SDK fields; `logBannerLoadFailure(...)` sends it to an injected `AdDiagnosticSink` or `debugPrint` only when enabled. Retain the `LoadAdError` parameter in `BannerAdListener.onAdFailedToLoad`, log first, then execute the existing failure/disposal path.
- [ ] **Step 6: Run** `flutter test test/features/ads/ad_unit_config_test.dart test/features/ads/ad_diagnostics_test.dart test/features/ads/ads_consent_controller_test.dart` and require PASS.
- [ ] **Step 7: Format** the Task 1 Dart files with `dart format`, then run `dart format --output=none --set-exit-if-changed` on the same paths.

### Task 2: Make Android native App IDs deterministic by build type

**Files:**
- Modify: `android/app/build.gradle.kts`
- Modify: `android/app/src/main/AndroidManifest.xml`

**Interfaces:**
- Produces: `${ADMOB_APP_ID}` = Google sample App ID for debug/profile and WorkProof's real App ID for release.
- Preserves: release signing, package `com.workproof.workhelper`, the single Mobile Ads metadata node, and optional release override through Gradle property/environment `ADMOB_APP_ID`.

- [ ] **Step 1: Prove the current mismatch** by running `./gradlew :app:processDebugMainManifest :app:processProfileMainManifest :app:processReleaseMainManifest --rerun-tasks --console=plain` from `android/`; inspect the three merged manifests and record that release incorrectly contains Google's sample App ID.
- [ ] **Step 2: Implement build-type selection.** Set `defaultConfig.manifestPlaceholders["ADMOB_APP_ID"]` to sample `ca-app-pub-3940256099942544~3347511713`. In `release`, preserve signing and override it with Gradle property `ADMOB_APP_ID`, then environment `ADMOB_APP_ID`, then fallback `ca-app-pub-2681549212751095~2564398166`. Validate the resolved release value as `ca-app-pub-<digits>~<digits>` and fail configuration for `/` or malformed values. Update the manifest comment without duplicating metadata.
- [ ] **Step 3: Re-run the three manifest tasks** and use `xmllint --xpath` to assert exactly one `com.google.android.gms.ads.APPLICATION_ID`: sample for debug/profile, real for release; also assert package `com.workproof.workhelper`. Run the release manifest task once with a `/`-shaped `-PADMOB_APP_ID` and require the explicit validation failure.
- [ ] **Step 4: Run** `git diff --check -- android/app/build.gradle.kts android/app/src/main/AndroidManifest.xml` and require no whitespace errors.

### Task 3: Centralize safe banner visibility and optional-service ownership

**Files:**
- Create: `lib/features/ads/application/banner_overlay_controller.dart`
- Create: `lib/core/widgets/app_banner_frame.dart`
- Modify: `lib/core/router/app_router.dart`
- Modify: `lib/features/showcase/presentation/app_showcase.dart`
- Modify: `lib/features/security/presentation/app_lock_gate.dart`
- Create: `test/features/ads/app_banner_frame_test.dart`

**Interfaces:**
- Produces: `BannerOverlayController.hasBlockingOverlay`, `BannerOverlayController.createObserver()`, `bannerOverlayControllerProvider`, `AppBannerBuilder`, `appBannerBuilderProvider`, and `AppBannerFrame({required Widget child, required AdPlacement placement, bool enabled = true, ValueListenable<bool>? showcaseActivity})`.
- Consumes: `adsConsentControllerProvider`, `AppShowcaseCoordinator.activity`, root/branch navigation events, `ModalRoute.isCurrentOf`, `TickerMode`, `MediaQuery.viewInsets`, and `WidgetsBindingObserver` lifecycle callbacks.

- [ ] **Step 1: Write failing controller/frame tests.** Use an injected fake banner builder with create/dispose counters and a `ValueNotifier<bool>` showcase source. Assert one banner when eligible; zero for disabled, non-current route, PopupRoute, paused/inactive/hidden/detached lifecycle, disabled TickerMode, active showcase, or visible keyboard; restoration creates exactly one; child text/focus/scroll state survives. Exercise popup push/pop/remove/replace so the controller cannot remain stuck suppressed.
- [ ] **Step 2: Add a safe-area layout test** at phone and rail widths. Assert no overflow, the child stays mounted, top system padding is applied exactly once, and removing the banner does not move content behind system UI.
- [ ] **Step 3: Run** `flutter test test/features/ads/app_banner_frame_test.dart` and confirm failure because the controller/frame do not exist.
- [ ] **Step 4: Implement `BannerOverlayController`.** Its distinct observer instances share a set/refcount of active `PopupRoute`s and notify only when `hasBlockingOverlay` changes. Attach one observer to `GoRouter`; rely on GoRouter's root-observer propagation to stateful branch navigators and cover dialogs/bottom sheets without reparenting routes.
- [ ] **Step 5: Make showcase activity reactive.** Expose `ValueListenable<bool> get activity`, retain `isActive`, and funnel start, finish/dismiss, and no-ready-target cancellation through one setter so every state transition notifies.
- [ ] **Step 6: Implement `AppBannerFrame`.** Initialize the consent controller once through its memoized API; keep `child` mounted; mount the injected banner builder only when every context gate passes. Use one outer top `SafeArea` plus `MediaQuery.removePadding(removeTop: true)` so the banner and the child `Scaffold` do not double-apply the status-bar inset.
- [ ] **Step 7: Disable retained work while locked.** Wrap `AppLockGate`'s retained child in `TickerMode(enabled: !blocked)` inside its existing `IgnorePointer`/`ExcludeSemantics` gates.
- [ ] **Step 8: Run** the focused frame tests and `test/features/ads/ads_consent_controller_test.dart`; require PASS, then format all Task 3 Dart files.

### Task 4: Install one banner owner on every approved content surface

**Files:**
- Modify: `lib/core/router/app_shell.dart`
- Modify: `lib/features/dashboard/dashboard_screen.dart`
- Modify: `lib/features/work/presentation/screens/work_hub_screen.dart`
- Modify: `lib/features/work/presentation/screens/people_directory_screen.dart`
- Modify: `lib/features/work/presentation/screens/work_calendar_screen.dart`
- Modify: `lib/features/jobs/jobs_screen.dart`
- Modify: `lib/features/customers/customers_screen.dart`
- Create: `test/features/ads/app_banner_placement_test.dart`

**Interfaces:**
- Produces: stable `AdPlacement.appShell`, `MainShellBannerRegion({required int currentIndex, required bool proofHasContent, required Widget child})`, and route-owned `people`/`calendar` frames.
- Consumes: `AppBannerFrame` and `auditEventsProvider`; More passes `enabled: false`. Navigation rail and bottom navigation remain outside the ad content pane.

- [ ] **Step 1: Write the failing placement test.** Pump `MainShellBannerRegion` in a small five-branch harness with the fake banner builder. Assert Home → Work → Money → a content-ready Proof retains one banner instance/request; loading/error-only Proof and More dispose it; returning creates one; a covering detail route removes it; both mobile and rail layouts remain usable.
- [ ] **Step 2: Run** `flutter test test/features/ads/app_banner_placement_test.dart` and confirm the shared placement behavior is absent.
- [ ] **Step 3: Integrate the main shell.** Remove ads initialization from `AppShell`; wrap only its content pane with `MainShellBannerRegion`, backed by one `AppBannerFrame(placement: AdPlacement.appShell)`. Enable Home/Work/Money and enable Proof only after `auditEventsProvider` has publisher content; disable loading/error-only Proof and More. Do not wrap the NavigationRail or NavigationBar.
- [ ] **Step 4: Integrate standalone roots.** Return `AppBannerFrame` around the complete People and Calendar `Scaffold`s. Leave their descendant editors unchanged so covered/non-current frames dispose their banners.
- [ ] **Step 5: Remove duplicate slots.** Delete raw banner widgets/imports from Dashboard, Work, People, Calendar, and legacy redirect-only Jobs/Customers. Preserve intentional content spacing and verify `rg -n "BannerAdWidget" lib` finds production construction only in `app_banner_frame.dart`.
- [ ] **Step 6: Run** the placement/frame tests, format all Task 4 Dart files, and require `git diff --check` on those files.

### Task 5: Keep Reports ad-free through generation and native sharing

**Files:**
- Modify: `lib/features/reports/application/report_controller.dart`
- Modify: `lib/features/reports/presentation/reports_screen.dart`
- Create: `test/features/reports/report_controller_export_test.dart`

**Interfaces:**
- Produces: `ReportShareCallback = Future<void> Function(PreparedReportExport export, {Rect? origin})` injected into `ReportController` and supplied by its Riverpod provider through `SharePlus.instance.share`.
- Consumes: `AppBannerFrame(placement: AdPlacement.reports, enabled: state.report.hasValue && !state.exporting)`.

- [ ] **Step 1: Write failing controller tests** with completers for export generation and sharing. Assert `exporting` becomes true immediately, remains true after generation and until share completion, rejects a concurrent call, clears on success, and clears with `report_export_failed` on either generation or sharing failure.
- [ ] **Step 2: Run** `flutter test test/features/reports/report_controller_export_test.dart` and confirm the existing early `exporting: false` transition fails the pending-share assertion.
- [ ] **Step 3: Inject sharing and fix state lifetime.** Keep `exporting` true across both awaited operations, retain `lastExport` after generation, set the error in `catch`, and clear `exporting` in `finally` without clearing the error.
- [ ] **Step 4: Replace Reports' raw banner** with an outer `AppBannerFrame` around its complete `Scaffold`, passing `enabled: state.report.hasValue && !state.exporting` so loading/error-only and export/share states remain ad-free; preserve refresh/error/content behavior.
- [ ] **Step 5: Run** the report export, report model, frame, and placement tests; require PASS and format the three Task 5 files.

### Task 6: Document operations and verify release artifacts

**Files:**
- Modify: `ADMOB_SETUP.md`
- Modify: `README.md`

**Interfaces:**
- Documents: ID separator rules, exact build matrix, eligible/excluded surfaces, complete debug failure logs, verified app-ads.txt URL, and external AdMob account/readiness actions.

- [ ] **Step 1: Update documentation.** Explain App ID `~` versus ad-unit `/`, built-in Android release defaults plus overrides, test-only debug/profile behavior, iOS release disablement, the seven eligible surfaces, suppression rules, and `https://workproof-tracker.web.app/app-ads.txt`. State that code cannot reactivate an account or guarantee fill.
- [ ] **Step 2: Format and lint.** Run `dart format` on every touched Dart/test file, `dart format --output=none --set-exit-if-changed` on the same list, and `git diff --check` for every touched file.
- [ ] **Step 3: Run focused tests:** `flutter test test/features/ads test/features/reports/report_controller_export_test.dart test/features/reports/report_models_test.dart` and require PASS.
- [ ] **Step 4: Run repository checks:** `flutter analyze` and `flutter test`. Report unrelated pre-existing diagnostics separately; do not hide failures.
- [ ] **Step 5: Build all Android modes:** `flutter build apk --debug`, `flutter build apk --profile`, `flutter build apk --release`, and `flutter build appbundle --release`. Inspect each APK/AAB manifest: debug/profile must contain the sample App ID exactly once; release artifacts must contain the WorkProof App ID exactly once. Assert merged release permissions include `INTERNET`, `ACCESS_NETWORK_STATE`, and `com.google.android.gms.permission.AD_ID`.
- [ ] **Step 6: Perform final static/runtime checks.** Confirm no `~` value can reach `BannerAd.adUnitId`, no eligible screen contains duplicate raw banners, More and every excluded route remain unwrapped, debug logs full `LoadAdError`, and a debug emulator reaches `onAdLoaded` with a visible “Test Ad” banner. Fetch `https://workproof-tracker.web.app/app-ads.txt` and require HTTP 200, `text/plain`, and the exact authorized seller line.
- [ ] **Step 7: Request an independent whole-change code review**, address only verified findings, rerun affected checks, and summarize the remaining external AdMob Console/reactivation steps without claiming live production fill.
