import 'package:flutter/material.dart';

import '../../routes/ek_routes.dart';
import '../../theme/ek_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final pending = const [
      _PendingTask(id: 1, title: 'Review Q2 Report', assignedTo: 'Sarah Anderson', dueDate: 'Today, 5:00 PM', priority: _Priority.high, category: 'Review'),
      _PendingTask(id: 2, title: 'Update Marketing Strategy', assignedTo: 'John Smith', dueDate: 'Tomorrow, 3:00 PM', priority: _Priority.medium, category: 'Planning'),
      _PendingTask(id: 3, title: 'Client Presentation Prep', assignedTo: 'Emily Davis', dueDate: 'May 9, 10:00 AM', priority: _Priority.high, category: 'Client'),
      _PendingTask(id: 4, title: 'Team Budget Review', assignedTo: 'Michael Brown', dueDate: 'May 10, 2:00 PM', priority: _Priority.low, category: 'Finance'),
    ];

    final completed = const [
      _CompletedTask(id: 5, title: 'Weekly Team Meeting', assignedTo: 'Sarah Anderson', completedDate: 'Today, 11:30 AM', category: 'Meeting'),
      _CompletedTask(id: 6, title: 'Code Review - Feature X', assignedTo: 'Alex Johnson', completedDate: 'Yesterday, 4:00 PM', category: 'Development'),
    ];

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              GradientHeader(
                colors: const [EkColors.blue500, EkColors.purple600],
                bottomRadius: 0,
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
                        _IconHeaderButton(icon: Icons.filter_alt_outlined, onTap: () {}),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _TabButton(
                            label: 'Pending (${pending.length})',
                            active: activeTab == _Tab.pending,
                            onTap: () => setState(() => activeTab = _Tab.pending),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TabButton(
                            label: 'Completed (${completed.length})',
                            active: activeTab == _Tab.completed,
                            onTap: () => setState(() => activeTab = _Tab.completed),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      if (activeTab == _Tab.pending)
                        ...pending.map((t) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: EkCard(
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(t.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: EkColors.gray800, fontWeight: FontWeight.w700)),
                                              const SizedBox(height: 4),
                                              Text('Assigned to: ${t.assignedTo}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: EkColors.gray500)),
                                            ],
                                          ),
                                        ),
                                        EkBadge(
                                          t.priority.name,
                                          variant: switch (t.priority) {
                                            _Priority.high => EkBadgeVariant.danger,
                                            _Priority.medium => EkBadgeVariant.warning,
                                            _Priority.low => EkBadgeVariant.info,
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(t.dueDate, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: EkColors.gray500)),
                                        EkBadge(t.category, variant: EkBadgeVariant.primary),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ))
                      else
                        ...completed.map((t) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Opacity(
                                opacity: 0.75,
                                child: EkCard(
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  t.title,
                                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                        color: EkColors.gray800,
                                                        fontWeight: FontWeight.w700,
                                                        decoration: TextDecoration.lineThrough,
                                                      ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text('Completed by: ${t.assignedTo}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: EkColors.gray500)),
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
                                          Text(t.completedDate, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: EkColors.gray500)),
                                          EkBadge(t.category, variant: EkBadgeVariant.primary),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          EkFab(onPressed: () {}),
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomNav(active: BottomNavItem.tasks),
          ),
        ],
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

enum _Priority { high, medium, low }

class _PendingTask {
  const _PendingTask({
    required this.id,
    required this.title,
    required this.assignedTo,
    required this.dueDate,
    required this.priority,
    required this.category,
  });

  final int id;
  final String title;
  final String assignedTo;
  final String dueDate;
  final _Priority priority;
  final String category;
}

class _CompletedTask {
  const _CompletedTask({
    required this.id,
    required this.title,
    required this.assignedTo,
    required this.completedDate,
    required this.category,
  });

  final int id;
  final String title;
  final String assignedTo;
  final String completedDate;
  final String category;
}

