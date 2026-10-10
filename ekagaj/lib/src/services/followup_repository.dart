import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/backend_config.dart';
import '../models/followup_record.dart';
import '../models/notification_record.dart';
import '../routes/ek_routes.dart';
import 'notification_repository.dart';
import 'user_repository.dart';

sealed class FollowUpRepository {
  static const _collection = 'followups';

  static Stream<List<FollowUpRecord>> watchAll() {
    if (!BackendConfig.useFirebase) return Stream.value(const []);

    return FirebaseFirestore.instance
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => FollowUpRecord.fromDoc(d.id, d.data())).toList());
  }

  static Future<FollowUpRecord> add({
    required String clientName,
    required String contactPerson,
    required String nextFollowUp,
    required FollowUpStatus status,
    required String notes,
    required String createdBy,
    String? createdByName,
  }) async {
    final ref = FirebaseFirestore.instance.collection(_collection).doc();
    await ref.set({
      'clientName': clientName.trim(),
      'contactPerson': contactPerson.trim(),
      'nextFollowUp': nextFollowUp.trim(),
      'status': status.label,
      'notes': notes.trim(),
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (createdBy.isNotEmpty) {
      final authorName = createdByName?.trim().isNotEmpty == true
          ? createdByName!.trim()
          : await _displayNameFor(createdBy);
      await NotificationRepository.notifyTeamExcept(
        exceptUserId: createdBy,
        type: NotificationType.team,
        title: 'New Follow-up',
        message: '$authorName added follow-up for ${clientName.trim()}',
        route: EkRoutes.followUps,
      );
    }

    final snap = await ref.get();
    return FollowUpRecord.fromDoc(snap.id, snap.data() ?? {});
  }

  static Future<String> _displayNameFor(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection(UserRepository.usersCollection)
        .doc(userId)
        .get();
    return (doc.data()?['displayName'] as String?)?.trim() ?? 'A teammate';
  }

  static Future<void> updateStatus(String id, FollowUpStatus status) async {
    await FirebaseFirestore.instance.collection(_collection).doc(id).update({
      'status': status.label,
      if (status == FollowUpStatus.completed) 'completedAt': FieldValue.serverTimestamp(),
    });
  }
}
