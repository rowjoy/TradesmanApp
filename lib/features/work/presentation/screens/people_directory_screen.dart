import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../l10n/l10n.dart';
import '../../../customers/customer_model.dart';
import '../../../customers/customer_provider.dart';
import '../../../proof/presentation/controllers/audit_controller.dart';
import '../../data/work_repository.dart';
import '../../domain/work_models.dart';
import '../controllers/work_controller.dart';

enum _DirectoryKind { employers, workplaces, customers, services }

class PeopleDirectoryScreen extends ConsumerStatefulWidget {
  const PeopleDirectoryScreen({super.key, required this.flow});
  final WorkFlow flow;

  @override
  ConsumerState<PeopleDirectoryScreen> createState() =>
      _PeopleDirectoryScreenState();
}

class _PeopleDirectoryScreenState extends ConsumerState<PeopleDirectoryScreen> {
  late _DirectoryKind _kind;
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _kind = widget.flow == WorkFlow.worker
        ? _DirectoryKind.employers
        : _DirectoryKind.customers;
    _searchController.text = widget.flow == WorkFlow.worker
        ? ref.read(directorySearchQueryProvider)
        : ref.read(customerSearchQueryProvider);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _queueSearch(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      _applySearch(value);
    });
  }

  void _applySearch(String value) {
    final query = value.trim();
    if (_kind == _DirectoryKind.customers) {
      ref.read(customerSearchQueryProvider.notifier).state = query;
    } else {
      ref.read(directorySearchQueryProvider.notifier).state = query;
    }
  }

  List<_DirectoryKind> get _available => widget.flow == WorkFlow.worker
      ? [_DirectoryKind.employers, _DirectoryKind.workplaces]
      : [_DirectoryKind.customers, _DirectoryKind.services];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.peopleTitle)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_people_directory',
        onPressed: () => context.push(_newRoute(_kind)),
        icon: const Icon(Icons.add),
        label: Text(_newLabel(context, _kind)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<_DirectoryKind>(
                segments: [
                  for (final kind in _available)
                    ButtonSegment(
                      value: kind,
                      label: Text(_label(context, kind)),
                    ),
                ],
                selected: {_kind},
                onSelectionChanged: (value) {
                  _searchDebounce?.cancel();
                  setState(() => _kind = value.first);
                  _applySearch(_searchController.text);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: context.l10n.searchPeople,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: _queueSearch,
            ),
          ),
          Expanded(child: _directoryBody()),
        ],
      ),
    );
  }

  Widget _directoryBody() => switch (_kind) {
    _DirectoryKind.employers => _AsyncDirectory<Employer>(
      value: ref.watch(directoryEmployersProvider),
      emptyText: context.l10n.noEmployers,
      title: (item) => item.name,
      subtitle: (item) =>
          item.contactName ?? item.paySchedule ?? context.l10n.noContactInfo,
      editRoute: (item) => AppRoutes.editEmployer(item.id),
      onDelete: (item) => _delete('employers', 'employer', item.id),
    ),
    _DirectoryKind.workplaces => _AsyncDirectory<Workplace>(
      value: ref.watch(directoryWorkplacesProvider),
      emptyText: context.l10n.noWorkplaces,
      title: (item) => item.name,
      subtitle: (item) => item.address ?? item.ianaTimeZone,
      editRoute: (item) => AppRoutes.editWorkplace(item.id),
      onDelete: (item) => _delete('workplaces', 'workplace', item.id),
    ),
    _DirectoryKind.customers => _AsyncDirectory<Customer>(
      value: ref.watch(customersListProvider),
      emptyText: context.l10n.noCustomers,
      title: (item) => item.name,
      subtitle: (item) =>
          item.phone ?? item.email ?? context.l10n.noContactInfo,
      editRoute: (item) => AppRoutes.editCustomer(item.id),
      onDelete: (item) async {
        if (!await _confirmDelete()) return false;
        await ref.read(customerRepositoryProvider).softDelete(item.id);
        ref.invalidate(customersListProvider);
        ref.invalidate(allCustomersProvider);
        invalidateWorkData(ref, flow: WorkFlow.tradesman);
        ref.invalidate(auditEventsProvider);
        return true;
      },
    ),
    _DirectoryKind.services => _AsyncDirectory<ServiceTemplate>(
      value: ref.watch(directoryServicesProvider),
      emptyText: context.l10n.noServices,
      title: (item) => item.name,
      subtitle: (item) => '${item.category} · ${item.pricingType}',
      editRoute: (item) => AppRoutes.editService(item.id),
      onDelete: (item) => _delete('services', 'service', item.id),
    ),
  };

  Future<bool> _delete(String table, String entityType, String id) async {
    if (!await _confirmDelete()) return false;
    await ref
        .read(workRepositoryProvider)
        .softDelete(table: table, entityType: entityType, id: id);
    invalidateWorkDirectories(ref);
    invalidateWorkData(
      ref,
      flow: table == 'services' ? WorkFlow.tradesman : WorkFlow.worker,
    );
    ref.invalidate(auditEventsProvider);
    return true;
  }

  Future<bool> _confirmDelete() async =>
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(context.l10n.deleteRecordTitle),
          content: Text(context.l10n.deleteRecordDescription),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.l10n.cancelLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(context.l10n.deleteLabel),
            ),
          ],
        ),
      ) ??
      false;
}

class _AsyncDirectory<T> extends StatelessWidget {
  const _AsyncDirectory({
    required this.value,
    required this.emptyText,
    required this.title,
    required this.subtitle,
    required this.editRoute,
    required this.onDelete,
  });

  final AsyncValue<List<T>> value;
  final String emptyText;
  final String Function(T) title;
  final String Function(T) subtitle;
  final String Function(T) editRoute;
  final Future<bool> Function(T) onDelete;

  @override
  Widget build(BuildContext context) => value.when(
    data: (items) => items.isEmpty
        ? Center(child: Text(emptyText, textAlign: TextAlign.center))
        : ListView.separated(
            key: PageStorageKey('people-directory-$T'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_outline),
                  ),
                  title: Text(
                    title(item),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(subtitle(item)),
                  onTap: () => context.push(editRoute(item)),
                  trailing: Wrap(
                    spacing: 2,
                    children: [
                      IconButton(
                        tooltip: context.l10n.editLabel,
                        onPressed: () => context.push(editRoute(item)),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: context.l10n.deleteLabel,
                        onPressed: () async {
                          final deleted = await onDelete(item);
                          if (context.mounted && deleted) {
                            AppFeedback.success(
                              context,
                              context.l10n.recordDeleted,
                            );
                          }
                        },
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    loading: () => const AppListSkeleton(),
    error: (_, __) => Center(child: Text(context.l10n.peopleLoadFailed)),
  );
}

String _label(BuildContext context, _DirectoryKind kind) => switch (kind) {
  _DirectoryKind.employers => context.l10n.employers,
  _DirectoryKind.workplaces => context.l10n.workplaces,
  _DirectoryKind.customers => context.l10n.customers,
  _DirectoryKind.services => context.l10n.services,
};

String _newLabel(BuildContext context, _DirectoryKind kind) =>
    '${context.l10n.addLabel} ${_label(context, kind)}';

String _newRoute(_DirectoryKind kind) => switch (kind) {
  _DirectoryKind.employers => AppRoutes.newEmployer,
  _DirectoryKind.workplaces => AppRoutes.newWorkplace,
  _DirectoryKind.customers => AppRoutes.newCustomer,
  _DirectoryKind.services => AppRoutes.newService,
};
