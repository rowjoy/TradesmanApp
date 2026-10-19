import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tradesman_manager/core/providers/app_metadata_provider.dart';
import 'package:tradesman_manager/features/app_update/application/app_update_controller.dart';
import 'package:tradesman_manager/features/app_update/domain/app_update_models.dart';
import 'package:tradesman_manager/features/app_update/presentation/app_update_coordinator.dart';
import 'package:tradesman_manager/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('defers checks until presentation is enabled', (tester) async {
    final gateway = _CoordinatorGateway();
    final gateKey = GlobalKey<_UpdateGateState>();
    addTearDown(gateway.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appUpdateGatewayProvider.overrideWithValue(gateway),
          appMetadataProvider.overrideWith(
            (ref) async => const AppMetadata(appName: 'WorkProof', packageName: 'com.workproof.workhelper', version: '1.0.0', buildNumber: '10'),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: _UpdateGate(key: gateKey),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(gateway.checkCount, 0);
    expect(find.byType(AlertDialog), findsNothing);

    gateKey.currentState!.enable();
    await tester.pumpAndSettle();

    expect(gateway.checkCount, 1);
    expect(find.byType(AlertDialog), findsOneWidget);
  });
}

class _UpdateGate extends StatefulWidget {
  const _UpdateGate({super.key});

  @override
  State<_UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<_UpdateGate> {
  bool _enabled = false;

  void enable() => setState(() => _enabled = true);

  @override
  Widget build(BuildContext context) => AppUpdateCoordinator(
    enabled: _enabled,
    child: const Scaffold(body: SizedBox.expand()),
  );
}

class _CoordinatorGateway implements AppUpdateGateway {
  int checkCount = 0;

  @override
  AppUpdatePlatform get platform => AppUpdatePlatform.ios;

  @override
  Stream<AppUpdateInstallStatus> get installStatuses => const Stream<AppUpdateInstallStatus>.empty();

  @override
  Future<AppUpdateOffer?> checkForUpdate(AppUpdateCheckRequest request) async {
    checkCount++;
    return AppUpdateOffer(
      platform: platform,
      flow: AppUpdateFlow.storeRedirect,
      installedVersion: request.installedVersion,
      availableVersion: '1.1.0',
      isMandatory: false,
      storeUrl: Uri.https('apps.apple.com', '/app/id123'),
    );
  }

  @override
  Future<AppUpdateActionResult> completeUpdate() async => AppUpdateActionResult.unsupported;

  @override
  Future<AppUpdateActionResult> startUpdate(AppUpdateOffer offer) async => AppUpdateActionResult.accepted;

  void dispose() {}
}
