import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

export 'arb_fallback_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
