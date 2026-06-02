import 'package:flutter/material.dart';

import '../../theme/ek_colors.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/ek_badge.dart';
import '../../widgets/ek_card.dart';
import '../../widgets/gradient_header.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  _ViewMode viewMode = _ViewMode.list;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chats = const [
      _ChatListItem(id: 1, name: 'Team Alpha', lastMessage: 'Great work on the presentation!', time: '10:30 AM', unread: 3, isOnline: true),
      _ChatListItem(id: 2, name: 'John Smith', lastMessage: 'Can we schedule a meeting?', time: '9:45 AM', unread: 0, isOnline: true),
      _ChatListItem(id: 3, name: 'Marketing Team', lastMessage: 'Emily: The campaign is ready', time: 'Yesterday', unread: 5, isOnline: true),
      _ChatListItem(id: 4, name: 'Sarah Anderson', lastMessage: 'Thanks for the update', time: 'Yesterday', unread: 0, isOnline: false),
      _ChatListItem(id: 5, name: 'Dev Team', lastMessage: 'Alex: Bug fix deployed', time: 'May 6', unread: 1, isOnline: true),
    ];

    final messages = const [
      _Message(id: 1, sender: 'John Smith', text: "Hey, how's the project going?", time: '9:30 AM', isMe: false),
      _Message(id: 2, sender: 'Me', text: 'Going well! Almost done with the review.', time: '9:32 AM', isMe: true),
      _Message(id: 3, sender: 'John Smith', text: 'That’s great! Can we schedule a meeting for tomorrow?', time: '9:45 AM', isMe: false),
      _Message(id: 4, sender: 'Me', text: 'Sure, let me check my calendar', time: '9:46 AM', isMe: true),
    ];

    return Scaffold(
      body: Stack(
        children: [
          if (viewMode == _ViewMode.list)
            ListView(
              padding: EdgeInsets.zero,
              children: [
                GradientHeader(
                  colors: const [EkColors.blue500, EkColors.purple600],
                  bottomRadius: 0,
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
                          _HeaderIcon(icon: Icons.search_rounded, onTap: () {}),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search messages...',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.18),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
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
                        ...chats.map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EkCard(
                              onTap: () => setState(() => viewMode = _ViewMode.chat),
                              child: Row(
                                children: [
                                  _Avatar(letter: c.name.characters.first, online: c.isOnline),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(c.name, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: EkColors.gray800, fontWeight: FontWeight.w700)),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(c.time, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: EkColors.gray500)),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(c.lastMessage, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: EkColors.gray500)),
                                      ],
                                    ),
                                  ),
                                  if (c.unread > 0) ...[
                                    const SizedBox(width: 10),
                                    EkBadge('${c.unread}', variant: EkBadgeVariant.danger),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                GradientHeader(
                  colors: const [EkColors.blue500, EkColors.purple600],
                  bottomRadius: 0,
                  padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
                  child: Row(
                    children: [
                      _HeaderIcon(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => setState(() => viewMode = _ViewMode.list),
                      ),
                      const SizedBox(width: 12),
                      const _Avatar(letter: 'J', online: true, size: 40),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('John Smith', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                          Text('Online', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white.withValues(alpha: 0.7))),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
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
                            color: m.isMe ? null : Colors.white,
                            boxShadow: const [
                              BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 6)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!m.isMe)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(m.sender, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: EkColors.gray500)),
                                ),
                              Text(
                                m.text,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: m.isMe ? Colors.white : EkColors.gray800,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                m.time,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: m.isMe ? Colors.white.withValues(alpha: 0.7) : EkColors.gray400,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: EkColors.gray200)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.attach_file_rounded, color: EkColors.gray400),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              filled: true,
                              fillColor: EkColors.gray100,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.mic_none_rounded, color: EkColors.gray400),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [EkColors.blue500, EkColors.purple600]),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomNav(active: BottomNavItem.chat),
          ),
        ],
      ),
    );
  }
}

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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF60A5FA), Color(0xFFA855F7)],
            ),
          ),
          child: Center(
            child: Text(
              letter,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
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

enum _ViewMode { list, chat }

class _ChatListItem {
  const _ChatListItem({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.isOnline,
  });

  final int id;
  final String name;
  final String lastMessage;
  final String time;
  final int unread;
  final bool isOnline;
}

class _Message {
  const _Message({
    required this.id,
    required this.sender,
    required this.text,
    required this.time,
    required this.isMe,
  });

  final int id;
  final String sender;
  final String text;
  final String time;
  final bool isMe;
}

