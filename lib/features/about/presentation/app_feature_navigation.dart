import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../work/domain/work_models.dart';
import '../domain/app_feature.dart';

extension AppFeatureNavigation on AppFeature {
  String routeFor(WorkFlow flow) => switch (destination) {
    AppFeatureDestination.work => AppRoutes.work,
    AppFeatureDestination.people => AppRoutes.peopleFor(flow),
    AppFeatureDestination.calendar => AppRoutes.calendarFor(flow),
    AppFeatureDestination.money => AppRoutes.money,
    AppFeatureDestination.proof => AppRoutes.proof,
    AppFeatureDestination.reports => AppRoutes.reports,
    AppFeatureDestination.reminders => AppRoutes.notifications,
    AppFeatureDestination.backup => AppRoutes.backupRestore,
    AppFeatureDestination.security => AppRoutes.security,
    AppFeatureDestination.promotions => AppRoutes.marketingStudio,
    AppFeatureDestination.codeTools => AppRoutes.codeStudio,
  };

  /// Opens shell branches by replacement and detail/utility screens by push,
  /// preserving a usable Back path to About for the latter group.
  void open(BuildContext context, WorkFlow flow) {
    final route = routeFor(flow);
    switch (destination) {
      case AppFeatureDestination.work:
      case AppFeatureDestination.money:
      case AppFeatureDestination.proof:
        context.go(route);
        break;
      case AppFeatureDestination.people:
      case AppFeatureDestination.calendar:
      case AppFeatureDestination.reports:
      case AppFeatureDestination.reminders:
      case AppFeatureDestination.backup:
      case AppFeatureDestination.security:
      case AppFeatureDestination.promotions:
      case AppFeatureDestination.codeTools:
        context.push(route);
        break;
    }
  }
}
