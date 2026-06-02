import 'package:flutter/material.dart';

import '../../routes/ek_routes.dart';
import '../../theme/ek_colors.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/ek_badge.dart';
import '../../widgets/ek_card.dart';
import '../../widgets/ek_fab.dart';
import '../../widgets/gradient_header.dart';

class FollowUpsScreen extends StatelessWidget {
  const FollowUpsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      _FollowUp(
        id: 1,
        clientName: 'Acme Corporation',
        contactPerson: 'James Wilson',
        nextFollowUp: 'Today, 3:00 PM',
        status: _FollowUpStatus.urgent,
        notes: 'Discuss Q2 contract renewal',
      ),
      _FollowUp(
        id: 2,
        clientName: 'TechStart Inc',
        contactPerson: 'Lisa Chen',
        nextFollowUp: 'Tomorrow, 10:00 AM',
        status: _FollowUpStatus.pending,
        notes: 'Product demo follow-up',
      ),
      _FollowUp(
        id: 3,
        clientName: 'Global Solutions',
        contactPerson: 'Michael Brown',
        nextFollowUp: 'May 9, 2:00 PM',
        status: _FollowUpStatus.scheduled,
        notes: 'Price negotiation meeting',
      ),
      _FollowUp(
        id: 4,
        clientName: 'Innovation Labs',
        contactPerson: 'Sarah Davis',
        nextFollowUp: 'May 10, 11:00 AM',
        status: _FollowUpStatus.scheduled,
        notes: 'Technical requirements review',
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              GradientHeader(
                colors: const [EkColors.orange500, EkColors.red500],
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
                              'Follow-Ups',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
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
                              Text('Active Clients', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                              const SizedBox(height: 6),
                              Text('24', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Due Today', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                              const SizedBox(height: 6),
                              Text('3', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ],
                      ),
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
                      ...items.map((f) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EkCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(f.clientName, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: EkColors.gray800, fontWeight: FontWeight.w700)),
                                            const SizedBox(height: 4),
                                            Text('Contact: ${f.contactPerson}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: EkColors.gray500)),
                                          ],
                                        ),
                                      ),
                                      EkBadge(f.status.label, variant: f.status.badge),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(color: EkColors.gray50, borderRadius: BorderRadius.circular(14)),
                                    child: Text(f.notes, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: EkColors.gray600)),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_month_rounded, size: 16, color: EkColors.gray500),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text('Next follow-up: ${f.nextFollowUp}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: EkColors.gray500)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _SoftActionButton(
                                          bg: const Color(0xFFEFF6FF),
                                          fg: const Color(0xFF2563EB),
                                          icon: Icons.call_rounded,
                                          label: 'Call',
                                          onTap: () {},
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _SoftActionButton(
                                          bg: const Color(0xFFF5F3FF),
                                          fg: EkColors.purple600,
                                          icon: Icons.mail_outline_rounded,
                                          label: 'Email',
                                          onTap: () {},
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
            child: BottomNav(active: BottomNavItem.home),
          ),
        ],
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

class _SoftActionButton extends StatelessWidget {
  const _SoftActionButton({
    required this.bg,
    required this.fg,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Color bg;
  final Color fg;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _FollowUp {
  const _FollowUp({
    required this.id,
    required this.clientName,
    required this.contactPerson,
    required this.nextFollowUp,
    required this.status,
    required this.notes,
  });

  final int id;
  final String clientName;
  final String contactPerson;
  final String nextFollowUp;
  final _FollowUpStatus status;
  final String notes;
}

enum _FollowUpStatus { urgent, pending, scheduled }

extension on _FollowUpStatus {
  String get label => switch (this) {
        _FollowUpStatus.urgent => 'urgent',
        _FollowUpStatus.pending => 'pending',
        _FollowUpStatus.scheduled => 'scheduled',
      };

  EkBadgeVariant get badge => switch (this) {
        _FollowUpStatus.urgent => EkBadgeVariant.danger,
        _FollowUpStatus.pending => EkBadgeVariant.warning,
        _FollowUpStatus.scheduled => EkBadgeVariant.info,
      };
}

