enum FollowUpStatus { urgent, pending, completed }

class FollowUpRecord {
  const FollowUpRecord({
    required this.id,
    required this.clientName,
    required this.contactPerson,
    required this.nextFollowUp,
    required this.status,
    required this.notes,
    this.createdBy = '',
  });

  final String id;
  final String clientName;
  final String contactPerson;
  final String nextFollowUp;
  final FollowUpStatus status;
  final String notes;
  final String createdBy;

  FollowUpRecord copyWith({
    String? clientName,
    String? contactPerson,
    String? nextFollowUp,
    FollowUpStatus? status,
    String? notes,
  }) {
    return FollowUpRecord(
      id: id,
      clientName: clientName ?? this.clientName,
      contactPerson: contactPerson ?? this.contactPerson,
      nextFollowUp: nextFollowUp ?? this.nextFollowUp,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  factory FollowUpRecord.fromDoc(String id, Map<String, dynamic> data) {
    return FollowUpRecord(
      id: id,
      clientName: (data['clientName'] as String?)?.trim() ?? '',
      contactPerson: (data['contactPerson'] as String?)?.trim() ?? '',
      nextFollowUp: (data['nextFollowUp'] as String?)?.trim() ?? '',
      status: _statusFrom(data['status']),
      notes: (data['notes'] as String?)?.trim() ?? '',
      createdBy: (data['createdBy'] as String?) ?? '',
    );
  }

  static FollowUpStatus _statusFrom(dynamic value) {
    return switch (value) {
      'urgent' => FollowUpStatus.urgent,
      'completed' => FollowUpStatus.completed,
      'scheduled' => FollowUpStatus.completed,
      _ => FollowUpStatus.pending,
    };
  }
}

extension FollowUpStatusX on FollowUpStatus {
  String get label => switch (this) {
        FollowUpStatus.urgent => 'urgent',
        FollowUpStatus.pending => 'pending',
        FollowUpStatus.completed => 'completed',
      };

  String get chipLabel => switch (this) {
        FollowUpStatus.urgent => 'Urgent',
        FollowUpStatus.pending => 'Pending',
        FollowUpStatus.completed => 'Done',
      };
}
