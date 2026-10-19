# Store Update and Review Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Check for Android/iOS store updates at launch and resume with a non-dismissible update prompt, and add policy-compliant native review prompting plus a permanent store-rating action.

**Architecture:** A root `ForcedUpgradeAlert` wraps the routed app and owns one injected `Upgrader`, while the existing custom update coordinator remains in the repository but is removed from runtime composition. A review service reads authoritative completed-clock-out statistics, persists only a one-shot attempt flag, and calls an injected `InAppReview` gateway; the About screen opens the store listing directly.

**Tech Stack:** Flutter, Riverpod, GoRouter, `upgrader: ^13.7.0`, `in_app_review: ^2.0.12`, sqflite, SharedPreferences, flutter_test.

**Spec:** `APP_UPDATE_SETUP.md` plus the update/review behavior approved in the current user session.

## Global Constraints

- Support Android and iOS; unsupported platforms fail open and hide the rating action.
- Check updates at startup and resume; network/store failures must never block startup.
- Show no Later or Ignore action, block back/barrier dismissal, and keep the dialog mounted after Update opens the store.
- Disable, but do not delete, the existing custom `AppUpdateCoordinator` runtime path.
- Request a native review only after at least three successful, nondeleted completed clock-outs whose first/latest clock-out span at least seven days, and attempt it once.
- The permanent About action uses `openStoreListing`, never `requestReview`; iOS requires a numeric `APP_STORE_ID`.
- Preserve unrelated dirty-worktree changes and do not create a commit from this shared worktree.

## Review Focus

- Upgrader's ordinary Update button normally pops the dialog: test that the forced state ignores the pop request.
- Store lookup may fail or return no listing: the routed app must remain usable.
- A review must not fire at two entries or a span shorter than exactly seven days: unit-test both boundaries.
- Concurrent successful callbacks must still produce one review attempt: unit-test the in-flight guard and persisted flag ordering.
- The About CTA must open the listing and remain hidden on unsupported/misconfigured iOS: widget-test both paths.

---

### Task 1: Forced store-update gate

**Files:**
- Create: `lib/features/app_update/presentation/store_update_gate.dart`
- Create: `test/features/app_update/store_update_gate_test.dart`
- Modify: `lib/main.dart`
- Modify: `lib/core/router/app_shell.dart`

**Interfaces:**
- Produces: `appStoreUpgraderProvider: Provider<Upgrader>` and `ForcedUpgradeAlert extends UpgradeAlert`.
- Consumes: `GoRouter.routerDelegate.navigatorKey` and `AppLockGate`.

- [ ] **Step 1: Write the failing tests** for forced widget configuration and an Update action that calls the store without popping its route.
- [ ] **Step 2: Run** `flutter test test/features/app_update/store_update_gate_test.dart` and confirm failure because the gate is absent.
- [ ] **Step 3: Implement** `ForcedUpgradeAlert` with `showIgnore: false`, `showLater: false`, `barrierDismissible: false`, `shouldPopScope: () => false`; override `UpgradeAlertState.onUserUpdated` to call `super.onUserUpdated(context, false)`.
- [ ] **Step 4: Provide** one `Upgrader(checkOnResume: true, durationUntilAlertAgain: Duration.zero)` instance, dispose it with its provider, wrap it inside `AppLockGate` in `MaterialApp.router.builder`, and remove the old coordinator wrapper/import from `AppShell`.
- [ ] **Step 5: Run** the focused update tests and confirm PASS.

### Task 2: Review eligibility and native gateway

**Files:**
- Create: `lib/features/app_review/application/app_review_service.dart`
- Create: `lib/features/app_review/infrastructure/in_app_review_gateway.dart`
- Create: `test/features/app_review/app_review_service_test.dart`
- Modify: `lib/features/time_tracking/time_entry_model.dart`
- Modify: `lib/features/time_tracking/time_tracking_provider.dart`

**Interfaces:**
- Produces: `CompletedClockOutStats`, `AppReviewGateway`, `ReviewAttemptStore`, `AppReviewService.maybeRequestReview({required bool Function() canPresent})`, and Riverpod providers.
- Consumes: `TimeTrackingRepository.completedClockOutStats()`, `AppClock`, SharedPreferences, and `InAppReview.instance`.

- [ ] **Step 1: Write failing policy tests** for counts below three, spans below/exactly seven days, already-attempted state, unavailable plugin, exception fail-open behavior, and concurrent calls.
- [ ] **Step 2: Run** `flutter test test/features/app_review/app_review_service_test.dart` and confirm the missing behavior fails.
- [ ] **Step 3: Add** `TimeTrackingRepository.completedClockOutStats()` using one aggregate query over `workspace_id = 'local-workspace'`, `deleted_at IS NULL`, `status = 'completed'`, and non-null `clock_out`.
- [ ] **Step 4: Implement** the injected review service and SharedPreferences-backed one-shot flag; mark attempted immediately before `requestReview()` and swallow plugin/storage/query failures.
- [ ] **Step 5: Implement** the plugin gateway; allow listing on Android and on iOS only when `APP_STORE_ID` is numeric.
- [ ] **Step 6: Run** the focused service tests and confirm PASS.

### Task 3: Successful clock-out hook and About rating action

**Files:**
- Modify: `lib/features/time_tracking/clock_screen.dart`
- Modify: `lib/features/about/presentation/about_app_screen.dart`
- Modify: `test/features/about/about_app_screen_test.dart`
- Modify: `lib/l10n/app_*.arb`
- Regenerate: `lib/l10n/generated/app_localizations*.dart`

**Interfaces:**
- Consumes: `appReviewServiceProvider`, `appReviewGatewayProvider`, `storeListingSupportedProvider`.
- Produces: a successful-clock-out-only review hook and localized `rateWorkProof` / `storeListingFailed` UI.

- [ ] **Step 1: Write failing About widget tests** proving the CTA calls `openStoreListing` (not `requestReview`), is hidden when unsupported, and reports listing failures.
- [ ] **Step 2: Run** the focused About test and confirm the new expectations fail.
- [ ] **Step 3: Add** localized strings to all ten ARBs and run `flutter gen-l10n`.
- [ ] **Step 4: Render** a star rating button in the About information card only when listing is supported; catch failures with existing `AppFeedback.error`.
- [ ] **Step 5: Make** `_run` return success and call `maybeRequestReview` only after a confirmed successful clock-out, while keeping review failure outside the timer error path.
- [ ] **Step 6: Run** the About and review focused tests and confirm PASS.

### Task 4: Documentation and full verification

**Files:**
- Modify: `APP_UPDATE_SETUP.md`

**Interfaces:**
- Documents: public-store lookup limits, `APP_STORE_ID`, version bumping, Play/App Store device testing, and review quota behavior.

- [ ] **Step 1: Rewrite** setup instructions for Upgrader store redirects and in-app review testing without claiming emulator validation.
- [ ] **Step 2: Run** `dart format` on changed Dart/test files.
- [ ] **Step 3: Run** `flutter test` and require all tests PASS.
- [ ] **Step 4: Run** `flutter analyze`; report any unrelated pre-existing diagnostics separately.
- [ ] **Step 5: Review** the final diff for unrelated changes and request an independent code review before completion.
