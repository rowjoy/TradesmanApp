# WorkProof Website Content and Legal Pages

**Document status:** Draft for owner review  
**Prepared:** 18 October 2026  
**Product:** WorkProof  
**Tagline:** Track your work. Protect your pay. Keep your proof.

This master document contains the website structure, publishable marketing copy, app details, Privacy Policy, Terms and Conditions, FAQ, contact copy, SEO metadata, and a pre-publication checklist for WorkProof.

Every unresolved value uses double braces around an uppercase underscore name, such as `{{SUPPORT_EMAIL}}`, and is listed in the Placeholder Register near the end of this document. Replace every placeholder and remove every visibly marked owner-action callout before publication. The Privacy Policy and Terms must be reviewed by a qualified lawyer for the countries where WorkProof will launch. Store privacy declarations must be checked against the final Android and iOS release builds.

## Recommended Website Structure

Use the following main navigation:

1. Home
2. Features
3. About WorkProof
4. FAQ
5. Privacy Policy
6. Terms and Conditions
7. Contact

The recommended first release is a static informational website without accounts, contact-form storage, advertising trackers, or non-essential cookies. Use direct email, WhatsApp, and app-store links instead. If analytics, advertising pixels, cookies, forms, newsletters, or user accounts are later added to the website, update the Privacy Policy and consent controls before enabling them.

## Brand Information

**Product name:** WorkProof  
**Tagline:** Track your work. Protect your pay. Keep your proof.  
**One-line description:** An offline-first work, time, pay, and evidence companion for employees and self-employed tradespeople.  
**Primary audience:** Employees, tradespeople, service providers, and people who manage both employer work and customer work.  
**Primary promise:** Plan work, record what happened, review the money, and keep useful proof in one local workspace.  
**Current release:** `{{CURRENT_RELEASE_VERSION}}`

## Home Page Copy

### Hero Section

#### Track your work. Protect your pay. Keep your proof.

Plan employer shifts and customer jobs, track working time, review pay and income, and keep useful records together. WorkProof's core features work offline, and no account is required.

**For employees, self-employed tradespeople, and people who do both.**

Primary button: **Get WorkProof on Google Play**  
Link: `{{GOOGLE_PLAY_URL}}`

Secondary button: **Download on the App Store**  
Link: `{{APPLE_APP_STORE_URL}}`

> **Owner action — remove before publication:** Show each store button only after that platform's production build and public listing are verified. This instruction applies to every download button in this document.

Supporting line: **Your core workspace is stored on your device, subject to your operating-system backup settings. You decide when to export or share it.**

### Product Overview

#### One Place for the Full Working Day

Work details are often scattered across calendars, notes, timers, payslips, invoices, photos, and spreadsheets. WorkProof brings those records into one practical workspace.

Use it to plan upcoming work, record what actually happened, review money, keep supporting documents, and create reports when you need them. Employer shifts and customer jobs remain separate, even when you manage both in the same app.

### Who WorkProof Is For

#### Employees

Plan shifts, track hours and paid or unpaid breaks, calculate expected pay, record payslips, and compare expected and received amounts.

#### Tradespeople and Self-Employed Workers

Manage customers, services, jobs, costs, quotes, invoices, payments, receipts, and outstanding balances.

#### People Who Do Both

Keep employer work and customer work in separate flows while using one calendar, timer, records system, and reporting workspace.

### Why Use WorkProof

- **Work without an account.** Core record-keeping, calculations, reminders, and report creation are designed to work without an active internet connection.
- **Keep work and money connected.** Move from a planned shift or job to tracked time, pay, expenses, documents, and reports.
- **Build a clearer record.** Save schedules, corrections, calculations, documents, and export history so you can review how a result was reached.
- **Keep employee and customer work separate.** Employer pay summaries do not mix with customer invoices and business income.
- **Choose when to share.** Create reports and documents on your device, review them, and share them through another app only when you are ready.
- **Protect important records.** Use an optional app lock, encryption for protected Pay Review attachment files, integrity checks, and password-encrypted backup files.
- **Adapt the workspace to your work.** Choose a language, region, currency, and hourly, daily, fixed-price, or mixed charging method. Schedules use the device's IANA time zone.

### How WorkProof Works

1. **Set up your workspace.** Choose your language, region, currency, work mode, and usual pay or charging method.
2. **Plan the work.** Add an employer shift or customer job with its schedule, rate, reminders, and notes.
3. **Track what happens.** Clock in and out, record paid or unpaid breaks, and compare planned time with actual time.
4. **Review the money.** Check expected pay and payslips, or manage job costs, invoices, payments, and outstanding amounts.
5. **Keep the record.** Add supporting evidence, create reports or document packs, and make an encrypted backup.

### Home Page Feature Highlights

#### Plan Jobs and Shifts

Schedule employer shifts and customer jobs, including overnight work, the device's local IANA time zone, rates, notes, priorities, reminders, and progress status.

#### Track Time and Breaks

Use one reliable timer across jobs and shifts. Record paid and unpaid breaks, correct completed entries with a reason, and compare planned time with actual time.

#### Review Pay and Income

Compare expected and received pay, record payslips and deductions, or manage quotes, invoices, expenses, payments, and outstanding balances.

#### Keep Evidence and Reports

Attach selected documents, maintain local activity history, and create PDF, CSV, and evidence-pack exports from your saved records.

#### Back Up Your Workspace

Create a password-encrypted `.workproof` backup, verify it before restoring, and choose whether to merge it with or replace the current workspace.

#### Work Offline

Core planning, tracking, calculations, reports, reminders, promotion creation, and QR or barcode tools are designed to work without an account or continuous connection.

### Privacy and Security Summary

#### Your Records, with Practical Controls

WorkProof stores its core workspace in a local database on your device. No WorkProof account is required, and the current app does not automatically upload your work database to a WorkProof cloud service.

New attachment files added through the protected Pay Review evidence path use authenticated AES-256-GCM encryption. Typed notes, acknowledgements, the main database, and files created through other paths are not covered by that attachment-file claim. Manual `.workproof` backups are password encrypted. An optional PIN and supported device biometrics can restrict access through the app.

Encryption has a defined scope. The main local database is not separately encrypted by WorkProof, and ordinary PDF, CSV, ZIP, image, invoice, receipt, and other export files may be unencrypted after creation. Store and share exported files carefully.

WorkProof may use internet connections for Firebase Crashlytics and Firebase Analytics in the reviewed Android configuration, Google Mobile Ads and consent management, app updates, store reviews, WhatsApp, and sharing through apps you select. On Android, bundled Google ML Kit barcode scanning may also send limited technical diagnostic and usage data to Google; camera input and decoded barcode values remain on the device according to Google's disclosure.

Button: **Read the Privacy Policy**  
Link: `{{PRIVACY_POLICY_URL}}`

### Final Call to Action

#### Keep the Record While the Work Is Fresh

Plan the job. Track the time. Review the money. Keep the proof.

Primary button: **Get WorkProof on Google Play**  
Link: `{{GOOGLE_PLAY_URL}}`

Secondary button: **Download on the App Store**  
Link: `{{APPLE_APP_STORE_URL}}`

## About WorkProof Page Copy

### About WorkProof

WorkProof is an offline-first mobile app built to help people keep a clearer record of their working day. It brings schedules, time tracking, pay review, customer-job finances, supporting evidence, reports, and backups into one practical workspace.

The app is designed for employees who want to compare shifts, hours, expected pay, and payslips; for self-employed tradespeople who manage jobs, invoices, payments, and expenses; and for people who do both. Employer work and customer work remain separate so each type of record stays easier to understand.

### Why WorkProof Exists

Important work details are easy to lose when they are spread across notes, messages, calendar entries, photographs, payslips, invoices, and memory. WorkProof helps users record information while it is still fresh, connect time with money, and create organised reports or documents when they need to review or share their records.

### Built Around Local Ownership

Core features do not require a WorkProof account or a continuous internet connection. The primary workspace is stored on the user's device, subject to operating-system or device-backup settings, and the current app has no WorkProof-operated cloud-sync service. Users choose when to create a manual backup, export a document, or share a file.

Offline-first does not mean that the app never connects to the internet. Crash diagnostics, Firebase Analytics in the current Android configuration, Android ML Kit scanner telemetry, advertising and consent, app-store services, WhatsApp, and user-selected sharing may use external services. The Privacy Policy explains those connections and the information they may process.

### Practical Records, Not Professional Advice

WorkProof helps organise information and perform repeatable calculations from the details entered by the user. It does not decide legal employment status, guarantee wage or tax compliance, verify signatures or evidence independently, or replace legal, payroll, tax, accounting, employment, or financial advice.

### Product Principles

- **Useful offline:** Core work should remain available without an account or continuous connection.
- **Clear separation:** Employer pay records and customer-business finances should not be mixed.
- **Reviewable calculations:** Important totals should be traceable to saved time, rates, breaks, adjustments, expenses, and payments.
- **User-controlled sharing:** Exports should be created deliberately and reviewed before they leave the device.
- **Honest security claims:** Encryption, App Lock, backups, and checksums should be described according to what each control actually protects.

### App Information

**App name:** WorkProof  
**Current version:** `{{CURRENT_RELEASE_VERSION}}`  
**Android requirement:** Android 7.0 or later  
**Apple target:** iPhone and iPad release planned; the minimum OS is unresolved and availability must not be claimed until the deployment target, dependencies, production configuration, archive, and live App Store listing are verified  
**Developer or publisher:** `{{LEGAL_OWNER_NAME}}`  
**Website:** `{{WEBSITE_DOMAIN}}`  
**Support:** `{{SUPPORT_EMAIL}}`

## Complete Feature Details

### Workspace Setup and Personalisation

Choose Worker, Tradesman, or Both mode. Set the app language, country or region, currency, profession, usual pay or charging method, default rate, and light, dark, or system theme. Optional demo data can help a new user understand the workflow before entering real records.

No account is required. Setup information is saved in the app's local workspace.

### Dashboard

See today's work, the active timer, upcoming jobs or shifts, and shortcuts for common actions. Users in Both mode can switch between employer work and customer work without combining the two financial views.

### Work Planning

Create, search, filter, edit, and manage employer shifts or customer jobs.

Employer shifts can include:

- Employer and workplace
- Normal or overnight schedules
- The device's saved IANA time zone
- Hourly rate
- Planned paid or unpaid break
- Notes and reminders
- Scheduled or completed status

Customer jobs can include:

- Customer and service
- Address and description
- Schedule and priority
- Hourly, daily, fixed-price, or mixed pricing
- Notes and reminders
- Status from lead and quoted through completed, invoiced, partially paid, paid, or cancelled

### Time Tracking

Clock in and out with one active session at a time across all jobs and shifts. The timer can recover after an app restart. Record paid or unpaid breaks, compare planned and actual time, and review recent sessions.

Completed time can be corrected, but the app requires a reason and keeps the correction in local audit history. Earnings calculations can include rates, overtime thresholds and multipliers, premiums, rounding, extra pay, and paid or unpaid breaks.

Calculations are record-keeping aids. Their accuracy depends on the user's entries and settings.

### Contacts and Services

Keep separate directories for employers, workplaces, customers, and reusable services. Records may include names, addresses, phone numbers, email addresses, billing currencies, pay schedules, contract notes, standard prices, and typical durations.

### Work Calendar

Browse work in a monthly calendar and daily agenda. Open an existing job or shift, or add new work from the date being viewed. Time-zone-aware schedules support overnight work and daylight-saving changes.

### Worker Pay Review

Create weekly, fortnightly, four-weekly, monthly, or custom pay periods. Calculate expected pay from completed work, record gross and net payslip amounts, deductions, adjustments, and supporting documents, and compare expected and received amounts.

A possible pay difference is a prompt to review the records. It is not a legal finding of underpayment or wrongdoing.

### Tradesman Job Finances

Track job pricing, expenses, tax or VAT inputs, invoices, payments, outstanding balances, and business income. Create PDF quotes, confirmations, invoices, and receipts from the saved information.

WorkProof records payments but does not process card or bank transactions.

### Work Records and Evidence

Review a local timeline of important setup, job, time, correction, pay, evidence, and export activity. Add notes, photos, documents, payslips, and acknowledgements to relevant pay records.

Selected evidence can be included in an offline PDF and ZIP pack. SHA-256 checksums help detect later file changes, but they do not prove that the original information was true, identify who created it, or guarantee legal acceptance.

### Reports and Statements

Create weekly, monthly, or custom reports from the local workspace.

Worker reports can include:

- Recorded and billable hours
- Expected and received gross pay
- Deductions
- Net payment
- Possible difference

Tradesman reports can include:

- Recorded and billable hours
- Billable work
- Invoiced and paid amounts
- Outstanding amounts
- Expenses
- Net cash

Filter reports by employer or customer, then create PDF or CSV exports. Report generation happens on the device, and the app records a checksum and local audit entry for each completed report export.

### Work Reminders and Alerts

Schedule local alerts for upcoming work, preparation time, starts, breaks, and planned finishes. Configure quiet hours, daily summaries, optional motivation, and private lock-screen wording.

Delivery can be delayed or suppressed by notification permissions, device battery rules, operating-system limits, clock or time-zone changes, and other conditions. Reminders should not be the only control for an emergency or legal deadline.

### Backup and Restore

Create a password-encrypted `.workproof` file containing a consistent copy of the local database, evidence, and the key needed to restore protected evidence. WorkProof checks the backup before restoration and supports confirmed Merge or Replace modes.

A protected local recovery snapshot is created before a restore. WorkProof attempts to roll back if validation or restoration fails. Automatic recovery snapshots rotate to the latest three.

Backups are not uploaded automatically. The password is not stored and cannot be recovered by WorkProof.

### App Lock and Evidence Protection

Add an optional 4–8 digit PIN and use supported device biometrics for app unlock. Failed PIN attempts are temporarily limited, and the app can relock after moving to the background.

The PIN verifier, evidence key, and recovery secret use operating-system secure storage. App Lock restricts access through the WorkProof interface; it does not encrypt the complete database or every generated file.

New attachment files added through the protected Pay Review evidence path use AES-256-GCM authenticated encryption. That protection does not cover typed notes and acknowledgements in the SQLite database, every legacy or separately generated file, or ordinary exports.

### Promotion Creator

Create reusable promotional material on the device. Add a business or professional name, headline, offer, services, contact information, logo, business photo, and design style. Preview the result and export an image or A4 PDF for user-directed sharing. The marketing share payload can also include the saved display name, headline, offer, phone number, email, website, and address as plain text.

### QR and Barcode Tools

Scan QR codes and common barcodes with the device camera, or generate QR and Code 128 images from text. Copy scanned content, or share a generated PNG together with its raw source text through the operating-system share interface. Camera input and decoded values are processed on the device. On Android, the bundled Google ML Kit scanner may send Google limited device and app information, per-installation identifiers, performance metrics, API configuration, feature version, feature input and output sizes, and event or error data for diagnostics and usage analytics; Google states that barcode input and decoded values are not sent.

### Guided Help, Feedback, Reviews, and Updates

Replay guided product tours and the Pay Review guide from Settings. Send optional feedback through WhatsApp and open the app-store listing to leave a rating. In the reviewed build, when the update service detects a newer store version, the update prompt blocks continued app use and cannot be dismissed.

> **Owner action — remove before publication:** Either keep this forced-update wording and provide users a practical pre-gate backup route, or wire and test the intended optional-versus-mandatory update policy before changing the public claim.

Opening a store, WhatsApp, or another sharing destination uses that third party under its own terms and privacy practices.

## Platforms, Languages, and Currency Options

### Target Platforms

- Android 7.0 or later; final availability depends on the live Google Play listing and compatible devices
- iPhone and iPad release planned; the minimum OS and availability are not yet confirmed

> **Owner action — remove before publication:** Show a platform and its download button only after its production build and public store listing have been verified.

> **Owner action — remove before publication:** The project currently declares iOS 13, while the resolved Firebase Core, Analytics, and Crashlytics Flutter plugins require iOS 15. Reconcile the Podfile, deployment target, lockfile, dependency set, and archive; then publish only the minimum version proved by the signed production build.

### Interface Languages

- English
- Bengali or Bangla
- Hindi
- Japanese
- Polish
- Urdu
- Romanian
- Irish or Gaeilge
- Yoruba
- Simplified Chinese

English and Bangla currently contain the fullest native copy. The other eight locales are partially translated and contain substantial English fallback text until their native translations are completed and reviewed.

### Currency Options

- British pound or GBP
- Euro or EUR
- Indian rupee or INR
- Japanese yen or JPY
- Bangladeshi taka or BDT
- United States dollar or USD

Changing the default currency changes future display and defaults; it does not automatically convert historical records.

## Store Listing Copy

### Google Play Short Description

Track work, time, pay, jobs, and proof offline without an account

### Apple App Store Subtitle

Work, Pay & Job Records

### Apple App Store Promotional Text

Plan shifts and customer jobs, track time and breaks, review pay or business income, keep supporting evidence, and create useful reports from one local workspace.

### Full Description

WorkProof helps employees and self-employed tradespeople keep work, time, money, and supporting records together.

Choose Worker mode for employer shifts, hours, expected pay, payslips, and deductions. Choose Tradesman mode for customer jobs, quotes, invoices, payments, expenses, and outstanding balances. Choose Both to keep the two workflows separate in one app.

With WorkProof you can:

- Plan jobs and shifts, including overnight schedules with the device's DST-aware IANA time zone
- Track clock-ins, clock-outs, and paid or unpaid breaks
- Compare planned time with actual time
- Calculate expected earnings from saved rates and rules
- Review payslips and possible pay differences
- Manage customers, employers, workplaces, and services
- Record invoices, payments, expenses, and job progress
- Keep selected supporting photos and documents
- Create PDF, CSV, quote, invoice, receipt, and evidence-pack exports
- Schedule local reminders with quiet hours and privacy controls
- Protect access with an optional PIN and device biometrics
- Create password-encrypted backups and verify them before restore
- Make promotional images or PDFs on the device
- Scan or generate QR codes and common barcodes

Core features work offline, and no WorkProof account is required. Limited network-connected services in the reviewed Android configuration include crash diagnostics, Firebase Analytics, Android ML Kit scanner telemetry, advertising and consent, app updates, reviews, WhatsApp, and user-selected sharing.

WorkProof is a record-keeping and calculation aid. It does not provide legal, employment, payroll, tax, accounting, or financial advice. Always review important calculations and documents before relying on or sharing them.

### Suggested Google Play Keyword Themes

work tracker, shift tracker, job manager, timesheet, clock in, pay tracker, invoice, tradesman, contractor, work evidence, offline reports, job timer

### Suggested Apple Keyword Field

work,shift,timesheet,pay,job,invoice,tradesman,contractor,evidence,offline,timer

## Contact Page Copy

### Contact WorkProof

Questions, feedback, privacy requests, and support enquiries are welcome.

**Support email:** `{{SUPPORT_EMAIL}}`  
**Privacy email:** `{{PRIVACY_CONTACT_EMAIL}}`  
**Business address:** `{{BUSINESS_ADDRESS}}`  
**WhatsApp:** [`{{WHATSAPP_SUPPORT_NUMBER}}`]({{WHATSAPP_SUPPORT_URL}})

> **Owner action — remove before publication:** The reviewed app is hard-coded to `+8801783109748`. Confirm that it is controlled, monitored, and suitable for public support and privacy communications; then fill both WhatsApp placeholders. If a different number is chosen, update and test the app as well as this website copy.

The in-app WhatsApp option opens an external link with an editable draft. No message is delivered to WorkProof support until the user presses Send; opening the link may disclose the destination number, prefilled draft, and technical request data to WhatsApp or Meta. Do not send an app-lock PIN, backup password, complete evidence archive, or other sensitive record unless support has explained why it is needed and the user has chosen an appropriate secure method.

Expected response time: `{{SUPPORT_RESPONSE_TIME}}`

## Footer Copy

**WorkProof**  
Track your work. Protect your pay. Keep your proof.

Navigation: Home · Features · About · FAQ · Privacy · Terms · Contact

Google Play: `{{GOOGLE_PLAY_URL}}`  
App Store: `{{APPLE_APP_STORE_URL}}`

© `{{COPYRIGHT_YEAR}}` `{{LEGAL_OWNER_NAME}}`. All rights reserved.

WorkProof is a record-keeping tool and does not provide legal, payroll, tax, accounting, employment, or financial advice.

## Privacy Policy

**Effective date:** `{{EFFECTIVE_DATE}}`  
**Last updated:** `{{LAST_UPDATED_DATE}}`

WorkProof is an offline-first mobile application for recording work, time, pay, expenses, customers, employers, evidence, and related documents.

This Privacy Policy explains how personal information is processed when someone uses the WorkProof mobile application or the informational website at `{{WEBSITE_DOMAIN}}`. “WorkProof,” “we,” “us,” and “our” mean `{{LEGAL_OWNER_NAME}}`, of `{{BUSINESS_ADDRESS}}`.

### 1 Scope

This Policy applies to:

- The WorkProof mobile application
- The informational website at `{{WEBSITE_DOMAIN}}`
- Communications a person chooses to send to us, including through email or WhatsApp
- Limited online services used by the app for Firebase Crashlytics and Analytics in the reviewed Android configuration, Android barcode-scanner diagnostics, advertising consent and delivery, updates, and store reviews

It does not govern third-party apps or services selected when exporting, saving, or sharing information. Those services apply their own privacy policies.

This draft is written for an informational website without accounts, contact-form storage, advertising pixels, or non-essential cookies. When implemented that way, its hosting provider may still process ordinary request logs such as IP address, browser or device type, requested page, referring page, and date and time for security and delivery. If the website implementation changes, this Policy and any required consent controls must be updated before the new processing begins.

> **Owner action — remove before publication:** Audit the deployed website, host, CDN, cookies, forms, analytics, pixels, store and messaging links, email handling, and log retention. Replace the first sentence above with a present-tense statement that matches the live site.

### 2 Offline-First Design

WorkProof does not require a WorkProof account or sign-in. The current version has no active WorkProof-operated cloud synchronisation or application backend. The local database contains fields designed for possible future synchronisation, but the current app does not send the work database to a WorkProof server.

Offline-first does not mean that the app never communicates over the internet. The app uses or may use Google Firebase, Google ML Kit on Android, Google Mobile Ads, consent services, app-store services, WhatsApp, website hosting, and apps selected by the user, as explained below.

| Activity | Main processing location | When information may leave the device |
| --- | --- | --- |
| Work, customer, employer, job, time, pay, evidence metadata, and settings | The user's device | Not sent to a WorkProof backend in the current version; operating-system backup may copy app data as described below |
| Protected Pay Review attachment files | The user's device | When the user creates and shares an export or manual backup, or when operating-system backup applies |
| Reports, invoices, evidence packs, marketing files, and generated code PNGs | The user's device | When the user selects a destination through the operating-system share interface; depending on the workflow, the payload may include accompanying plain subject or message text such as a job title or reference, marketing contact and offer details, or a generated code's raw source text |
| Operating-system backup or device transfer | Device platform or the user's configured backup provider | Android cloud backup is disabled in the reviewed manifest, but Android 12 or later may still permit device-to-device transfer on some manufacturers' devices unless explicit data-extraction rules prevent it; iOS device or iCloud backup may copy app-container data depending on system and user settings until exclusions are verified |
| Crash reporting | Google Firebase | The reviewed Android configuration may send crash and diagnostic reports automatically; iOS production behaviour is unresolved |
| Firebase Analytics | Google | The reviewed Android configuration should be treated as automatically collecting basic usage, identifier, and device data; the production iOS status must be confirmed |
| Android barcode scanning | Google ML Kit | Limited device and app information, per-installation identifiers, performance metrics, API configuration, feature version, feature input and output sizes, and event or error data may be sent for diagnostics and usage analytics; camera input and decoded values remain on-device according to Google |
| Advertising and consent | Google and participating advertising vendors | Consent, technical, identifier, advertising, and interaction data may be transmitted |
| App updates and reviews | Google Play or Apple App Store | Store requests and information submitted to the store |
| WhatsApp feedback | WhatsApp and Meta | Opening the external link may disclose the destination number, prefilled draft, and technical request data; message content is delivered to WorkProof support only if the user presses Send |
| Email support or privacy requests | The user's selected email app and `{{EMAIL_SERVICE_PROVIDER}}` | Addressing or sending an email may disclose addressing, message, attachment, and technical delivery data to those providers; content reaches WorkProof when it is sent |
| Website delivery | `{{WEBSITE_HOSTING_PROVIDER}}` | Technical request logs are received when someone visits the website |

### 3 Data Controller and User Responsibilities

For personal information transmitted for diagnostics, analytics, advertising, website delivery, or support, the data controller or equivalent business is:

**Controller:** `{{LEGAL_OWNER_NAME}}`  
**Address:** `{{BUSINESS_ADDRESS}}`  
**Privacy email:** `{{PRIVACY_CONTACT_EMAIL}}`

WorkProof normally cannot access records held only in the app's local storage.

When a user records information about customers, workers, employers, suppliers, or signers, that user decides why the information is recorded and shared. The user may therefore be a separate controller or business under applicable privacy law and is responsible for having an appropriate lawful basis, providing any required notices, limiting what is recorded, and responding to the rights of those individuals.

Google and other third parties may act as processors, service providers, or independent controllers depending on the service, configuration, and purpose. Their own notices and terms describe their roles.

### 4 Information Processed Locally

Depending on how the app is used, WorkProof may process the following information on the device:

- **Profile and preferences:** language, country, currency, profession, work mode, pay method, default rate, theme, onboarding status, and demo-data choice.
- **Customer and business contacts:** names, phone numbers, email addresses, physical addresses, billing currency, official references, pay schedules, contract information, service details, and notes.
- **Work records:** job and shift titles, descriptions, locations, dates, schedules, time zones, priorities, status, rates, reminders, clock-in and clock-out times, breaks, calculations, corrections, and notes.
- **Financial records:** quotes, invoices, line items, tax or VAT inputs, expenses, payments, payment methods and references, receipts, pay periods, payslips, gross and net pay, deductions, adjustments, overtime, premiums, and calculated differences.
- **Evidence and documents:** selected photos, files, payslips, file names, types, sizes, paths, descriptions, signatures, timestamps, hashes, and resized, re-encoded image copies with metadata removed.
- **Marketing content:** name, headline, offer, services, phone number, email address, website, address, logo, cover image, and design choice.
- **Notification information:** reminder settings, notification text, scheduled times, time zone, permission status, quiet hours, delivery state, and custom motivation messages.
- **Security and backup information:** a salted app-lock PIN verifier, biometric setting, encryption keys held through operating-system secure storage, backup history, file names, sizes, checksums, and restore state.
- **Operational records:** local identifiers, drafts, audit events, deletion markers, pending-operation records, export paths, checksums, and calculation snapshots.

Some of this information may be sensitive, especially pay records, signatures, identity-related documents, and free-text notes. Users should record only information they are entitled to process.

### 5 Camera, Scanner Diagnostics, Files, Clipboard, and Biometrics

The camera is used to scan QR codes and barcodes. Camera frames and decoded values are processed on the device and are not intentionally uploaded by WorkProof. A detected value remains on the current screen and may be copied to the clipboard if the user chooses. Clipboard contents may be accessible to the operating system or other apps under their applicable rules.

On Android, the scanner includes the bundled Google ML Kit barcode-scanning library. Google states that barcode input and decoded values remain on the device, but ML Kit may send Google device and app information, per-installation identifiers, performance metrics, API configuration, feature version, feature input and output sizes, and event or error data for diagnostics and usage analytics. Google states that this data is encrypted in transit and is not shared with third parties. The iOS scanner uses Apple's on-device Vision technology rather than the Android ML Kit library. See Google's [ML Kit Android data disclosure](https://developers.google.com/ml-kit/android-data-disclosure).

WorkProof uses operating-system file pickers so the user can choose evidence, payslips, logos, cover photos, or backup files. It does not request access to every file on the device. If a selected file comes from a cloud provider exposed through the picker, that provider handles the request under its own terms.

When biometric App Lock is enabled, WorkProof asks the operating system to authenticate the user. WorkProof receives a success or failure result and does not receive or store the user's fingerprint, face template, or other raw biometric data.

### 6 Crash and Diagnostic Information

In the reviewed Android configuration, WorkProof initialises Firebase Crashlytics when the app starts and explicitly reports unhandled Flutter framework and Dart errors as fatal. The native Crashlytics SDK may also collect native crash reports. Crashlytics may process:

- Crash traces and exception messages
- Crashlytics installation identifiers and Firebase installation identifiers
- Firebase session identifiers and relevant application state
- App identifier, version, and crash timestamp
- Device model, operating system, CPU architecture, memory, and storage information
- Whether the app was in the background
- Root or jailbreak indicators
- Automatic Analytics breadcrumb logs or user-action context where the enabled Analytics integration supplies them
- Other technical information needed to diagnose a failure

WorkProof does not intentionally attach work records to crash reports. An exception message, breadcrumb, application state, or technical context could nevertheless contain incidental information such as a file name, path, action, or operation that was underway. No custom Analytics event calls were found in the reviewed source.

The iOS Firebase configuration and dependency lockfile are incomplete or stale, so iOS Crashlytics behaviour must be verified from a successful production archive before iOS availability is claimed.

Google describes Crashlytics processing and retention in its [Firebase Privacy and Security documentation](https://firebase.google.com/support/privacy/).

### 7 Firebase Analytics

The reviewed Android source includes and configures Firebase Analytics, initialises Firebase at startup, and contains no explicit runtime or native setting that disables automatic Analytics collection. The current Android configuration must therefore be treated as Analytics-enabled. No explicit custom Analytics event calls were found. The iOS production Firebase configuration is incomplete, so no iOS availability or Analytics-status claim should be published until a production archive and network behaviour are verified.

In the current Android configuration, Analytics may process an app-instance identifier, app opens and sessions, automatically collected events, app version, device information, approximate location derived from network information, and advertising identifiers where available under platform settings.

The app does not intentionally include customer names, pay records, evidence, or free-text work notes in custom Analytics events.

> **Owner action — remove before publication:** Decide whether Analytics is needed. If retained, confirm and disclose its purpose, legal basis, consent or opt-out controls, configured retention, advertising integration, and production behaviour on each platform. If removed or disabled before release, update every Analytics statement only after release-build and network testing proves collection is off.

Google describes [automatically collected events](https://support.google.com/analytics/answer/9234069) and [data collection configuration](https://firebase.google.com/docs/analytics/configure-data-collection).

### 8 Advertising and Consent Information

After onboarding, WorkProof uses Google's User Messaging Platform to determine whether a privacy message or consent choice is required. The Google Mobile Ads SDK is initialised only after Google's consent service reports that ad requests may be made.

Depending on region, choices, device, and configuration, Google and participating advertising partners may process:

- IP address and approximate location
- Consent status and privacy choices
- Advertising, app-set, app-instance, signed-in account, or other device identifiers where available
- App launches and interactions
- Ad requests, impressions, ads viewed, and ad interactions
- Device, app, and operating-system information
- Performance and diagnostic information
- Information used for advertising, measurement, security, and fraud prevention

WorkProof does not intentionally send the contents of the work database, evidence files, contact directory, or pay records to the advertising SDK.

Google describes the Mobile Ads SDK's [Android data disclosure](https://developers.google.com/admob/android/privacy/play-data-disclosure), [iOS data disclosure](https://developers.google.com/admob/ios/privacy/data-disclosure), and [UMP privacy flow for Flutter](https://developers.google.com/admob/flutter/privacy).

### 9 Updates, Reviews, Feedback, and Sharing

WorkProof may check Google Play or Apple's App Store for updates and may request a store review after eligibility conditions are calculated locally. Store services may receive ordinary request information such as IP address, app identifier, installed version, store country, and device or store information. Any rating or review is submitted directly to the store.

When a user selects Send Feedback on WhatsApp, WorkProof opens an external WhatsApp link with an editable draft. WhatsApp may receive the destination number, draft content included in the link, network information, and anything the user chooses to add or send. WhatsApp applies its [Privacy Policy](https://www.whatsapp.com/legal/privacy-policy).

When a user shares a backup, report, document, evidence pack, marketing file, or generated code, WorkProof gives the selected item to the operating system's share interface. Depending on the workflow, the payload may also contain plain subject or message text—for example, a job title or reference, a marketing display name, headline, offer, phone number, email, website or address, or a generated code's raw source text. The recipient app or service then processes the supplied item and text under its own policy. WorkProof cannot control or retrieve copies held by recipients.

### 10 Purposes and Legal Bases

Where the GDPR, UK GDPR, or similar law requires a legal basis, the applicable bases should be stated below.

> **Owner action — remove before publication:** Have qualified counsel confirm every legal basis for the controller's country, users, consent design, and final release configuration.

| Purpose | Information involved | Anticipated legal basis |
| --- | --- | --- |
| Provide local work, time, pay, evidence, report, backup, notification, and security features | Information entered by the user, settings, and generated local records | Performance of a contract or steps taken at the user's request |
| Protect the app, recover data, maintain integrity, and manage updates | Security settings, local keys, backups, checksums, and app metadata | Contract and legitimate interests in security, reliability, and continuity |
| Diagnose crashes and improve stability | Crash and diagnostic information | `{{CRASHLYTICS_LEGAL_BASIS}}` |
| Measure use through Firebase Analytics in the current Android configuration | App-instance, usage, device, approximate-location, and available advertising-identifier data | `{{ANALYTICS_LEGAL_BASIS}}` |
| Support Android barcode scanning diagnostics and usage measurement | ML Kit device, app, installation, performance, configuration, feature-version, feature input/output-size, event, and error data | `{{ML_KIT_LEGAL_BASIS}}` |
| Obtain privacy choices and deliver, measure, and secure advertising | Consent, identifiers, ad interactions, technical, and fraud-prevention data | Consent where required and `{{LIMITED_ADS_LEGAL_BASIS}}` |
| Check for updates and request optional reviews | App, store, and technical request information | Contract and legitimate interests in maintenance and feedback |
| Respond to messages initiated by a user | Contact details and message content | Steps taken at the user's request, contract, or consent |
| Deliver and secure the informational website | IP address, request logs, and device or browser information | Legitimate interests in providing and securing the website |
| Meet legal requirements and establish or defend claims | Relevant information actually available to us | Legal obligation or legitimate interests |

Where processing relies on consent, it may be withdrawn prospectively. Withdrawal does not affect processing that was lawful before withdrawal.

### 11 Disclosure to Other Organisations

Information may be disclosed to:

- **Google LLC and its affiliates** through Firebase Crashlytics and Firebase Analytics in the reviewed Android configuration, bundled Google ML Kit barcode scanning on Android, Google Mobile Ads, UMP, Google Play updates, and Google Play review services. Google states that ML Kit scanner telemetry is not shared by ML Kit with third parties. See [Google's Privacy Policy](https://policies.google.com/privacy), [Firebase privacy information](https://firebase.google.com/support/privacy), and [ML Kit Android data disclosure](https://developers.google.com/ml-kit/android-data-disclosure).
- **Advertising partners** where enabled and permitted by consent and other applicable choices. The current vendor list and purposes should be available through the UMP consent interface.
- **Apple Inc.** for App Store lookup, update, review, and operating-system services. See [Apple's Privacy Policy](https://www.apple.com/legal/privacy/).
- **WhatsApp and Meta** when a user opens or sends feedback using WhatsApp.
- **The user's selected email service and our email provider** `{{EMAIL_SERVICE_PROVIDER}}` when a user addresses or sends support, legal, or privacy email, including any message and attachment supplied by the user.
- **The website hosting provider** `{{WEBSITE_HOSTING_PROVIDER}}` for delivery and security logs.
- **Apps, people, and storage providers selected by the user** when information is exported, saved, printed, or shared.
- **Professional advisers, authorities, or courts** when disclosure of information actually held by us is reasonably necessary to comply with law, protect rights or safety, or establish or defend legal claims.
- **A successor or transaction counterparty** if the WorkProof business is reorganised, sold, or transferred, subject to applicable law and appropriate safeguards.

**Additional production vendors:** `{{ADDITIONAL_VENDORS}}`

We do not operate a data marketplace for the local contents of a user's WorkProof database. Disclosure of identifiers and interaction information for personalised or targeted advertising may nevertheless be treated as a sale, sharing, or targeted-advertising disclosure under some United States state laws even when no money is exchanged.

`{{US_STATE_PRIVACY_DISCLOSURE}}`

### 12 Advertising Choices

When UMP determines that a consent form is required, it presents relevant choices before WorkProof requests ads. When UMP requires an ongoing privacy-options entry point, WorkProof displays Privacy Choices in Settings.

Changing or refusing advertising consent does not necessarily make the app ad-free. Refusal may still permit non-personalised, limited, or technical ad delivery where lawful. Personalised advertising is used only when the necessary consent or another valid permission exists. Non-personalised advertising can still use local storage or identifiers for functions such as frequency control, fraud prevention, and aggregated reporting.

Users may also use device settings to limit or reset advertising identifiers and, where available, restrict app tracking. Availability and effect vary by platform and region.

`{{GLOBAL_PRIVACY_CONTROL_POSITION}}`

Advertising choices do not automatically control Crashlytics, Analytics, ML Kit scanner telemetry, store services, or information a user chooses to share.

> **Owner action — remove before publication:** Confirm whether an in-app Crashlytics or Analytics choice is legally required, implement any required control, and describe it here.

### 13 Device Permissions

WorkProof may request or use:

- **Camera:** to scan QR codes and barcodes on the device. On Android, ML Kit may separately transmit the limited scanner telemetry described in Section 5, but not camera input or decoded values according to Google.
- **Notifications:** to show locally scheduled work, shift, break, finish, and motivation reminders. Text may appear on the lock screen depending on app and operating-system settings.
- **Boot completed on Android:** to restore or reconcile scheduled local notifications after a restart or app update.
- **Biometrics:** to ask the operating system to authenticate the user for App Lock.
- **Files or photos selected by the user:** to import evidence, payslips, logos, cover images, or backups and to save or share generated files.

Permissions can be denied or revoked through device settings. The related feature may then be unavailable or limited.

The current app does not request precise location, microphone, contacts-address-book, or SMS permissions.

### 14 Local Storage, Encryption, and Backups

The main SQLite database and app preferences remain on the device while the app's storage remains available. WorkProof does not currently apply app-level encryption to the complete SQLite database.

Protected evidence files handled through the Pay Review evidence feature use authenticated AES-256-GCM encryption. WorkProof attempts to migrate older evidence to protected storage, but every legacy or separately generated artifact cannot be described as encrypted without verifying the final release and data state.

Generated reports, PDFs, CSV files, ordinary ZIP evidence packs, work documents, invoices, receipts, marketing images, QR or barcode images, and other exports are not automatically encrypted by WorkProof. Some signature or derived files may also exist without independent app-level encryption. Device-level encryption depends on the operating system, device, and passcode configuration.

Android cloud backup is disabled by the current manifest. On Android 12 or later, some device manufacturers may still permit device-to-device transfer despite that setting because explicit data-extraction rules have not been verified. Apple device-backup behaviour depends on operating-system and user settings. `{{IOS_BACKUP_STATUS}}`

Password-protected `.workproof` backups use AES-256-GCM authenticated encryption. The key is derived from the password entered by the user. WorkProof does not know or recover that password.

A manual backup contains the local database, evidence files, the evidence-encryption key, and source-device documents-directory path metadata inside the encrypted backup. Anyone who obtains the backup and its password may be able to restore its contents.

WorkProof also attempts to create an encrypted on-device recovery snapshot when one has not been created within the previous 24 hours. It keeps up to three recovery snapshots and removes older snapshots during successful rotation.

### 15 Retention and Deletion

Many delete actions in WorkProof are soft deletions. The active interface hides the record, but a database row may remain with a deletion timestamp. Audit logs, deletion markers, pending-operation records, and related metadata may also remain. The current version does not automatically purge all such records after a fixed period.

Deleting an active record does not remove copies already included in recovery snapshots, manual backups, reports, evidence packs, externally saved files, or third-party records.

The current version does not provide one in-app Erase All Data action. To remove the active local workspace, a user may need to clear the app's storage through Android settings or delete the app on iOS. Offloading an iOS app may preserve its data. Operating-system actions may not remove secure-storage entries, device or cloud backups, externally saved files, or information previously transmitted to service providers.

| Information | Current retention approach |
| --- | --- |
| Active local records and preferences | Until edited, deleted, app storage is cleared, or the app is deleted, subject to operating-system behaviour |
| Soft-deleted records, audit logs, and deletion markers | May remain indefinitely in the current local database |
| Automatic recovery snapshots | Up to three snapshots, with older snapshots removed during successful rotation |
| Manual encrypted backups and generated exports | Until the user deletes every copy from each location where it was saved or shared |
| Temporary export or restore files | Many workflows attempt cleanup after use, but generated QR or barcode PNGs written to temporary storage are not explicitly deleted by the current code and may remain until operating-system or app-storage cleanup; immediate or forensic erasure is not guaranteed |
| Crashlytics information | Google states that crash traces and associated identifiers are retained for 90 days before removal from live and backup systems begins |
| Firebase Analytics information | `{{FIREBASE_ANALYTICS_RETENTION_PERIOD}}` |
| Google ML Kit scanner telemetry | According to Google's applicable ML Kit disclosure and Privacy Policy; WorkProof does not configure this retention in app code |
| Advertising, app-store, WhatsApp, and website-host information | According to the relevant provider's settings and policies |
| Direct support communications, including email | `{{SUPPORT_COMMUNICATION_RETENTION_PERIOD}}`, subject also to the selected communication and email providers' retention policies |

### 16 Security

Security measures implemented in the current app include:

- AES-256-GCM authenticated encryption for protected Pay Review attachment files and encrypted backup files
- Password-based key derivation for manual backups
- Operating-system secure storage for evidence keys, recovery secrets, and App Lock information
- A salted, iterated verifier instead of storing the App Lock PIN as plain text
- Operating-system biometric authentication
- SHA-256 checksums and manifest verification for evidence, reports, and backups
- App sandbox storage and an Android manifest setting that disables cloud backup; device-to-device transfer may still occur on some Android 12-or-later devices, and iOS device or cloud-backup behaviour remains subject to the confirmed production configuration and user settings
- Integrity checks and recovery snapshots during backup restoration

App Lock controls access through the WorkProof interface. It does not encrypt the complete SQLite database or every generated file.

No storage or transmission method is completely secure. Users should use a strong device passcode, keep the operating system updated, choose a unique backup password, protect exported files, and verify recipients before sharing. A user should never send us an App Lock PIN or backup password.

### 17 International Transfers

Core local records are not transferred internationally merely because they are stored in WorkProof.

When Crashlytics, Analytics, Android ML Kit scanner telemetry, advertising, app-store, operating-system or cloud backup, website-hosting, communication, or user-selected sharing and storage services are used, information may be processed in countries other than the user's own, including the United States. Firebase states that global services such as Crashlytics may process information wherever Google or its subprocessors maintain facilities.

Where European transfer rules apply, transfers may rely on adequacy decisions, the EU–US Data Privacy Framework where applicable, Standard Contractual Clauses, UK or Swiss equivalents, or another lawful mechanism. See the [Firebase Data Processing and Security Terms](https://firebase.google.com/terms/data-processing-terms) and [Google Privacy Policy](https://policies.google.com/privacy).

`{{INTERNATIONAL_TRANSFER_DETAILS}}`

### 18 Privacy Rights

Depending on location, a person may have rights to:

- Know whether and how personal information is processed
- Request access to or a copy of personal information
- Correct inaccurate information
- Request deletion
- Restrict or object to processing
- Receive portable information
- Withdraw consent
- Opt out of targeted advertising or qualifying sale or sharing
- Limit certain uses of sensitive information
- Appeal a denied request
- Complain to a data-protection authority

Because WorkProof does not maintain user accounts and normally cannot access local records, we may be unable to retrieve, correct, or delete content held only on the user's device. Active records can be viewed and edited in the app, available exports can provide copies, and device controls can remove local app storage. An in-app record deletion may remain as a soft deletion in local history.

For information processed through Crashlytics, Analytics, ML Kit, advertising, website hosting, or support, contact us using the details below. We may need enough information to locate and verify the relevant record. Some pseudonymous SDK information may not be reasonably linkable to a real-world identity.

We will not discriminate against a person for exercising an applicable privacy right. Authorised-agent and appeal requests will be handled where required by law.

**Supervisory authority:** `{{RELEVANT_AUTHORITY_AND_LINK}}`  
**Request response period:** `{{APPLICABLE_RESPONSE_PERIOD}}`

WorkProof does not use locally stored work or pay records to make decisions that produce legal or similarly significant effects about a user. Google and advertising partners may perform profiling for personalised advertising when permitted by the user's choices and applicable law.

### 19 Children

WorkProof is intended for users aged `{{MINIMUM_USER_AGE}}` or older and is not directed to younger children.

We do not knowingly request children's information through a WorkProof account because the app has no account system. Advertising and diagnostic SDKs may process device data as described above, and a user could enter information about another person into a local record.

`{{CHILD_PRIVACY_AND_ADS_CONFIGURATION}}`

If a person believes information relating to a child has been transmitted to us contrary to this Policy, they should contact us. We will take reasonable steps available to us, recognising that we cannot access content held only on another person's device.

### 20 Changes to This Policy

We may update this Policy when WorkProof's features, vendors, legal obligations, or data practices change. The revised Policy will show a new Last updated date and will be available at `{{PRIVACY_POLICY_URL}}` and `{{IN_APP_POLICY_LOCATION}}`.

Where required, we will provide additional notice or seek consent before a material change takes effect. If a future version introduces accounts, cloud synchronisation, or a WorkProof backend, this Policy and applicable store disclosures will be updated before that processing begins.

### 21 Contact Us

For privacy questions or requests:

**Controller:** `{{LEGAL_OWNER_NAME}}`  
**Address:** `{{BUSINESS_ADDRESS}}`  
**Privacy email:** `{{PRIVACY_CONTACT_EMAIL}}`  
**General support:** `{{SUPPORT_EMAIL}}`  
**Data Protection Officer:** `{{DATA_PROTECTION_OFFICER_DETAILS}}`  
**EU representative:** `{{EU_REPRESENTATIVE_DETAILS}}`  
**UK representative:** `{{UK_REPRESENTATIVE_DETAILS}}`

## Terms and Conditions

**Terms version:** `{{TERMS_VERSION}}`  
**Effective date:** `{{EFFECTIVE_DATE}}`

### 1 Who We Are and What These Terms Cover

WorkProof is operated by `{{LEGAL_OWNER_NAME}}`, `{{LEGAL_ENTITY_DETAILS}}`, whose address is `{{BUSINESS_ADDRESS}}` (“WorkProof,” “we,” “us,” or “our”).

These Terms govern the download and use of the WorkProof mobile application, including updates we provide, and use of the informational website at `{{WEBSITE_DOMAIN}}`. Our Privacy Policy at `{{PRIVACY_POLICY_URL}}` explains how personal information is handled. The terms of the app store through which the app was obtained may also apply.

### 2 Eligibility and Authority

A user must be at least `{{MINIMUM_USER_AGE}}` years old and legally able to agree to these Terms. If applicable law permits a younger person to use the app only with a parent or guardian's agreement, that adult must agree to these Terms and supervise the use.

If the app is used for a business or another organisation, the user confirms that they have authority to bind that organisation. The organisation is then included in “you.”

### 3 Acceptance

By downloading, opening, or using the app, and by completing any acceptance screen we provide, you agree to these Terms. If you do not agree, do not use the app. Before deleting the app or clearing its storage, export or back up any records you wish to keep.

### 4 What WorkProof Does

WorkProof is an offline-first tool for planning jobs and employer shifts, tracking working time and breaks, recording expected and received amounts, keeping supporting records, preparing reports and business documents, creating encrypted backup files, and sharing user-selected exports.

A local WorkProof profile is not an online account. Core records are normally stored on the device, subject to operating-system backup settings. WorkProof does not currently provide account login or its own cloud-sync service. Supporting functions in the reviewed Android configuration may require a network connection, including advertising consent and delivery, Crashlytics, Firebase Analytics, ML Kit scanner telemetry, update checks, app-store functions, support, and sharing through third-party apps.

Worker, Tradesman, and similar labels are organisational modes in the app. They do not determine anyone's legal employment, contractor, tax, or business status.

### 5 Licence to Use WorkProof

Subject to these Terms, we grant you a limited, non-exclusive, non-transferable, non-sublicensable licence to use the app on compatible devices that you own or control for personal use or internal business record-keeping.

Except where applicable law or an open-source licence permits it, you must not:

- Copy, sell, rent, sublicense, redistribute, or commercially exploit the app itself
- Reverse engineer, decompile, or attempt to extract its source code
- Remove proprietary notices
- Interfere with security, integrity, advertising, or normal operation
- Use the app to gain unauthorised access to a device, service, or information

Open-source components remain subject to their respective licences.

### 6 User Content and Information About Other People

You retain any rights you hold in information, documents, images, logos, signatures, notes, and other material you enter or import. You permit the app to process that content as needed to provide features you request. We do not acquire ownership of your content merely because you use WorkProof.

Your records may contain information about customers, employers, workers, workplaces, suppliers, signers, or other people. You are responsible for determining whether you have a lawful basis, permission, or other authority to collect, store, use, export, and share that information. Where required, you must give appropriate notices and obtain valid consent, including before taking or using photographs, workplace records, documents, or signatures.

You are responsible for the accuracy of your records and should collect only information reasonably necessary for your purpose. WorkProof does not determine your legal or data-protection responsibilities for you.

### 7 Acceptable Use

You must not use WorkProof:

- Unlawfully or to infringe another person's privacy, confidentiality, intellectual-property, employment, or other rights
- To falsify hours, payments, expenses, evidence, acknowledgements, invoices, receipts, signatures, or audit history
- To impersonate someone or present a generated document as independently verified by WorkProof
- To store or distribute malware or harmful material
- To harass, exploit, deceive, or cause unlawful harm
- For emergency, life-safety, or other safety-critical scheduling or decision-making

### 8 Local Storage and Device Responsibility

WorkProof stores the primary workspace in local app storage, including a SQLite database, preferences, and files. We do not ordinarily receive those local work records. This does not apply to information deliberately shared or to limited information processed by the services described in the Privacy Policy.

Protected attachment files added through the Pay Review evidence path and backup archives are encrypted. That does not mean the entire app is end-to-end encrypted. Typed notes and acknowledgements, the local database, files created through other paths, and ordinary PDFs, CSVs, ZIP evidence packs, marketing files, and other exports may be unencrypted. App Lock controls access through the WorkProof interface and is not full-database or full-device encryption.

You are responsible for securing the device, maintaining operating-system protections, restricting access, and keeping sufficient storage available. A compromised, shared, rooted, jailbroken, lost, or poorly secured device may expose records.

We generally cannot retrieve or restore local records. Deleting an item may not securely erase every underlying copy, audit reference, backup, recovery snapshot, or export. Clearing app storage or deleting the app usually removes app-container data, subject to operating-system behaviour, but does not remove files already shared, copied, backed up, or saved elsewhere.

### 9 Backups and Recovery

Manual `.workproof` backup files are password encrypted and may contain the database, evidence, the key required to read protected evidence, and source-device documents-directory path metadata. The current app requires a password of at least ten characters. WorkProof does not store or recover that password. If it is forgotten, the backup may be permanently unusable.

Automatic local recovery snapshots may help roll back a failed restore, but they remain on the device and are not a substitute for a manual backup stored safely elsewhere. WorkProof does not provide its own cloud backup.

Restore operations can Merge compatible records or Replace the current workspace. Although the app validates supported backups and creates recovery safeguards, restoration may fail because of corruption, an incorrect password, insufficient storage, incompatible versions, operating-system behaviour, or another cause. Back up current data before restoring and review the result afterwards.

### 10 Exports and User-Directed Sharing

The app creates reports, invoices, quotes, confirmations, receipts, promotion files, evidence packs, and QR or barcode images from the information provided by the user. Sharing occurs only after the user chooses an export or share action. Depending on the workflow, the app may supply the operating-system share interface with both a file and plain subject or message text, including a job title or reference, marketing contact and offer details, or a generated code's raw source text. The receiving app, service, or person then controls the shared copy and text under its own terms and privacy practices.

Some image evidence is exported through a resized copy with metadata removed. Metadata may remain in other file types. Ordinary exports and WorkProof ZIP evidence packs are not password encrypted unless expressly stated otherwise. Use a secure channel appropriate for the information being shared.

A SHA-256 value can help show whether a file has changed since the hash was calculated. It does not prove that the underlying information was true, that the person who supplied it was authorised, or that a court, employer, tax authority, or other recipient will accept it.

### 11 Advertising and Third-Party Services

The current release may display banner advertisements on selected browsing and reporting screens. It does not currently include interstitial or rewarded ads, subscriptions, in-app purchases, or a paid remove-ads feature.

The reviewed Android configuration uses or is configured to use services such as Google UMP and Google Mobile Ads, Firebase Crashlytics, Firebase Analytics, bundled Google ML Kit barcode scanning, Google Play update and review services, operating-system notifications and biometrics, WhatsApp, and user-selected sharing apps. The production iOS service configuration remains unresolved. These providers operate under their own terms and privacy policies.

Advertising consent controls do not necessarily control Crashlytics, Analytics, ML Kit scanner telemetry, operating-system diagnostics, or information shared by the user. Where required, the app provides a Privacy Choices entry point for advertising settings. The Privacy Policy explains the final release configuration and available choices.

Advertisements are supplied by third parties. Their appearance is not an endorsement, and we do not control every advertised product, statement, destination, or availability.

### 12 No Professional Advice or Regulated Service

WorkProof provides record-keeping and calculation tools only. It does not provide legal, employment, payroll, tax, accounting, financial, immigration, regulatory, or other professional advice.

The app does not:

- Determine whether a person is an employee, worker, contractor, or business
- Determine the legally required wage, overtime, break, deduction, tax, pension, or benefit treatment
- Run payroll, file taxes, remit deductions, or transfer payments
- Guarantee that an invoice, quote, receipt, payslip record, signature, or evidence pack meets local legal requirements
- Decide whether anyone has been underpaid or breached a contract or law

Consult an appropriately qualified adviser or relevant authority when needed.

### 13 Calculations and Generated Documents

Calculations depend on the dates, times, time zone, rates, currency, pricing method, break treatment, overtime settings, rounding rules, tax or VAT inputs, adjustments, payments, and corrections recorded in the app. Incorrect, incomplete, duplicated, outdated, or inconsistent inputs will produce incorrect results.

Expected pay, possible difference, outstanding, net cash, and similar figures are review prompts, not findings or accusations. A local audit entry records activity within the app; it is not an independent audit.

You must review calculations and every export before relying on or sharing it. Compare important results with contracts, payslips, bank records, receipts, official requirements, and professional advice.

### 14 Reminders and Notifications

WorkProof schedules reminders through the device operating system. Delivery may be delayed, changed, suppressed, or lost because of permission settings, battery optimisation, device limits, time-zone or clock changes, restarts, operating-system updates, notification limits, or other conditions.

Reminders are convenience features only. Do not rely on them for emergencies, safety procedures, limitation periods, tax deadlines, contractual notice deadlines, or any event where a missed alert could cause serious loss or harm.

### 15 Acknowledgements and Evidence

The app may store a typed acknowledgement. WorkProof does not verify the identity, age, authority, consent, intention, or control of the device of the person whose name is entered. It does not provide a qualified electronic signature, certificate authority, trusted timestamp, witness, or identity-verification service.

Whether a record or acknowledgement is valid, binding, admissible, or sufficient depends on the circumstances and applicable law. Obtain separate verification or formal signatures when needed.

Evidence files, hashes, timestamps, and audit entries can support personal record-keeping but do not establish authenticity, accuracy, legal ownership, or admissibility by themselves.

### 16 Intellectual Property

The app, software, design, WorkProof branding, documentation, and non-user content are owned by or licensed to `{{COPYRIGHT_OWNER}}` and are protected by applicable intellectual-property laws.

Users may use documents and reports generated from their own records for their intended personal or business purposes. This permission does not transfer ownership of the WorkProof name, logo, software, templates, or other proprietary material. Users remain responsible for having permission to use logos, images, text, and other material they add.

### 17 Availability, Compatibility, and Updates

We aim to keep WorkProof useful and reliable, but we do not promise uninterrupted availability, compatibility with every device, or indefinite support for every operating-system or backup version.

We may provide updates for security, compatibility, legal, or functional reasons. In the reviewed build, any newer version detected by the active store-update gate produces a non-dismissible prompt that blocks continued app use; the gate does not currently distinguish an optional update from a mandatory one. Back up important records regularly and before updating whenever access is available. Store availability, update delivery, and device compatibility also depend on Apple, Google, device manufacturers, and operating-system providers.

> **Owner action — remove before publication:** Ensure users have a practical backup route before a forced gate can block workspace access, or replace the gate with a tested optional-versus-mandatory policy and update this clause.

We may change or discontinue optional network-connected features or future distribution, with reasonable notice where practicable. Discontinuing distribution does not give us access to or responsibility for retrieving local records.

### 18 Ending Use and Suspension

A user may stop using WorkProof at any time and delete the app after preserving any records they need.

There is currently no WorkProof account to suspend. If a user materially breaches these Terms, we may end the licence or restrict access to online components or future updates where technically and legally possible. Where appropriate, we will provide notice and a reasonable opportunity to correct the breach. Immediate action may be taken for serious unlawful, harmful, or security-related misuse.

Ending the licence does not automatically erase local or previously shared data. Provisions that logically need to continue, including ownership, disclaimers, liability limits, and dispute terms, remain effective.

### 19 Disclaimers

To the fullest extent permitted by law, WorkProof is provided “as available.” We do not guarantee that it will be error-free, always available, completely secure, suitable for a particular legal or business purpose, or that any calculation, reminder, backup, restore, export, hash, signature, or record will be accepted by a third party.

No security measure eliminates every risk, and no backup method guarantees recovery.

Nothing in these Terms excludes statutory guarantees or consumer rights that cannot lawfully be excluded or limited.

### 20 Limitation of Liability

> **Owner action — remove before publication:** A qualified lawyer must adapt this limitation-of-liability section to the governing law and the intended consumer and business markets.

To the extent permitted by law, WorkProof is not liable for indirect or consequential loss, or for lost profit, revenue, business opportunity, goodwill, or data arising from use of the app. This exclusion does not apply where the law does not permit it.

Subject to non-excludable rights and liabilities, WorkProof's total aggregate liability arising from the app or these Terms will not exceed the greater of:

1. The amount paid directly to WorkProof for the app during the twelve months before the event giving rise to the claim
2. `{{LIABILITY_CAP_AND_CURRENCY}}`

Nothing limits liability for fraud, fraudulent misrepresentation, death or personal injury caused by negligence, wilful misconduct, gross negligence where applicable, breach of a non-excludable data-protection duty, or another liability that applicable law does not allow us to limit.

### 21 Changes to These Terms

We may update these Terms to reflect legal, security, operational, or product changes. The revised version and effective date will be available at `{{TERMS_URL}}` and `{{IN_APP_TERMS_LOCATION}}`. We will give additional notice for material changes where reasonably practicable.

Changes apply prospectively from their stated effective date. If applicable law requires express consent, we will request it. If a user does not agree to revised Terms, they should stop using the affected version after preserving their records.

### 22 Governing Law and Courts

These Terms are governed by the laws of `{{GOVERNING_LAW}}`, without applying conflict-of-law rules, and disputes are subject to the courts of `{{COURTS_OR_VENUE}}`.

If the user is a consumer, this clause does not remove mandatory protections or any right to bring proceedings in another court that applicable law provides.

### 23 App Store Terms

The Apple App Store or Google Play terms that apply to downloading, installing, updating, billing, and using apps also apply. If an app-store term cannot be changed by these Terms, that store term controls to the extent of the conflict.

Apple, Google, and their affiliates are not responsible for WorkProof's content, local records, calculations, support, or warranties except to the extent required by their own terms or applicable law.

### 24 Contact and General Terms

Questions about the app or these Terms may be sent to:

**Legal owner:** `{{LEGAL_OWNER_NAME}}`  
**Address:** `{{BUSINESS_ADDRESS}}`  
**Support:** `{{SUPPORT_EMAIL}}`  
**Legal and privacy notices:** `{{PRIVACY_CONTACT_EMAIL}}`  
**WhatsApp:** `{{WHATSAPP_SUPPORT_NUMBER}}`

> **Owner action — remove before publication:** The reviewed app is hard-coded to `+8801783109748`. Confirm it or update and test the app, then use the same verified number in the Terms, Contact page, and support workflow.

These Terms, the Privacy Policy, applicable app-store terms, and any additional terms expressly presented for a feature form the agreement concerning WorkProof. If a provision is unenforceable, it will be limited only as much as necessary, and the remaining provisions continue to apply. A failure to enforce a provision once is not a permanent waiver.

## Frequently Asked Questions

### 1. What is WorkProof?

WorkProof is an offline-first work companion. It helps employees and tradespeople plan shifts or jobs, track time and breaks, review pay or business totals, keep evidence, create reports and documents, set local reminders, and make encrypted backup files.

### 2. Do I need an account?

No. The current version has no WorkProof account, login, or cloud workspace. The local profile configures the app on the device.

### 3. Does WorkProof work without internet?

Core record-keeping, time tracking, calculations, evidence handling, reports, code scanning and generation, promotion creation, and local reminders are designed to work offline. In the reviewed Android configuration, internet access is still used for advertising consent and ads, crash diagnostics, Firebase Analytics, limited ML Kit scanner telemetry, app updates and ratings, WhatsApp, email, and other apps selected for sharing.

### 4. What is the difference between Worker and Tradesman mode?

Worker mode is for employer-based work: shifts, workplaces, hours, expected pay, payslips, deductions, and possible pay differences. Tradesman mode is for customer work: jobs, customers, services, quotes, invoices, payments, expenses, and business totals. These labels organise the app; they do not decide a person's legal employment or tax status.

### 5. Can I use both modes or switch later?

Yes. Choose Worker, Tradesman, or Both during setup. Work mode, country, currency, and language can be changed later in profile preferences. Existing monetary records are not automatically converted when the default currency changes.

### 6. Can a team share or synchronise one workspace?

Not in the current version. WorkProof does not provide an account, cloud synchronisation, or live team collaboration. A password-encrypted backup can be restored on a compatible installation, but it is a file transfer rather than live sync.

### 7. How does the timer work?

One work session can run at a time across all jobs and shifts. Clocking in records the start time and uses the selected work item's saved calculation settings. Clock out before starting another session.

### 8. Can I record breaks or correct a time entry?

Yes. Breaks can be paid or unpaid. A completed entry's times can be corrected, but the app requires a reason and records the correction in local audit history. Check the calculation after any correction.

### 9. How are hours and earnings calculated?

The app uses saved clock times, unpaid breaks, pricing type, rate or fixed amount, extra pay, overtime threshold and multiplier, premium multiplier, rounding rule, and currency. Results are only as accurate as the information and settings entered by the user.

### 10. What does possible pay difference mean?

It is a comparison between recorded expected gross pay and recorded received gross pay. It is a prompt to compare WorkProof with the payslip, contract, and original records. It is not a legal finding of underpayment, wrongdoing, or entitlement.

### 11. Can WorkProof manage invoices, payments, and expenses?

Tradesman mode can record customers, jobs, expenses, tax or VAT inputs, invoices, payments, quotes, confirmations, and receipts. It can generate documents for sharing. WorkProof does not process bank or card payments; a payment entry is the user's record of a payment.

### 12. Are WorkProof invoices or pay records official legal, tax, payroll, or accounting documents?

Not automatically. Requirements differ by country, industry, and business type. Users must review numbering, identities, tax, payment status, payroll treatment, and retention requirements and obtain professional advice where necessary.

### 13. What evidence can I add?

Pay Review can accept written notes, selected photos, documents, payslip files, and acknowledgements. The current evidence attachment limit is 25 MB per file. The user chooses which evidence items are included in an export.

### 14. Is all WorkProof data encrypted?

No. Protected attachment files added through the Pay Review evidence path and `.workproof` backup files use authenticated encryption, but the complete workspace is not encrypted by WorkProof. The SQLite database, typed notes and acknowledgements, files created through other paths, ordinary reports and exports, and some derived files are not guaranteed to be encrypted. App Lock is an access gate, not full-database encryption.

### 15. What do hashes and audit history prove?

A SHA-256 hash helps detect whether a file differs from the version that was hashed. Local audit history helps explain activity recorded in the app. Neither proves that the original information was true, identifies who entered it, or guarantees that another organisation will accept it.

### 16. Does WorkProof verify acknowledgements or evidence?

No. A typed acknowledgement records what was entered on the device. WorkProof does not verify identity, authority, consent, intention, the truth of supporting material, or legal validity and does not provide a certified or qualified electronic signature.

### 17. How do I back up or move my records?

Open **Settings → Backup and Restore**, create a manual backup, choose a password of at least ten characters, and save the `.workproof` file somewhere you control. On a compatible installation, choose that file and enter its password to restore it. WorkProof does not upload the backup to its own cloud.

### 18. What happens if I forget my backup password or App Lock PIN?

WorkProof does not store or recover a manual backup password, so the backup cannot be opened without it. The current app also has no forgotten-PIN reset flow. Biometric unlock does not reveal or reset the PIN. Keep credentials safely and maintain a tested backup.

### 19. What is the difference between Merge and Replace restore?

Merge keeps the current workspace and adds compatible records that are not already present. Replace substitutes the current database and evidence with the backup. Before either operation, WorkProof creates a local encrypted recovery snapshot and attempts rollback if validation fails. Review the restored workspace afterwards.

### 20. How do App Lock and biometrics work?

App Lock uses a 4–8 digit PIN whose verifier is salted and held through device secure storage. Optional biometric unlock asks the operating system to authenticate the user; WorkProof does not receive the fingerprint or face template. App Lock can relock after the app has been in the background, but it does not encrypt the database or exported files.

### 21. How long are records kept?

Local records, soft-deleted rows, generated files, and manual backups may remain until the user removes the applicable storage or files. The app keeps up to three rotating local recovery snapshots. Third-party Crashlytics, Analytics, ML Kit, advertising, store, hosting, and communication retention is explained in the Privacy Policy and the providers' notices.

### 22. How do I delete my data?

Certain records can be deleted through their app controls, although some deletions remain as hidden local rows for history or relationship integrity. The current version has no single Erase All Data action. To remove the active local workspace, use Android's clear-app-storage function or delete the app on iOS, then separately delete backups and exports saved elsewhere. Do not rely on iOS Offload App because it can preserve app data. Copies already shared with other people or services cannot be recalled by WorkProof.

### 23. Are exports encrypted?

Ordinary reports, job documents, promotion files, generated QR or barcode PNGs, and PDF or ZIP evidence packs are not password encrypted. Some share flows also include unencrypted plain subject or message text, such as a job title or reference, marketing contact and offer details, or a generated code's raw source text. A `.workproof` backup is encrypted. Store and send ordinary exports only through channels appropriate for their contents.

### 24. Does WorkProof automatically upload or share my work records?

WorkProof does not automatically upload the local work database, customer directory, evidence files, camera input, or decoded scan values to a WorkProof backend. Export and share actions open the device's sharing system, and the user chooses a destination. Crashlytics, Firebase Analytics in the current Android configuration, Android ML Kit scanner telemetry, advertising, consent, and store services separately process the diagnostic, usage, identifier, consent, advertising, and store information described in the Privacy Policy.

### 25. Is WorkProof free, and are there subscriptions?

The current app contains no subscription, in-app purchase, Pro entitlement, or remove-ads purchase. The app-store listing will show any download price that applies. Limited banner advertising may support the app, and a mobile provider or third-party service may charge for its own data or services.

### 26. Where are advertisements shown?

The current design limits banner advertisements to selected Dashboard, Work, Contacts or Customers, Calendar, and Reports screens. Ads are not intended for Pay or Pay Protection, Work Records, editors, evidence, Backup and Restore, App Lock, or export and share flows.

### 27. Can I change advertising privacy choices?

Where Google's consent service requires a privacy-options entry point, open **Settings → Privacy Choices**. Refusing or changing consent does not necessarily remove all advertising: non-personalised, limited, or technical ad delivery may still occur where lawful. Personalised advertising is used only when the necessary consent or another valid permission exists.

### 28. Does WorkProof use Crashlytics or Analytics?

The reviewed Android configuration uses Firebase Crashlytics for fatal crash and diagnostic reports and includes Firebase Analytics. Firebase is initialised at startup and automatic Analytics collection is not explicitly disabled, so Analytics must be treated as enabled there. Crash reports may include session and application-state context and automatic Analytics breadcrumbs. The iOS Firebase and dependency configuration is unresolved and must be verified before iOS availability is claimed. WorkProof does not intentionally attach the local work database or evidence files to diagnostics or Analytics events. See the Privacy Policy for the final production controls and retention.

### 29. Why does WorkProof request camera permission?

Camera permission is used for on-device QR and barcode scanning. WorkProof does not intentionally upload camera input or decoded values. On Android, the bundled Google ML Kit scanner may send limited device, app, installation, performance, configuration, feature-version, feature input/output-size, event, and error information to Google for diagnostics and usage analytics; Google states that camera input and decoded values remain on-device. A decoded value can also leave the app when the user copies or shares it.

### 30. Why does WorkProof request notification or biometric permission?

Notification permission is used for reminders configured by the user. Biometric permission is used only when biometric App Lock is enabled. Optional permissions can be denied, but the related feature will not work.

### 31. Can I rely on reminders arriving exactly on time?

No. Reminders are scheduled locally, but the operating system may delay or suppress them because of battery rules, permissions, scheduling limits, restarts, clock changes, or time zones. Do not use WorkProof as the only reminder for an emergency, safety task, or legal deadline.

### 32. Which platforms and languages are targeted?

The project targets Android 7.0 or later. An iPhone and iPad release is planned, but its minimum OS and availability will be announced only after a production build and live App Store listing are verified. The interface offers English, Bangla, Hindi, Japanese, Polish, Urdu, Romanian, Irish, Yoruba, and Simplified Chinese. English and Bangla contain the fullest native copy; the other eight locales are partially translated and currently contain substantial English fallback text.

### 33. Which currencies are available, and how is the time zone handled?

The current currency catalogue includes GBP, EUR, INR, JPY, BDT, and USD. Current job and shift editors use the device's IANA time zone; they do not expose a separate time-zone picker. Changing the default currency does not convert older records.

### 34. Can support see or restore my workspace?

Normally, no. There is no WorkProof account or cloud workspace for support to open. Support cannot recover a forgotten backup password. A user should provide only the minimum information needed for a support request and should never send an App Lock PIN or backup password.

### 35. How do I get support?

Open **Settings → Send Feedback on WhatsApp**. No message is delivered to WorkProof support until the user presses Send; opening the external link may disclose the destination number, prefilled draft, and technical request data to WhatsApp or Meta. Support is also available at `{{SUPPORT_EMAIL}}`.

## SEO Metadata

### Home Page

**SEO title:** WorkProof | Offline Work, Time, Pay and Job Records  
**Meta description:** Plan jobs and shifts, track time, review pay and income, keep evidence, and create reports offline with WorkProof. No account required.

### Features Page

**SEO title:** WorkProof Features | Jobs, Shifts, Pay, Evidence and Reports  
**Meta description:** Explore WorkProof features for employees and tradespeople, including time tracking, invoices, pay review, evidence, reports, reminders, and backup.

### About Page

**SEO title:** About WorkProof | Track Work and Keep Better Records  
**Meta description:** Learn how WorkProof helps employees and self-employed tradespeople plan work, track time, review money, and keep useful records on-device.

### FAQ Page

**SEO title:** WorkProof FAQ | Accounts, Offline Use, Privacy and Backup  
**Meta description:** Find answers about WorkProof time tracking, offline use, pay calculations, security, backups, exports, advertising, privacy, and support.

### Privacy Policy Page

**SEO title:** WorkProof Privacy Policy  
**Meta description:** Learn how WorkProof stores local work records and handles diagnostics, advertising, permissions, backups, exports, retention, and privacy choices.

### Terms Page

**SEO title:** WorkProof Terms and Conditions  
**Meta description:** Read the rules, responsibilities, limitations, and legal terms that apply when using the WorkProof application and website.

### Social Sharing Description

WorkProof helps employees and tradespeople plan work, track time, review pay or business income, and keep useful proof in one offline-first workspace.

## Owner Pre-Publication Checklist

This section is not public website copy. Complete it before publishing the website or submitting the app.

### Legal Identity and Contact Details

- [ ] Add the full legal owner or sole-trader name.
- [ ] Add entity type, incorporation country, and registration number if applicable.
- [ ] Add a complete business and postal address.
- [ ] Add and monitor support, privacy, and legal email addresses.
- [ ] Confirm that WhatsApp number `+8801783109748` is authorised and appropriate for public support.
- [ ] Choose the minimum user age for every launch market.
- [ ] Choose governing law and courts after checking mandatory consumer protections.
- [ ] Set a counsel-approved liability cap.
- [ ] Add the effective date, last-updated date, Terms version, and copyright owner and year.
- [ ] Identify the applicable supervisory authority, response period, EU representative, UK representative, and Data Protection Officer where required.
- [ ] Obtain qualified legal review in every intended launch market.

### Website and Public Links

- [ ] Add the website domain and final Privacy Policy and Terms URLs.
- [ ] Add live Google Play and Apple App Store links.
- [ ] Confirm the website hosting provider and log-retention period.
- [ ] Identify the support/privacy email provider, its security and retention settings, and any international-transfer terms; fill `{{EMAIL_SERVICE_PROVIDER}}` consistently.
- [ ] Keep the initial website static and without non-essential cookies unless the Policy and consent implementation are updated.
- [ ] If adding a contact form, analytics, pixels, advertising, newsletter, or account, document its fields, provider, purpose, legal basis, retention, and user choices before enabling it.
- [ ] Add accessible Privacy Policy and Terms links in app onboarding and Settings.
- [ ] Decide whether explicit Terms acceptance is required and record the accepted version if implemented.

### Product Identity and Release Metadata

- [ ] Reconcile `README.md` version `0.16.1+19` with `pubspec.yaml` version `0.0.1+1`.
- [ ] Replace the iOS placeholder bundle identifier `com.example.tradesmanJobManager`; Android currently uses `com.workproof.workhelper`.
- [ ] Update iOS test identifiers, Firebase, AdMob, App Store Connect, store URLs, and update lookup to match the final bundle identifier.
- [ ] Reconcile the project and Podfile iOS 13 declaration with the current Firebase Core, Analytics, and Crashlytics plugins' iOS 15 minimum; regenerate the Pod lockfile and publish only the deployment target proved by a clean production archive.
- [ ] Supply and test the final numeric Apple App Store ID and country setting.
- [ ] Ensure the legal publisher name in Apple and Google listings matches the legal pages.
- [ ] Verify Android and iOS production release builds rather than relying on debug configuration.
- [ ] Describe iOS as a target, not a supported or available platform, until the final identity, Firebase configuration, production archive, and live listing are verified.
- [ ] Complete and independently review the eight partially translated, English-heavy locales before describing them as fully translated.

### Data Retention and Deletion

- [ ] Define retention periods for active records, soft-deleted rows, audit logs, report history, generated documents, manual backups, support messages, diagnostics, Analytics, and advertising data.
- [ ] Build and test an Erase All Data function before claiming that complete in-app deletion is available.
- [ ] Ensure erasure covers the SQLite database and sidecar files, evidence, signatures, reports, documents, exports, marketing files, backups, recovery snapshots, preferences, drafts, notifications, PIN verifier, evidence key, and recovery secret.
- [ ] Explain which external backups, shared files, and provider-held information cannot be recalled.
- [ ] Distinguish iOS Offload App from Delete App.
- [ ] Confirm whether sensitive iOS files are included in iCloud or device backups and configure exclusions where required.
- [ ] Add and verify explicit Android `dataExtractionRules` for cloud backup and device-to-device transfer, then test signed release builds on Android 12 or later and representative manufacturer devices; do not rely only on `allowBackup="false"`.
- [ ] Create a privacy-rights request process for support and third-party SDK information.

### Encryption and App Lock

- [ ] Decide whether to encrypt the complete SQLite database. Until then, never describe the whole workspace as encrypted.
- [ ] Disclose that ordinary PDFs, CSVs, ZIP packs, job documents, reports, and marketing exports are not password encrypted.
- [ ] Fix drawn job-signature storage so signatures consistently use the encrypted evidence path and can be safely decrypted for display and export.
- [ ] Fix the unlock PIN field so PIN digits are obscured by default.
- [ ] Design and document a safe forgotten-PIN process.
- [ ] Test key lifecycle across deletion, reinstall, device migration, biometric changes, backup, and restore.
- [ ] Verify temporary decrypted staging files are cleaned after success, failure, cancellation, and interruption.
- [ ] Decide whether source-device documents-directory path metadata is necessary in encrypted backup manifests; remove it if unnecessary or keep its disclosure aligned across the Policy, Terms, and restore UI.
- [ ] Delete generated QR and barcode PNGs from temporary storage after sharing or add a tested retention policy; inventory and test every share payload, including generated-code source text, marketing contact and offer text, and job title or reference text.
- [ ] Describe hashes only as integrity checks, never as proof of identity, authenticity, or truth.

### Firebase and Diagnostics

- [ ] Resolve the misleading `main.dart` comment that says Firebase is not initialised there even though `Firebase.initializeApp()` runs before the app UI.
- [ ] Decide whether Firebase Analytics is needed and treat automatic collection as enabled until release testing proves otherwise.
- [ ] If Analytics is disabled, remove it or disable it in both native configuration and runtime. If enabled, document events, identifiers, purposes, legal basis, retention, advertising integration, and user controls.
- [ ] Decide whether Crashlytics is automatic, opt-in, or opt-out. The current build records fatal errors without an in-app control.
- [ ] Confirm that customer names, work titles, notes, file paths, code values, or other user content cannot enter exception messages, breadcrumbs, custom keys, or logs.
- [ ] Inspect Crashlytics session identifiers, relevant application state, and automatic Analytics breadcrumbs in the production console and disclose or suppress any unintended user-action context.
- [ ] Do not imply that Google's UMP advertising consent also controls Crashlytics or Analytics unless that connection is explicitly implemented and verified.
- [ ] Add and test the final iOS Firebase configuration or make Firebase startup safely optional.
- [ ] Align the Privacy Policy and store declarations with verified production network behaviour.

### Android ML Kit Scanner Disclosure

- [ ] Confirm the final Android binary still bundles Google ML Kit barcode scanning and re-check Google's current data disclosure before release.
- [ ] Declare the ML Kit device and app information, per-installation identifiers, performance metrics, API configuration, feature version, feature input and output sizes, and event or error telemetry wherever required, including Google Play Data Safety.
- [ ] Preserve the narrower, verified statement that barcode input and decoded values remain on-device; do not describe the complete scanner feature as producing no network data.
- [ ] Confirm the applicable legal basis, vendor role, retention position, international-transfer disclosure, and rights process for ML Kit telemetry.
- [ ] Re-test scanner network behaviour from the signed production Android build.

### Advertising and Consent

- [ ] Create production AdMob apps and banner units for the final Android and iOS identifiers.
- [ ] Supply `ADMOB_APP_ID`, `ADMOB_ANDROID_BANNER_ID`, and `ADMOB_IOS_BANNER_ID` in release configuration and ensure sample IDs do not reach production.
- [ ] Configure and publish UMP messages for every launch region.
- [ ] Test first launch, consent denial, acceptance, withdrawal, expiry, error, offline launch, and changed choices.
- [ ] Keep Privacy Choices visible whenever UMP requires an entry point.
- [ ] Decide personalised, non-personalised, limited-ad, and restricted-data-processing behaviour.
- [ ] Align minimum-age rules with UMP under-age-of-consent and Mobile Ads child-directed-treatment settings. The current code sets neither.
- [ ] Determine whether advertising disclosures amount to sale, sharing, or targeted advertising under relevant United States laws and provide any required opt-out.
- [ ] Confirm that the final ad placements match the public FAQ and that sensitive, edit, backup, security, and export screens remain ad-free.

### Apple and Google Store Privacy Work

- [ ] Add or validate an accurate iOS `PrivacyInfo.xcprivacy` file and inspect Xcode's aggregate privacy report.
- [ ] Make and document the App Tracking Transparency decision. Add `NSUserTrackingUsageDescription` and request permission before tracking if required.
- [ ] Add and maintain current SKAdNetwork identifiers if the chosen AdMob configuration needs them.
- [ ] Complete Apple App Privacy details from the final binary and SDK manifests.
- [ ] Complete Google Play Data Safety answers for advertising, identifiers, crash logs, Analytics, ML Kit scanner telemetry, and support information.
- [ ] Compare declarations with production-binary network tests and current vendor documentation.
- [ ] Review vendor data-processing terms, roles, international transfers, and retention settings.

### Calculation and Evidence Claims

- [ ] Have relevant advisers review pay, overtime, deduction, tax, VAT, invoice, receipt, and retention terminology for launch markets.
- [ ] Ensure generated documents tell users to verify important amounts and details.
- [ ] Keep employer-pay records separate from customer-business finances in reports.
- [ ] Test currency fraction digits, rounding, daylight-saving changes, cross-time-zone work, corrections, paid and unpaid breaks, fixed prices, overtime, and negative adjustments.
- [ ] Keep signatures and acknowledgements labelled as unverified.
- [ ] Do not market WorkProof as proof of legal entitlement, guaranteed wage compliance, certified evidence, certified electronic signature, payroll software, or professional advice.

### Final Verification

- [ ] Run formatting, static analysis, automated tests, Android release build, and iOS archive with production-like configuration.
- [ ] Test first launch online and offline, denied permissions, denied ad consent, Firebase outage, AdMob no-fill, low storage, restart, time-zone change, and update failure.
- [ ] Test backup, forgotten-password messaging, wrong password, damaged archive, Merge, Replace, rollback, and restore across supported versions.
- [ ] Test the active update gate. If it remains non-dismissible for every detected update, provide a usable pre-gate backup route and keep the website and Terms explicit; otherwise verify the replacement optional-versus-mandatory policy.
- [ ] Test data erasure independently on Android and iOS and inspect app files, secure storage, pending notifications, and recovery snapshots afterwards.
- [ ] Confirm support procedures do not ask users to disclose unnecessary sensitive records, App Lock PINs, or backup passwords.
- [ ] Read the final website, Privacy Policy, Terms, FAQ, store declarations, and in-app text side by side immediately before release.

## Placeholder Register

Replace or resolve all of the following before publication:

- `{{ADDITIONAL_VENDORS}}`
- `{{ANALYTICS_LEGAL_BASIS}}`
- `{{APPLE_APP_STORE_URL}}`
- `{{APPLICABLE_RESPONSE_PERIOD}}`
- `{{BUSINESS_ADDRESS}}`
- `{{CHILD_PRIVACY_AND_ADS_CONFIGURATION}}`
- `{{COPYRIGHT_OWNER}}`
- `{{COPYRIGHT_YEAR}}`
- `{{COURTS_OR_VENUE}}`
- `{{CRASHLYTICS_LEGAL_BASIS}}`
- `{{CURRENT_RELEASE_VERSION}}`
- `{{DATA_PROTECTION_OFFICER_DETAILS}}`
- `{{EMAIL_SERVICE_PROVIDER}}`
- `{{EFFECTIVE_DATE}}`
- `{{EU_REPRESENTATIVE_DETAILS}}`
- `{{FIREBASE_ANALYTICS_RETENTION_PERIOD}}`
- `{{GLOBAL_PRIVACY_CONTROL_POSITION}}`
- `{{GOOGLE_PLAY_URL}}`
- `{{GOVERNING_LAW}}`
- `{{INTERNATIONAL_TRANSFER_DETAILS}}`
- `{{IN_APP_POLICY_LOCATION}}`
- `{{IN_APP_TERMS_LOCATION}}`
- `{{IOS_BACKUP_STATUS}}`
- `{{LAST_UPDATED_DATE}}`
- `{{LEGAL_ENTITY_DETAILS}}`
- `{{LEGAL_OWNER_NAME}}`
- `{{LIABILITY_CAP_AND_CURRENCY}}`
- `{{LIMITED_ADS_LEGAL_BASIS}}`
- `{{MINIMUM_USER_AGE}}`
- `{{ML_KIT_LEGAL_BASIS}}`
- `{{PRIVACY_CONTACT_EMAIL}}`
- `{{PRIVACY_POLICY_URL}}`
- `{{RELEVANT_AUTHORITY_AND_LINK}}`
- `{{SUPPORT_COMMUNICATION_RETENTION_PERIOD}}`
- `{{SUPPORT_EMAIL}}`
- `{{SUPPORT_RESPONSE_TIME}}`
- `{{TERMS_URL}}`
- `{{TERMS_VERSION}}`
- `{{UK_REPRESENTATIVE_DETAILS}}`
- `{{US_STATE_PRIVACY_DISCLOSURE}}`
- `{{WHATSAPP_SUPPORT_NUMBER}}`
- `{{WHATSAPP_SUPPORT_URL}}`
- `{{WEBSITE_DOMAIN}}`
- `{{WEBSITE_HOSTING_PROVIDER}}`

The register is intentionally exhaustive. A verification command should produce no placeholder used in the document body that is absent from this list.

## Legal and Technical Reference Links

- [Firebase Privacy and Security](https://firebase.google.com/support/privacy/)
- [Firebase Data Processing and Security Terms](https://firebase.google.com/terms/data-processing-terms)
- [Firebase Analytics Data Collection Configuration](https://firebase.google.com/docs/analytics/configure-data-collection)
- [Google Analytics Automatically Collected Events](https://support.google.com/analytics/answer/9234069)
- [Google ML Kit Android Data Disclosure](https://developers.google.com/ml-kit/android-data-disclosure)
- [Google Mobile Ads Android Data Disclosure](https://developers.google.com/admob/android/privacy/play-data-disclosure)
- [Google Mobile Ads iOS Data Disclosure](https://developers.google.com/admob/ios/privacy/data-disclosure)
- [Google UMP for Flutter](https://developers.google.com/admob/flutter/privacy)
- [Google Privacy Policy](https://policies.google.com/privacy)
- [Google Play Data Safety Guidance](https://support.google.com/googleplay/android-developer/answer/10787469)
- [Android Backup and Device-Transfer Behaviour](https://developer.android.com/identity/data/autobackup)
- [Apple Privacy Policy](https://www.apple.com/legal/privacy/)
- [Apple Privacy Manifest Documentation](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files)
- [Apple App Tracking Transparency](https://developer.apple.com/documentation/apptrackingtransparency)
- [WhatsApp Privacy Policy](https://www.whatsapp.com/legal/privacy-policy)

