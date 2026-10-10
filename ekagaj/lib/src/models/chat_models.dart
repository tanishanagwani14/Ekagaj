import 'package:cloud_firestore/cloud_firestore.dart';

class ChatThread {
  const ChatThread({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.participantIds,
    required this.otherUserId,
    required this.otherDisplayName,
  });

  final String id;
  final String title;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final List<String> participantIds;
  final String otherUserId;
  final String otherDisplayName;

  factory ChatThread.fromDoc(String myUserId, DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final participantIds = List<String>.from(data['participantIds'] as List? ?? []);
    final names = Map<String, dynamic>.from(data['participantNames'] as Map? ?? {});
    final otherId = participantIds.firstWhere((id) => id != myUserId, orElse: () => '');
    final otherName = (names[otherId] as String?)?.trim();
    final title = otherName?.isNotEmpty == true ? otherName! : 'Chat';

    return ChatThread(
      id: doc.id,
      title: title,
      lastMessage: (data['lastMessage'] as String?)?.trim() ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      participantIds: participantIds,
      otherUserId: otherId,
      otherDisplayName: title,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
    required this.isMe,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime? createdAt;
  final bool isMe;

  factory ChatMessage.fromDoc(String myUserId, DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final senderId = (data['senderId'] as String?) ?? '';
    return ChatMessage(
      id: doc.id,
      senderId: senderId,
      senderName: (data['senderName'] as String?)?.trim() ?? 'User',
      text: (data['text'] as String?)?.trim() ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      isMe: senderId == myUserId,
    );
  }
}
