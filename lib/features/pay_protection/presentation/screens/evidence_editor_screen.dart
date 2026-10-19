import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/inline_animated_picker.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../l10n/l10n.dart';
import '../../../proof/presentation/controllers/audit_controller.dart';
import '../../data/pay_protection_repository.dart';
import '../../domain/pay_protection_models.dart';
import '../../infrastructure/evidence_file_service.dart';
import '../controllers/pay_protection_controller.dart';

class EvidenceEditorScreen extends ConsumerStatefulWidget {
  const EvidenceEditorScreen({super.key, required this.payPeriodId});
  final String payPeriodId;

  @override
  ConsumerState<EvidenceEditorScreen> createState() =>
      _EvidenceEditorScreenState();
}

class _EvidenceEditorScreenState extends ConsumerState<EvidenceEditorScreen> {
  final _description = TextEditingController();
  EvidenceType _type = EvidenceType.note;
  PreparedEvidenceFile? _file;
  bool _picking = false;
  bool _saving = false;
  bool _saved = false;

  @override
  void dispose() {
    _description.dispose();
    if (!_saved && _file != null) {
      unawaited(ref.read(evidenceFileServiceProvider).discard(_file!));
    }
    super.dispose();
  }

  Future<void> _pick() async {
    setState(() => _picking = true);
    try {
      final file = await ref
          .read(evidenceFileServiceProvider)
          .pickAndPrepare(
            _type == EvidenceType.photo
                ? EvidencePickKind.photo
                : EvidencePickKind.document,
          );
      if (file != null && mounted) {
        final previous = _file;
        setState(() => _file = file);
        if (previous != null && previous.localPath != file.localPath) {
          unawaited(ref.read(evidenceFileServiceProvider).discard(previous));
        }
      }
    } on EvidenceFileTooLargeException {
      if (mounted) _message(context.l10n.evidenceFileTooLarge);
    } catch (_) {
      if (mounted) {
        _message(context.l10n.m05FileCouldNotBePrepared);
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _save() async {
    if (_description.text.trim().isEmpty &&
        (_type == EvidenceType.note || _type == EvidenceType.signature)) {
      _message(context.l10n.m05WriteANoteFirst);
      return;
    }
    if (_type != EvidenceType.note &&
        _type != EvidenceType.signature &&
        _file == null) {
      _message(context.l10n.m05ChooseAFileFirst);
      return;
    }
    setState(() => _saving = true);
    try {
      final repository = ref.read(payProtectionRepositoryProvider);
      if (_type == EvidenceType.note || _type == EvidenceType.signature) {
        await repository.addNoteEvidence(
          payPeriodId: widget.payPeriodId,
          description: _description.text,
          type: _type,
        );
      } else {
        await repository.addFileEvidence(
          payPeriodId: widget.payPeriodId,
          type: _type,
          file: _file!,
          description: _description.text,
        );
      }
      invalidatePayProtection(ref, periodId: widget.payPeriodId);
      ref.invalidate(auditEventsProvider);
      _saved = true;
      if (mounted) context.pop(true);
    } catch (_) {
      if (mounted) {
        _message(context.l10n.m05EvidenceCouldNotBeSaved);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String value) => AppFeedback.error(context, value);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.m05AddEvidence)),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
      children: [
        InlineAnimatedPicker<EvidenceType>(
          label: context.l10n.m05EvidenceType,
          value: _type,
          options: const [
            EvidenceType.note,
            EvidenceType.photo,
            EvidenceType.document,
            EvidenceType.signature,
          ],
          optionLabel: (value) => switch (value) {
            EvidenceType.note => context.l10n.m05WrittenNote,
            EvidenceType.photo => context.l10n.m05Photo,
            EvidenceType.document => context.l10n.m05DocumentPDF,
            EvidenceType.payslip => context.l10n.m05Payslip,
            EvidenceType.signature => context.l10n.m05TypedAcknowledgement,
          },
          optionLeading: (value) => Icon(switch (value) {
            EvidenceType.note => Icons.notes_rounded,
            EvidenceType.photo => Icons.photo_outlined,
            EvidenceType.document => Icons.description_outlined,
            EvidenceType.payslip => Icons.receipt_outlined,
            EvidenceType.signature => Icons.draw_outlined,
          }),
          leading: const Icon(Icons.category_outlined),
          onChanged: (value) {
            final previous = _file;
            setState(() {
              _type = value;
              _file = null;
            });
            if (previous != null) {
              unawaited(
                ref.read(evidenceFileServiceProvider).discard(previous),
              );
            }
          },
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _description,
          minLines: 3,
          maxLines: 6,
          decoration: InputDecoration(
            labelText: _type == EvidenceType.note
                ? context.l10n.m05WhatHappened
                : _type == EvidenceType.signature
                ? context.l10n.m05SignerNameAndAcknowledgement
                : context.l10n.m05DescriptionOptional,
            alignLabelWithHint: true,
          ),
        ),
        if (_type != EvidenceType.note && _type != EvidenceType.signature) ...[
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_file == null)
                    Text(
                      context.l10n.m05NoFileSelected,
                      textAlign: TextAlign.center,
                    )
                  else ...[
                    Row(
                      children: [
                        Icon(
                          _type == EvidenceType.photo
                              ? Icons.image_outlined
                              : Icons.description_outlined,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _file!.originalFilename,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text('SHA-256 ${_file!.sha256.substring(0, 20)}…'),
                    const SizedBox(height: 5),
                    Text(
                      _file!.metadataStripped
                          ? context
                                .l10n
                                .m05CompressedShareCopyCreatedImageMetadataStripped
                          : context.l10n.m05AShareCopyIsCreatedDocumentMetadata,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _picking ? null : _pick,
                    icon: _picking
                        ? const SizedBox.square(
                            dimension: 17,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.file_open_outlined),
                    label: Text(
                      _file == null
                          ? context.l10n.m05ChooseFromDevice
                          : context.l10n.m05ChooseAnother,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (_type == EvidenceType.signature) ...[
          const SizedBox(height: 10),
          Text(
            context.l10n.m05ThisRecordsTypedAcknowledgementAndTimeOnly,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.secondaryContainer.withValues(alpha: .55),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_outline_rounded),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.m05OriginalEvidenceStaysPrivateOnThisDevice,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.verified_outlined),
          label: Text(context.l10n.m05SaveEvidence),
        ),
      ],
    ),
  );
}
