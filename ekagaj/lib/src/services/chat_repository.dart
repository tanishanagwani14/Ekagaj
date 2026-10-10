import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/backend_config.dart';
import '../models/chat_models.dart';
import '../models/employee_record.dart';
import '../models/user_profile.dart';
import 'notification_repository.dart';
import 'user_repository.dart';

sealed class ChatRepository {
  static const chatsCollection = 'chats';

  static String directChatId(String uidA, String uidB) {
    final sorted = [uidA, uidB]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  static Stream<List<ChatThread>> watchInbox(String myUserId) {
    if (!BackendConfig.useFirebase || myUserId.isEmpty) {
      return Stream.value(const []);
    }

    return FirebaseFirestore.instance
        .collection(chatsCollection)
        .where('participantIds', arrayContains: myUserId)
        .snapshots()
        .map((snap) {
      final threads = snap.docs.map((d) => ChatThread.fromDoc(myUserId, d)).toList();
      threads.sort((a, b) {
        final aTime = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
      return threads;
    });
  }

  static Stream<List<ChatMessage>> watchMessages(String chatId, String myUserId) {
    if (!BackendConfig.useFirebase || chatId.isEmpty) {
      return Stream.value(const []);
    }

    return FirebaseFirestore.instance
        .collection(chatsCollection)
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ChatMessage.fromDoc(myUserId, d)).toList());
  }

  static Future<ChatThread> openDirectChat({
    required UserProfile me,
    required EmployeeRecord other,
  }) async {
    if (!BackendConfig.useFirebase) {
      throw StateError('Chat requires Firebase backend.');
    }

    final chatId = directChatId(me.id, other.id);
    final ref = FirebaseFirestore.instance.collection(chatsCollection).doc(chatId);
    final existing = await ref.get();

    if (!existing.exists) {
      await ref.set({
        'participantIds': [me.id, other.id],
        'participantNames': {
          me.id: me.displayName,
          other.id: other.displayName,
        },
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    final fresh = await ref.get();
    return ChatThread.fromDoc(me.id, fresh);
  }

  static Future<void> sendMessage({
    required String chatId,
    required UserProfile sender,
    required String text,
  }) async {
    if (!BackendConfig.useFirebase) return;

    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final firestore = FirebaseFirestore.instance;
    final chatRef = firestore.collection(chatsCollection).doc(chatId);
    final messageRef = chatRef.collection('messages').doc();

    final batch = firestore.batch();
    batch.set(messageRef, {
      'senderId': sender.id,
      'senderName': sender.displayName,
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(chatRef, {
      'lastMessage': trimmed,
      'lastMessageAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();

    for (final recipientId in _recipientIds(chatId, sender.id)) {
      await NotificationRepository.notifyChatMessage(
        recipientUserId: recipientId,
        senderName: sender.displayName,
        preview: trimmed,
      );
    }
  }

  static List<String> _recipientIds(String chatId, String senderId) {
    return chatId.split('_').where((id) => id.isNotEmpty && id != senderId).toList();
  }

  static Stream<List<EmployeeRecord>> watchContacts(String myUserId) {
    return FirebaseFirestore.instance.collection(UserRepository.usersCollection).snapshots().map((snap) {
      return snap.docs
          .map((d) => EmployeeRecord.fromMap(d.id, d.data()))
          .where((e) => e.id != myUserId && e.status == 'active')
          .toList()
        ..sort((a, b) => a.displayName.compareTo(b.displayName));
    });
  }
}
