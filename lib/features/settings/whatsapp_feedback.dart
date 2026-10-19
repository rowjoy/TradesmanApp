import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

typedef WhatsAppFeedbackLauncher =
    Future<bool> Function(Uri uri, {required LaunchMode mode});

final whatsAppFeedbackLauncherProvider = Provider<WhatsAppFeedbackLauncher>(
  (ref) => launchUrl,
);

abstract final class WhatsAppFeedback {
  static const contactNumber = '+8801783109748';

  /// Opens an editable draft; the user chooses whether to send it in WhatsApp.
  static Future<bool> open(
    WhatsAppFeedbackLauncher launcher, {
    required String message,
  }) async {
    final uri = Uri.https('wa.me', contactNumber.substring(1), {
      'text': message,
    });
    try {
      return await launcher(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
