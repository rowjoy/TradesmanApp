import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/about/domain/app_feature.dart';
import '../../features/about/presentation/about_app_screen.dart';
import '../../features/about/presentation/app_feature_catalog.dart';
import '../../features/ads/application/banner_overlay_controller.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/backup/presentation/backup_restore_screen.dart';
import '../../features/code_tools/presentation/code_studio_screen.dart';
import '../../features/jobs/add_job_screen.dart';
import '../../features/jobs/job_workspace_screen.dart';
import '../../features/marketing/presentation/marketing_studio_screen.dart';
import '../../features/money/presentation/screens/money_overview_screen.dart';
import '../../features/notifications/presentation/notification_settings_screen.dart';
import '../../features/onboarding/domain/entities/local_profile.dart'
    show WorkMode;
import '../../features/onboarding/presentation/controllers/onboarding_controller.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/startup_screen.dart';
import '../../features/pay_protection/presentation/screens/evidence_editor_screen.dart';
import '../../features/pay_protection/presentation/screens/pay_period_detail_screen.dart';
import '../../features/pay_protection/presentation/screens/pay_period_editor_screen.dart';
import '../../features/pay_protection/presentation/screens/payslip_editor_screen.dart';
import '../../features/proof/presentation/screens/proof_overview_screen.dart';
import '../../features/security/presentation/security_settings_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/settings/profile_preferences_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/showcase/presentation/guided_showcase.dart';
import '../../features/time_tracking/clock_screen.dart';
import '../../features/time_tracking/time_entry_model.dart';
import '../../features/work/domain/work_models.dart';
import '../../features/work/presentation/screens/people_directory_screen.dart';
import '../../features/work/presentation/screens/people_editor_screens.dart';
import '../../features/work/presentation/screens/shift_editor_screen.dart';
import '../../features/work/presentation/screens/work_calendar_screen.dart';
import '../../features/work/presentation/screens/work_hub_screen.dart';
import '../../l10n/l10n.dart';
import 'app_routes.dart';
import 'app_shell.dart';
import 'route_guard.dart';

export 'app_routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen(
      onboardingControllerProvider.select(
        (value) => (
          loading: value.isLoading,
          hasError: value.hasError,
          completed: value.asData?.value?.onboardingCompleted ?? false,
        ),
      ),
      (_, __) => notifyListeners(),
    );
  }

  final Ref _ref;
}

final _routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_routerNotifierProvider);
  final bannerOverlayController = ref.watch(
    bannerOverlayControllerProvider.notifier,
  );
  List<NavigatorObserver> bannerObservers() => [
    bannerOverlayController.createObserver(),
  ];

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    observers: bannerObservers(),
    initialLocation: AppRoutes.startup,
    refreshListenable: notifier,
    redirect: (context, state) {
      final onboarding = ref.read(onboardingControllerProvider);
      final profile = onboarding.asData?.value;
      return workProofRedirect(
        isLoading: onboarding.isLoading,
        hasError: onboarding.hasError,
        onboardingCompleted: profile?.onboardingCompleted ?? false,
        location: state.matchedLocation,
      );
    },
    routes: [
      GoRoute(
        path: AppRoutes.startup,
        builder: (context, state) => const StartupScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            observers: bannerObservers(),
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            observers: bannerObservers(),
            routes: [
              GoRoute(
                path: AppRoutes.work,
                builder: (context, state) => _featureGuide(
                  context: context,
                  screenId: 'work_hub',
                  featureId: AppFeatureId.workPlanning,
                  child: const WorkHubScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'jobs/new',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const AddJobScreen(),
                  ),
                  GoRoute(
                    path: 'jobs/:jobId/edit',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) =>
                        AddJobScreen(jobId: state.pathParameters['jobId']!),
                  ),
                  GoRoute(
                    path: 'jobs/:jobId/workspace',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => _screenGuide(
                      screenId: 'job_workspace',
                      title: context.l10n.manageJobTitle,
                      description: context.l10n.manageJobDescription,
                      child: JobWorkspaceScreen(
                        jobId: state.pathParameters['jobId']!,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'jobs/:jobId',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => ClockScreen(
                      workItem: WorkItemReference.job(
                        state.pathParameters['jobId']!,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'shifts/new',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => _screenGuide(
                      screenId: 'shift_editor',
                      title: context.l10n.newShift,
                      description:
                          '${context.l10n.scheduleTitle} · ${context.l10n.pricingLabel} · '
                          '${context.l10n.saveShift}',
                      child: const ShiftEditorScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'shifts/:shiftId/edit',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => _screenGuide(
                      screenId: 'shift_editor',
                      title: context.l10n.editShift,
                      description:
                          '${context.l10n.scheduleTitle} · ${context.l10n.pricingLabel} · '
                          '${context.l10n.saveShift}',
                      child: ShiftEditorScreen(
                        shiftId: state.pathParameters['shiftId']!,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'shifts/:shiftId',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => ClockScreen(
                      workItem: WorkItemReference.shift(
                        state.pathParameters['shiftId']!,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            observers: bannerObservers(),
            routes: [
              GoRoute(
                path: AppRoutes.money,
                builder: (context, state) {
                  const screen = MoneyOverviewScreen();
                  final mode = ref.read(currentProfileProvider)?.workMode;
                  if (mode != WorkMode.tradesman) return screen;
                  return _featureGuide(
                    context: context,
                    screenId: 'business_money',
                    featureId: AppFeatureId.payAndIncome,
                    child: screen,
                  );
                },
                routes: [
                  GoRoute(
                    path: 'new',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => _screenGuide(
                      screenId: 'pay_period_editor',
                      title: context.l10n.m05StartAPayPeriod,
                      description:
                          '${context.l10n.m05Expected} · ${context.l10n.m05Received} · '
                          '${context.l10n.saveLabel}',
                      child: const PayPeriodEditorScreen(),
                    ),
                  ),
                  GoRoute(
                    path: ':payPeriodId',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => _screenGuide(
                      screenId: 'pay_period_detail',
                      title: context.l10n.m05ReviewEvidenceExport,
                      description:
                          '${context.l10n.m05Expected} · ${context.l10n.m05Received} · '
                          '${context.l10n.exportPdf}',
                      child: PayPeriodDetailScreen(
                        payPeriodId: state.pathParameters['payPeriodId']!,
                      ),
                    ),
                    routes: [
                      GoRoute(
                        path: 'payslip',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) => _screenGuide(
                          screenId: 'payslip_editor',
                          title: context.l10n.m05Received,
                          description:
                              '${context.l10n.m05ReviewMetadata} · ${context.l10n.saveLabel}',
                          child: PayslipEditorScreen(
                            payPeriodId: state.pathParameters['payPeriodId']!,
                          ),
                        ),
                      ),
                      GoRoute(
                        path: 'evidence/new',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) => _screenGuide(
                          screenId: 'evidence_editor',
                          title: context.l10n.evidenceEncryptionTitle,
                          description:
                              '${context.l10n.evidenceEncryptionDescription} '
                              '${context.l10n.saveLabel}',
                          child: EvidenceEditorScreen(
                            payPeriodId: state.pathParameters['payPeriodId']!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            observers: bannerObservers(),
            routes: [
              GoRoute(
                path: AppRoutes.proof,
                builder: (context, state) => _featureGuide(
                  context: context,
                  screenId: 'proof_overview',
                  featureId: AppFeatureId.workRecords,
                  child: const ProofOverviewScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            observers: bannerObservers(),
            routes: [
              GoRoute(
                path: AppRoutes.more,
                builder: (context, state) => _screenGuide(
                  screenId: 'settings',
                  title: context.l10n.settings,
                  description:
                      '${context.l10n.regionLanguageTitle} · '
                      '${context.l10n.marketingStudioTitle} · '
                      '${context.l10n.offlineNotificationsTitle} · '
                      '${context.l10n.backupRestoreTitle}',
                  child: const SettingsScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'notifications',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => _screenGuide(
                      screenId: 'notification_settings',
                      title: context.l10n.offlineNotificationsTitle,
                      description:
                          '${context.l10n.offlineNotificationsDescription} · '
                          '${context.l10n.savedOnDevice}',
                      child: const NotificationSettingsScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'preferences',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => _screenGuide(
                      screenId: 'profile_preferences',
                      title: context.l10n.regionLanguageTitle,
                      description:
                          '${context.l10n.appLanguageLabel} · '
                          '${context.l10n.defaultCurrencyLabel}',
                      child: const ProfilePreferencesScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'security',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => _screenGuide(
                      screenId: 'security_settings',
                      title: context.l10n.securityPrivacyTitle,
                      description:
                          '${context.l10n.appLockTitle} · '
                          '${context.l10n.evidenceEncryptionTitle}',
                      child: const SecuritySettingsScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'backup-restore',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => _screenGuide(
                      screenId: 'backup_restore',
                      title: context.l10n.backupRestoreTitle,
                      description: context.l10n.backupRestoreSubtitle,
                      child: const BackupRestoreScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'marketing-studio',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => _featureGuide(
                      context: context,
                      screenId: 'marketing_studio',
                      featureId: AppFeatureId.promotions,
                      child: const MarketingStudioScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'code-studio',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => _featureGuide(
                      context: context,
                      screenId: 'code_studio',
                      featureId: AppFeatureId.codeTools,
                      child: const CodeStudioScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'about',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const AboutAppScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.people,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => _featureGuide(
          context: context,
          screenId: 'people_directory',
          featureId: AppFeatureId.contacts,
          child: PeopleDirectoryScreen(
            flow: state.uri.queryParameters['flow'] == WorkFlow.worker.name
                ? WorkFlow.worker
                : WorkFlow.tradesman,
          ),
        ),
        routes: [
          GoRoute(
            path: 'employers/new',
            builder: (context, state) => _screenGuide(
              screenId: 'employer_editor',
              title: context.l10n.newEmployer,
              description:
                  '${context.l10n.contactName} · ${context.l10n.paySchedule} · '
                  '${context.l10n.saveLabel}',
              child: const EmployerEditorScreen(),
            ),
          ),
          GoRoute(
            path: 'employers/:id/edit',
            builder: (context, state) => _screenGuide(
              screenId: 'employer_editor',
              title: context.l10n.editEmployer,
              description:
                  '${context.l10n.contactName} · ${context.l10n.paySchedule} · '
                  '${context.l10n.saveLabel}',
              child: EmployerEditorScreen(
                employerId: state.pathParameters['id']!,
              ),
            ),
          ),
          GoRoute(
            path: 'workplaces/new',
            builder: (context, state) => _screenGuide(
              screenId: 'workplace_editor',
              title: context.l10n.newWorkplace,
              description:
                  '${context.l10n.addressLabel} · ${context.l10n.saveLabel}',
              child: const WorkplaceEditorScreen(),
            ),
          ),
          GoRoute(
            path: 'workplaces/:id/edit',
            builder: (context, state) => _screenGuide(
              screenId: 'workplace_editor',
              title: context.l10n.editWorkplace,
              description:
                  '${context.l10n.addressLabel} · ${context.l10n.saveLabel}',
              child: WorkplaceEditorScreen(
                workplaceId: state.pathParameters['id']!,
              ),
            ),
          ),
          GoRoute(
            path: 'customers/new',
            builder: (context, state) => _screenGuide(
              screenId: 'customer_editor',
              title: context.l10n.newCustomer,
              description:
                  '${context.l10n.customerName} · ${context.l10n.emailLabel} · '
                  '${context.l10n.saveLabel}',
              child: const CustomerEditorScreen(),
            ),
          ),
          GoRoute(
            path: 'customers/:id/edit',
            builder: (context, state) => _screenGuide(
              screenId: 'customer_editor',
              title: context.l10n.editCustomer,
              description:
                  '${context.l10n.customerName} · ${context.l10n.emailLabel} · '
                  '${context.l10n.saveLabel}',
              child: CustomerEditorScreen(
                customerId: state.pathParameters['id']!,
              ),
            ),
          ),
          GoRoute(
            path: 'services/new',
            builder: (context, state) => _screenGuide(
              screenId: 'service_editor',
              title: context.l10n.newService,
              description:
                  '${context.l10n.pricingLabel} · ${context.l10n.saveLabel}',
              child: const ServiceEditorScreen(),
            ),
          ),
          GoRoute(
            path: 'services/:id/edit',
            builder: (context, state) => _screenGuide(
              screenId: 'service_editor',
              title: context.l10n.editService,
              description:
                  '${context.l10n.pricingLabel} · ${context.l10n.saveLabel}',
              child: ServiceEditorScreen(
                serviceId: state.pathParameters['id']!,
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.calendar,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => _featureGuide(
          context: context,
          screenId: 'work_calendar',
          featureId: AppFeatureId.calendar,
          child: WorkCalendarScreen(
            initialFlow:
                state.uri.queryParameters['flow'] == WorkFlow.worker.name
                ? WorkFlow.worker
                : WorkFlow.tradesman,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.reports,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => _featureGuide(
          context: context,
          screenId: 'reports',
          featureId: AppFeatureId.reports,
          child: const ReportsScreen(),
        ),
      ),
      GoRoute(path: '/dashboard', redirect: (context, state) => AppRoutes.home),
      GoRoute(path: '/jobs', redirect: (context, state) => AppRoutes.work),
      GoRoute(
        path: '/jobs/new',
        redirect: (context, state) => AppRoutes.newJob,
      ),
      GoRoute(
        path: '/jobs/:jobId',
        redirect: (context, state) =>
            AppRoutes.job(state.pathParameters['jobId']!),
      ),
      GoRoute(
        path: '/customers',
        redirect: (context, state) => AppRoutes.peopleFor(WorkFlow.tradesman),
      ),
      GoRoute(
        path: '/customers/new',
        redirect: (context, state) => AppRoutes.newCustomer,
      ),
      GoRoute(path: '/settings', redirect: (context, state) => AppRoutes.more),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

Widget _screenGuide({
  required String screenId,
  required String title,
  required String description,
  required Widget child,
}) => FirstVisitScreenShowcase(
  screenId: screenId,
  title: title,
  description: description,
  child: child,
);

Widget _featureGuide({
  required BuildContext context,
  required String screenId,
  required AppFeatureId featureId,
  required Widget child,
}) {
  final feature = AppFeatureCatalog.forId(featureId);
  return _screenGuide(
    screenId: screenId,
    title: feature.title(context.l10n),
    description: feature.shortDescription(context.l10n),
    child: child,
  );
}
