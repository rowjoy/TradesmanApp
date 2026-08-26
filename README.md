# WorkProof Flutter

> Track your work. Protect your pay. Keep your proof.

Offline-first Flutter app covering work planning, time tracking, notifications,
pay protection, evidence, audit history, and WorkProof PDF/ZIP exports.

## Current checkpoint

Version `0.16.1+19` includes Module 10 offline reports, Module 11 ads/consent,
three animated localized onboarding pages, first-visit screen guides, an
offline Marketing Studio for promotion PNG/PDF sharing, an on-device QR and
barcode studio, and the runtime, device-time-zone, alert, showcase, work-PDF,
notification icon, and text-controller lifecycle fixes.

- Settings includes QR and common-barcode scanning plus offline QR/Code 128
  generation, type switching, clipboard copy, and PNG sharing;
- Marketing Studio now exports the complete promotion design as an A4 portrait
  2480×3508 PNG with 300 DPI metadata and as a full-page, margin-free A4 PDF
  without square cropping;
- camera frames and scanned values stay on device unless the user explicitly
  copies or shares a generated result;

- weekly, monthly and custom Worker/Tradesman reports use SQLite as the only
  calculation source and never require an account or connection;
- Worker reports show recorded/billable hours, expected/received gross,
  deductions, net pay and possible difference without mixing customer invoices;
- Tradesman reports show time, billable work, invoiced, paid, outstanding,
  expenses and net cash without mixing employer payroll;
- employer and customer filters create focused statements; CSV and PDF exports
  are generated in a background isolate, shared explicitly by the user, hashed
  with SHA-256 and recorded in a local export audit table;
- Google UMP runs before Mobile Ads initialization or any request, Privacy
  Choices remains available in Settings, and denied consent/no-fill/missing
  release IDs collapse the banner slot;
- only anchored adaptive top banners are enabled on eligible Dashboard, Work
  browse and Reports surfaces. There are no interstitial/rewarded ads and no ads
  on Money/Pay Protection, Proof, editors, evidence, backup/restore, App Lock or
  export/share flows;
- **no subscription, Pro entitlement, purchase, or remove-ads feature is linked.**

Module 07 backup/recovery and Module 08 security remain included:

- password-encrypted, versioned `.workproof` backups contain a transactionally
  consistent SQLite snapshot, evidence, device evidence key, record counts,
  per-file sizes and SHA-256 checksums;
- restore decrypts into private temporary storage, blocks ZIP path traversal,
  verifies the complete manifest, previews counts, and supports merge or
  replace only after explicit confirmation;
- every restore creates an encrypted pre-import recovery snapshot and restores
  the prior database, evidence tree and key automatically if validation fails;
- recovery snapshots run at most once per 24 hours and rotate the latest three;
- new evidence is encrypted at rest with authenticated AES-256-GCM while export
  decrypts only a verified privacy copy in temporary staging;
- optional 4–8 digit app lock uses a salted PBKDF2 verifier, biometric unlock,
  attempt throttling, and automatic relock after backgrounding;
- backup/restore and app-lock screens contain localized action feedback, and
  backup/restore is blocked while a work timer is active;
- Android backup is disabled for device-bound secrets, Android uses a
  `FlutterFragmentActivity`, and iOS includes the Face ID purpose string.

Module 06 smooth-performance behavior remains included:

- evidence image decode/resize/hash, PDF rendering, ZIP creation, and
  notification-plan calculation run away from Flutter's UI isolate;
- live clocks rebuild only their small visible subtree and pause in background
  or inactive indexed tabs;
- debounced, screen-scoped search avoids database churn and picker/list jumps;
- fixed-geometry loading skeletons and remembered scroll positions stabilize
  screen layout during refreshes;
- targeted Riverpod invalidation prevents unrelated tabs from reloading after
  every local save;
- calendar day bucketing, batched time-entry hydration, limited dashboard
  queries, SQLite WAL/busy timeout, and schema-v7 indexes support larger local
  workspaces;
- the Module 05 guided tours, localization, clear action feedback, evidence
  integrity, and privacy behavior remain included.

English and Bangla contain the complete Module 04–11 copy. Every included ARB
has the same key coverage; locales awaiting native copy use an explicit English
fallback so no screen renders a missing localization key.

The current Module 10–11 handoff and release configuration are summarized
above. Release IDs use `ADMOB_APP_ID`, `ADMOB_ANDROID_BANNER_ID`, and
`ADMOB_IOS_BANNER_ID` build settings.

## Run locally

Use Flutter 3.41.1 / Dart 3.11 or newer compatible versions:

```bash
flutter pub get
flutter gen-l10n
dart format lib
flutter analyze
flutter test
flutter run
```

The generated localization files in `lib/l10n/generated/` must be refreshed
after changing an ARB file.

## Safety boundaries

- SQLite remains the screen source of truth.
- User actions save locally before any optional network work.
- Money is stored in integer minor units and calculations are deterministic.
- Evidence originals are kept private; exports prefer privacy-safe copies.
- Backup passwords are never stored; losing one makes that backup unrecoverable.
- Restore never continues after a checksum, schema, database, or relationship
  integrity failure.
- A possible pay difference is a review prompt, not a legal conclusion.
- No cloud-backup claim is made until encrypted bytes are acknowledged remotely.
# TradesmanApp
