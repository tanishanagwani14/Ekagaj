import 'package:flutter/material.dart';

import '../../models/followup_record.dart';
import '../../routes/ek_routes.dart';
import '../../services/app_session.dart';
import '../../services/followup_repository.dart';
import '../../theme/ek_colors.dart';
import '../../theme/ek_theme_context.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/ek_badge.dart';
import '../../widgets/ek_card.dart';
import '../../widgets/ek_fab.dart';
import '../../widgets/gradient_header.dart';

class FollowUpsScreen extends StatefulWidget {
  const FollowUpsScreen({super.key});

  @override
  State<FollowUpsScreen> createState() => _FollowUpsScreenState();
}

class _FollowUpsScreenState extends State<FollowUpsScreen> {
  int _dueTodayCount(List<FollowUpRecord> items) =>
      items.where((f) => f.nextFollowUp.toLowerCase().contains('today')).length;

  Future<void> _setStatus(String id, FollowUpStatus status) async {
    try {
      await FollowUpRepository.updateStatus(id, status);
      if (!mounted) return;
      if (status == FollowUpStatus.completed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Follow-up marked completed.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update: $e')),
      );
    }
  }

  Future<void> _showAddDialog() async {
    final result = await showDialog<FollowUpRecord>(
      context: context,
      builder: (dialogContext) => _AddFollowUpDialog(hostContext: dialogContext),
    );
    if (result == null || !mounted) return;

    try {
      final profile = AppSession.profile.value;
      await FollowUpRepository.add(
        clientName: result.clientName,
        contactPerson: result.contactPerson,
        nextFollowUp: result.nextFollowUp,
        status: result.status,
        notes: result.notes,
        createdBy: profile?.id ?? '',
        createdByName: profile?.displayName,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Follow-up added.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not add follow-up: $e')),
      );
    }
  }

  void _openDetail(FollowUpRecord item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return _FollowUpDetailSheet(
          item: item,
          onStatusChanged: (status) {
            _setStatus(item.id, status);
            Navigator.of(sheetContext).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = context.ekTextPrimary;
    final textSecondary = context.ekTextSecondary;

    return Scaffold(
      body: StreamBuilder<List<FollowUpRecord>>(
        stream: FollowUpRepository.watchAll(),
        builder: (context, snap) {
          final items = snap.data ?? const [];
          if (snap.connectionState == ConnectionState.waiting && items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              GradientHeader(
                colors: const [EkColors.orange500, EkColors.red500],
                bottomRadius: 40,
                child: Column(
                  children: [
                    Row(
                      children: [
                        _IconHeaderButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.of(context).pushReplacementNamed(EkRoutes.home),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Follow-Ups',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                    const SizedBox(height: 20),
                    EkCard(
                      variant: EkCardVariant.gradient,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Active Clients',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${items.length}',
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Due Today',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${_dueTodayCount(items)}',
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  children: [
                    ...items.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: EkCard(
                          onTap: () => _openDetail(f),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          f.clientName,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                color: textPrimary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Contact: ${f.contactPerson}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  EkBadge(f.status.label, variant: _badgeFor(f.status)),
                                  const SizedBox(width: 4),
                                  Icon(Icons.chevron_right_rounded, color: textSecondary),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: context.ekMutedSurface,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  f.notes,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.calendar_month_rounded, size: 16, color: textSecondary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Next: ${f.nextFollowUp}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _StatusChip(
                                    label: 'Pending',
                                    active: f.status == FollowUpStatus.pending,
                                    color: const Color(0xFFEA580C),
                                    onTap: () => _setStatus(f.id, FollowUpStatus.pending),
                                  ),
                                  const SizedBox(width: 8),
                                  _StatusChip(
                                    label: 'Urgent',
                                    active: f.status == FollowUpStatus.urgent,
                                    color: const Color(0xFFDC2626),
                                    onTap: () => _setStatus(f.id, FollowUpStatus.urgent),
                                  ),
                                  const SizedBox(width: 8),
                                  _StatusChip(
                                    label: 'Completed',
                                    active: f.status == FollowUpStatus.completed,
                                    color: const Color(0xFF16A34A),
                                    onTap: () => _setStatus(f.id, FollowUpStatus.completed),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
          EkFab(onPressed: _showAddDialog),
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomNav(active: BottomNavItem.home),
          ),
        ],
      );
        },
      ),
    );
  }
}

EkBadgeVariant _badgeFor(FollowUpStatus status) => switch (status) {
      FollowUpStatus.urgent => EkBadgeVariant.danger,
      FollowUpStatus.pending => EkBadgeVariant.warning,
      FollowUpStatus.completed => EkBadgeVariant.success,
    };

class _AddFollowUpDialog extends StatefulWidget {
  const _AddFollowUpDialog({required this.hostContext});

  final BuildContext hostContext;

  @override
  State<_AddFollowUpDialog> createState() => _AddFollowUpDialogState();
}

class _AddFollowUpDialogState extends State<_AddFollowUpDialog> {
  final _client = TextEditingController();
  final _contact = TextEditingController();
  final _when = TextEditingController();
  final _notes = TextEditingController();
  FollowUpStatus _status = FollowUpStatus.pending;

  @override
  void dispose() {
    _client.dispose();
    _contact.dispose();
    _when.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _submit() {
    final client = _client.text.trim();
    final contact = _contact.text.trim();
    final when = _when.text.trim();
    if (client.isEmpty || contact.isEmpty || when.isEmpty) {
      ScaffoldMessenger.of(widget.hostContext).showSnackBar(
        const SnackBar(content: Text('Client, contact, and follow-up time are required.')),
      );
      return;
    }

    Navigator.of(context).pop(
      FollowUpRecord(
        id: '',
        clientName: client,
        contactPerson: contact,
        nextFollowUp: when,
        status: _status,
        notes: _notes.text.trim().isEmpty ? 'No notes added.' : _notes.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Follow-Up'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _client,
              decoration: const InputDecoration(labelText: 'Client name *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contact,
              decoration: const InputDecoration(labelText: 'Contact person *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _when,
              decoration: const InputDecoration(
                labelText: 'Next follow-up *',
                hintText: 'e.g. Today, 3:00 PM',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<FollowUpStatus>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
              items: FollowUpStatus.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _status = v);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}

class _FollowUpDetailSheet extends StatelessWidget {
  const _FollowUpDetailSheet({
    required this.item,
    required this.onStatusChanged,
  });

  final FollowUpRecord item;
  final ValueChanged<FollowUpStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final textPrimary = context.ekTextPrimary;
    final textSecondary = context.ekTextSecondary;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: textSecondary.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            item.clientName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text('Contact: ${item.contactPerson}', style: TextStyle(color: textSecondary)),
          const SizedBox(height: 8),
          Text('Next follow-up: ${item.nextFollowUp}', style: TextStyle(color: textSecondary)),
          const SizedBox(height: 16),
          EkBadge(item.status.label, variant: _badgeFor(item.status)),
          const SizedBox(height: 16),
          Text(item.notes, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textPrimary, height: 1.5)),
          const SizedBox(height: 24),
          Text('Update status', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: textSecondary)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => onStatusChanged(FollowUpStatus.pending),
                  child: const Text('Pending'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => onStatusChanged(FollowUpStatus.urgent),
                  child: const Text('Urgent'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: () => onStatusChanged(FollowUpStatus.completed),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: const Text('Completed', maxLines: 1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: active ? color : context.ekMutedSurface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: active ? Colors.white : context.ekTextSecondary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconHeaderButton extends StatelessWidget {
  const _IconHeaderButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}
