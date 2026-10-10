import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/chat_models.dart';
import '../../models/employee_record.dart';
import '../../models/user_profile.dart';
import '../../services/app_session.dart';
import '../../services/chat_repository.dart';
import '../../theme/ek_colors.dart';
import '../../theme/ek_theme_context.dart';
import '../../widgets/auth_gate.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/ek_card.dart';
import '../../widgets/ek_fab.dart';
import '../../widgets/gradient_header.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  _ViewMode _viewMode = _ViewMode.list;
  final _messageController = TextEditingController();
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  final _messageFocus = FocusNode();
  final _messageScrollController = ScrollController();

  ChatThread? _activeChat;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    _messageFocus.dispose();
    _messageScrollController.dispose();
    super.dispose();
  }

  UserProfile? get _me => AppSession.profile.value;

  List<ChatThread> _filterThreads(List<ChatThread> threads) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return threads;
    return threads
        .where(
          (c) =>
              c.title.toLowerCase().contains(query) ||
              c.lastMessage.toLowerCase().contains(query),
        )
        .toList();
  }

  void _openChat(ChatThread chat) {
    setState(() {
      _activeChat = chat;
      _viewMode = _ViewMode.chat;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
      _messageFocus.requestFocus();
    });
  }

  void _closeChat() {
    setState(() {
      _viewMode = _ViewMode.list;
      _activeChat = null;
      _messageController.clear();
    });
  }

  void _scrollToBottom() {
    if (!_messageScrollController.hasClients) return;
    _messageScrollController.animateTo(
      _messageScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _sendMessage() async {
    final me = _me;
    final chat = _activeChat;
    final text = _messageController.text.trim();
    if (me == null || chat == null || text.isEmpty || _sending) return;

    setState(() => _sending = true);
    _messageController.clear();
    try {
      await ChatRepository.sendMessage(chatId: chat.id, sender: me, text: text);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send message: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _showNewChatDialog() async {
    final me = _me;
    if (me == null) return;

    final picked = await showDialog<EmployeeRecord>(
      context: context,
      builder: (dialogContext) => _PickContactDialog(myUserId: me.id),
    );
    if (picked == null || !mounted) return;

    try {
      final thread = await ChatRepository.openDirectChat(me: me, other: picked);
      _openChat(thread);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not start chat: $e')),
        );
      }
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(time.year, time.month, time.day);
    if (day == today) return DateFormat.jm().format(time);
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat.MMMd().format(time);
  }

  @override
  Widget build(BuildContext context) {
    final me = _me;
    final textPrimary = context.ekTextPrimary;
    final textSecondary = context.ekTextSecondary;
    final activeChat = _activeChat;

    if (me == null) {
      return const SessionSignInPrompt(
        title: 'Sign in to use Messages',
        message:
            'Your session is missing or expired. Tap below to open the login page and sign in again.',
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          if (_viewMode == _ViewMode.list)
            StreamBuilder<List<ChatThread>>(
              stream: ChatRepository.watchInbox(me.id),
              builder: (context, snap) {
                final threads = _filterThreads(snap.data ?? const []);
                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    GradientHeader(
                      colors: const [EkColors.blue500, EkColors.purple600],
                      bottomRadius: 40,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Messages',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              Row(
                                children: [
                                  _HeaderIcon(icon: Icons.add_comment_outlined, onTap: _showNewChatDialog),
                                  const SizedBox(width: 8),
                                  _HeaderIcon(icon: Icons.search_rounded, onTap: () => _searchFocus.requestFocus()),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _searchController,
                            focusNode: _searchFocus,
                            decoration: InputDecoration(
                              hintText: 'Search messages...',
                              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.18),
                              prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.8)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                      child: snap.connectionState == ConnectionState.waiting && threads.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : threads.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 32),
                                  child: Text(
                                    'No conversations yet. Tap + to message a teammate.',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textSecondary),
                                  ),
                                )
                              : Column(
                                  children: threads
                                      .map(
                                        (c) => Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: EkCard(
                                            onTap: () => _openChat(c),
                                            child: Row(
                                              children: [
                                                _Avatar(letter: _initial(c.title), online: true),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              c.title,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                                    color: textPrimary,
                                                                    fontWeight: FontWeight.w700,
                                                                  ),
                                                            ),
                                                          ),
                                                          Text(
                                                            _formatTime(c.lastMessageAt),
                                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: textSecondary),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        c.lastMessage.isEmpty ? 'Start chatting' : c.lastMessage,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                    ),
                  ],
                );
              },
            )
          else
            Column(
              children: [
                GradientHeader(
                  colors: const [EkColors.blue500, EkColors.purple600],
                  bottomRadius: 40,
                  padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
                  child: Row(
                    children: [
                      _HeaderIcon(icon: Icons.arrow_back_rounded, onTap: _closeChat),
                      const SizedBox(width: 12),
                      _Avatar(letter: _initial(activeChat?.title ?? '?'), online: true, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeChat?.title ?? 'Chat',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            Text(
                              'Live chat',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<ChatMessage>>(
                    stream: ChatRepository.watchMessages(activeChat?.id ?? '', me.id),
                    builder: (context, snap) {
                      final messages = snap.data ?? const [];
                      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                      if (messages.isEmpty) {
                        return Center(
                          child: Text(
                            'No messages yet.\nSay hello!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textSecondary),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _messageScrollController,
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final m = messages[index];
                          return Align(
                            alignment: m.isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 320),
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: m.isMe
                                    ? const LinearGradient(colors: [EkColors.blue500, EkColors.purple600])
                                    : null,
                                color: m.isMe ? null : context.ekCardSurface,
                                border: m.isMe
                                    ? null
                                    : Border.all(color: context.isDark ? const Color(0xFF374151) : EkColors.gray200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!m.isMe)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        m.senderName,
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: textSecondary),
                                      ),
                                    ),
                                  Text(
                                    m.text,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: m.isMe ? Colors.white : textPrimary,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _formatTime(m.createdAt),
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: m.isMe ? Colors.white.withValues(alpha: 0.7) : textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: BoxDecoration(
                    color: context.ekNavBarSurface,
                    border: Border(top: BorderSide(color: context.ekNavBarBorder)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            focusNode: _messageFocus,
                            minLines: 1,
                            maxLines: 4,
                            onSubmitted: (_) => _sendMessage(),
                            style: TextStyle(color: textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              filled: true,
                              fillColor: context.ekInputFill,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _sending ? null : _sendMessage,
                          icon: _sending
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.send_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          if (_viewMode == _ViewMode.list) ...[
            EkFab(onPressed: _showNewChatDialog, bottom: MediaQuery.paddingOf(context).bottom + 128),
            const Align(
              alignment: Alignment.bottomCenter,
              child: BottomNav(active: BottomNavItem.chat),
            ),
          ],
        ],
      ),
    );
  }

  static String _initial(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }
}

class _PickContactDialog extends StatelessWidget {
  const _PickContactDialog({required this.myUserId});

  final String myUserId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Message'),
      content: SizedBox(
        width: double.maxFinite,
        child: StreamBuilder<List<EmployeeRecord>>(
          stream: ChatRepository.watchContacts(myUserId),
          builder: (context, snap) {
            final contacts = snap.data ?? const [];
            if (contacts.isEmpty) {
              return const Text('No teammates found. Ask admin to add employees.');
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final c = contacts[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(c.displayName.characters.first)),
                  title: Text(c.displayName),
                  subtitle: Text(c.department),
                  onTap: () => Navigator.of(context).pop(c),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
      ],
    );
  }
}

enum _ViewMode { list, chat }

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.onTap});

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
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.letter, required this.online, this.size = 48});

  final String letter;
  final bool online;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [Color(0xFF60A5FA), Color(0xFFA855F7)]),
          ),
          child: Center(
            child: Text(letter, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * 0.38)),
          ),
        ),
        if (online)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
