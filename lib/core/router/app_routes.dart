import '../../features/work/domain/work_models.dart';

/// Stable route locations shared by navigation and feature discovery UI.
abstract final class AppRoutes {
  static const startup = '/startup';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const work = '/work';
  static const newJob = '/work/jobs/new';
  static String editJob(String jobId) => '/work/jobs/$jobId/edit';
  static String job(String jobId) => '/work/jobs/$jobId';
  static String jobWorkspace(String jobId) => '/work/jobs/$jobId/workspace';
  static const newShift = '/work/shifts/new';
  static String editShift(String shiftId) => '/work/shifts/$shiftId/edit';
  static String shift(String shiftId) => '/work/shifts/$shiftId';
  static const calendar = '/work-calendar';
  static String calendarFor(WorkFlow flow) => '$calendar?flow=${flow.name}';
  static const people = '/people';
  static String peopleFor(WorkFlow flow) => '$people?flow=${flow.name}';
  static const newEmployer = '/people/employers/new';
  static String editEmployer(String id) => '/people/employers/$id/edit';
  static const newWorkplace = '/people/workplaces/new';
  static String editWorkplace(String id) => '/people/workplaces/$id/edit';
  static const newCustomer = '/people/customers/new';
  static String editCustomer(String id) => '/people/customers/$id/edit';
  static const newService = '/people/services/new';
  static String editService(String id) => '/people/services/$id/edit';
  static const money = '/money';
  static const newPayPeriod = '/money/new';
  static String payPeriod(String id) => '/money/$id';
  static String payPayslip(String id) => '/money/$id/payslip';
  static String newPayEvidence(String id) => '/money/$id/evidence/new';
  static const proof = '/proof';
  static const more = '/more';
  static const notifications = '/more/notifications';
  static const preferences = '/more/preferences';
  static const security = '/more/security';
  static const backupRestore = '/more/backup-restore';
  static const marketingStudio = '/more/marketing-studio';
  static const codeStudio = '/more/code-studio';
  static const about = '/more/about';
  static const reports = '/reports';
}
