import 'package:flutter/material.dart';

import '../../models/task_record.dart';
import '../../routes/ek_routes.dart';
import '../../services/app_session.dart';
import '../../services/reminder_time_parser.dart';
import '../../services/task_repository.dart';
import '../../theme/ek_colors.dart';
import '../../theme/ek_theme_context.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/ek_badge.dart';
import '../../widgets/ek_card.dart';
import '../../widgets/ek_fab.dart';
import '../../widgets/gradient_header.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  _Tab activeTab = _Tab.pending;
  TaskPriority? _priorityFilter;
  String? _categoryFilter;

  bool get _hasActiveFilters => _priorityFilter != null || (_categoryFilter != null && _categoryFilter!.isNotEmpty);

  List<TaskRecord> _filteredPending(List<TaskRecord> all) {
    return all.where((t) {
      if (!t.isPending) return false;
      if (_priorityFilter != null && t.priority != _priorityFilter) return false;
      if (_categoryFilter != null && _categoryFilter!.isNotEmpty && t.category != _categoryFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  List<TaskRecord> _filteredCompleted(List<TaskRecord> all) {
    return all.where((t) {
      if (t.isPending) return false;
      if (_categoryFilter != null && _categoryFilter!.isNotEmpty && t.category != _categoryFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  Set<String> _allCategories(List<TaskRecord> all) => all.map((t) => t.category).toSet();

  Future<void> _showFilterSheet(List<TaskRecord> allTasks) async {
    var priority = _priorityFilter;
    var category = _categoryFilter;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final textPrimary = sheetContext.ekTextPrimary;
            final categories = _allCategories(allTasks).toList()..sort();

            return Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + MediaQuery.of(sheetContext).padding.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: sheetContext.ekTextSecondary.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Filter Tasks',
                    style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Priority',
                    style: Theme.of(sheetContext).textTheme.labelLarge?.copyWith(
                          color: sheetContext.ekTextSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: priority == null,
                        onTap: () => setSheetState(() => priority = null),
                      ),
                      for (final p in TaskPriority.values)
                        _FilterChip(
                          label: p.label,
                          selected: priority == p,
                          onTap: () => setSheetState(() => priority = p),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Category',
                    style: Theme.of(sheetContext).textTheme.labelLarge?.copyWith(
                          color: sheetContext.ekTextSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: category == null || category!.isEmpty,
                        onTap: () => setSheetState(() => category = null),
                      ),
                      for (final c in categories)
                        _FilterChip(
                          label: c,
                          selected: category == c,
                          onTap: () => setSheetState(() => category = c),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _priorityFilter = null;
                              _categoryFilter = null;
                            });
                            Navigator.of(sheetContext).pop();
                          },
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            setState(() {
                              _priorityFilter = priority;
                              _categoryFilter = category;
                            });
                            Navigator.of(sheetContext).pop();
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAddTaskDialog() async {
    final result = await showDialog<_AddTaskResult>(
      context: context,
      builder: (dialogContext) => _AddTaskDialog(hostContext: dialogContext),
    );

    if (result == null || !mounted) return;

    try {
      final profile = AppSession.profile.value;
      await TaskRepository.addTask(
        title: result.title,
        assignedTo: result.assignedTo,
        dueDate: result.dueDate,
        category: result.category,
        priority: result.priority,
        createdBy: profile?.id ?? '',
        remindAt: result.remindAt,
      );
      if (!mounted) return;
      setState(() => activeTab = _Tab.pending);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.remindAt != null ? 'Task added with reminder alarm.' : 'Task added.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not add task: $e')),
      );
    }
  }

  Future<void> _markComplete(TaskRecord task) async {
    try {
      final profile = AppSession.profile.value;
      await TaskRepository.markComplete(
        taskId: task.id,
        completedByUserId: profile?.id ?? '',
        completedByName: profile?.displayName ?? 'Someone',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${task.title}" marked complete.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update task: $e')),
      );
    }
  }

  Future<void> _markPending(TaskRecord task) async {
    try {
      await TaskRepository.markPending(task.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${task.title}" moved to pending.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = context.ekTextPrimary;
    final textSecondary = context.ekTextSecondary;

    return Scaffold(
      body: StreamBuilder<List<TaskRecord>>(
        stream: TaskRepository.watchAll(),
        builder: (context, snap) {
          final all = snap.data ?? const [];
          final pending = _filteredPending(all);
          final completed = _filteredCompleted(all);
          final pendingCount = all.where((t) => t.isPending).length;
          final completedCount = all.length - pendingCount;

          if (snap.connectionState == ConnectionState.waiting && all.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              GradientHeader(
                colors: const [EkColors.blue500, EkColors.purple600],
                bottomRadius: 40,
                padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
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
                              'Tasks',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                        _IconHeaderButton(
                          icon: _hasActiveFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                          onTap: () => _showFilterSheet(all),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _TabButton(
                            label: 'Pending ($pendingCount)',
                            active: activeTab == _Tab.pending,
                            onTap: () => setState(() => activeTab = _Tab.pending),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TabButton(
                            label: 'Completed ($completedCount)',
                            active: activeTab == _Tab.completed,
                            onTap: () => setState(() => activeTab = _Tab.completed),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  children: [
                    if (_hasActiveFilters)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                activeTab == _Tab.pending
                                    ? 'Showing ${pending.length} of $pendingCount pending'
                                    : 'Showing ${completed.length} of $completedCount completed',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary),
                              ),
                            ),
                            TextButton(
                              onPressed: () => setState(() {
                                _priorityFilter = null;
                                _categoryFilter = null;
                              }),
                              child: const Text('Clear filters'),
                            ),
                          ],
                        ),
                      ),
                    if (activeTab == _Tab.pending) ...[
                      if (pending.isEmpty)
                        _EmptyState(
                          message: _hasActiveFilters
                              ? 'No pending tasks match your filters.'
                              : 'No pending tasks. Tap + to add one.',
                        )
                      else
                        ...pending.map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EkCard(
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _TaskStatusActions(
                                        isPending: true,
                                        onMarkComplete: () => _markComplete(t),
                                        onMarkPending: () {},
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              t.title,
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    color: textPrimary,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Assigned to: ${t.assignedTo}',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      EkBadge(
                                        t.priority.label,
                                        variant: switch (t.priority) {
                                          TaskPriority.high => EkBadgeVariant.danger,
                                          TaskPriority.medium => EkBadgeVariant.warning,
                                          TaskPriority.low => EkBadgeVariant.info,
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        t.dueDate,
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: textSecondary),
                                      ),
                                      EkBadge(t.category, variant: EkBadgeVariant.primary),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ] else ...[
                      if (completed.isEmpty)
                        _EmptyState(
                          message: _hasActiveFilters
                              ? 'No completed tasks match your filters.'
                              : 'No completed tasks yet.',
                        )
                      else
                        ...completed.map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Opacity(
                              opacity: 0.85,
                              child: EkCard(
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _TaskStatusActions(
                                          isPending: false,
                                          onMarkComplete: () {},
                                          onMarkPending: () => _markPending(t),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                t.title,
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                      color: textPrimary,
                                                      fontWeight: FontWeight.w700,
                                                      decoration: TextDecoration.lineThrough,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Completed by: ${t.assignedTo}',
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const EkBadge('Done', variant: EkBadgeVariant.success),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          t.completedDateLabel,
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: textSecondary),
                                        ),
                                        EkBadge(t.category, variant: EkBadgeVariant.primary),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
          EkFab(onPressed: _showAddTaskDialog),
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomNav(active: BottomNavItem.tasks),
          ),
        ],
      );
        },
      ),
    );
  }
}

class _AddTaskResult {
  const _AddTaskResult({
    required this.title,
    required this.assignedTo,
    required this.dueDate,
    required this.category,
    required this.priority,
    this.remindAt,
  });

  final String title;
  final String assignedTo;
  final String dueDate;
  final String category;
  final TaskPriority priority;
  final DateTime? remindAt;
}

class _AddTaskDialog extends StatefulWidget {
  const _AddTaskDialog({required this.hostContext});

  final BuildContext hostContext;

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final _title = TextEditingController();
  final _assigned = TextEditingController();
  final _dueDate = TextEditingController();
  final _category = TextEditingController();
  final _reminderTime = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;

  @override
  void dispose() {
    _title.dispose();
    _assigned.dispose();
    _dueDate.dispose();
    _category.dispose();
    _reminderTime.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _title.text.trim();
    final assignedTo = _assigned.text.trim();
    if (title.isEmpty || assignedTo.isEmpty) {
      ScaffoldMessenger.of(widget.hostContext).showSnackBar(
        const SnackBar(content: Text('Title and assigned to are required.')),
      );
      return;
    }

    final due = _dueDate.text.trim();
    final remindAt = _reminderTime.text.trim().isNotEmpty
        ? parseReminderDateTime(timeLabel: _reminderTime.text.trim(), dateLabel: due, defaultToday: true)
        : parseReminderDateTime(timeLabel: due, defaultToday: true);

    Navigator.of(context).pop(
      _AddTaskResult(
        title: title,
        assignedTo: assignedTo,
        dueDate: due.isEmpty ? 'No due date' : due,
        category: _category.text.trim().isEmpty ? 'General' : _category.text.trim(),
        priority: _priority,
        remindAt: remindAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _assigned,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Assigned to *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dueDate,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Due date',
                hintText: 'e.g. Today, 5:00 PM',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _category,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'e.g. Review',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reminderTime,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Reminder alarm',
                hintText: 'e.g. 5:00 PM (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TaskPriority>(
              initialValue: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: TaskPriority.values
                  .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _priority = value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}

/// Tick = complete, cross = pending. Both always visible; active state shows current status.
class _TaskStatusActions extends StatelessWidget {
  const _TaskStatusActions({
    required this.isPending,
    required this.onMarkComplete,
    required this.onMarkPending,
  });

  final bool isPending;
  final VoidCallback onMarkComplete;
  final VoidCallback onMarkPending;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatusButton(
          icon: Icons.check_rounded,
          label: 'Complete',
          active: !isPending,
          activeColor: const Color(0xFF16A34A),
          onTap: onMarkComplete,
        ),
        const SizedBox(height: 6),
        _StatusButton(
          icon: Icons.close_rounded,
          label: 'Pending',
          active: isPending,
          activeColor: const Color(0xFFEA580C),
          onTap: onMarkPending,
        ),
      ],
    );
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inactiveBg = context.ekMutedSurface;
    final inactiveFg = context.ekTextSecondary;

    return Tooltip(
      message: label,
      child: Material(
        color: active ? activeColor : inactiveBg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              icon,
              size: 20,
              color: active ? Colors.white : inactiveFg,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: EkColors.purple600.withValues(alpha: 0.2),
      checkmarkColor: EkColors.purple600,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.ekTextSecondary),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: active ? EkColors.purple600 : Colors.white,
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

enum _Tab { pending, completed }
