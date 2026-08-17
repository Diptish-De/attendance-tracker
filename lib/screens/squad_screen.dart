import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/attendance_store.dart';
import '../theme/colors.dart';

class SquadScreen extends StatefulWidget {
  final AttendanceDataStore store;

  const SquadScreen({super.key, required this.store});

  @override
  State<SquadScreen> createState() => _SquadScreenState();
}

class _SquadScreenState extends State<SquadScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _chatInputCtrl = TextEditingController();
  final ScrollController _chatScrollCtrl = ScrollController();

  final List<String> _roomIcons = ['🚀', '🔥', '🍕', '🎮', '⚡', '📚', '☕', '💻', '👑', '🧪'];
  final List<Map<String, String>> _roomThemes = [
    {'name': 'Emerald', 'hex': '#22C55E'},
    {'name': 'Royal Purple', 'hex': '#8B5CF6'},
    {'name': 'Sky Blue', 'hex': '#3B82F6'},
    {'name': 'Amber Sunset', 'hex': '#F59E0B'},
    {'name': 'Rose Pink', 'hex': '#EC4899'},
    {'name': 'Cyber Teal', 'hex': '#14B8A6'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatInputCtrl.dispose();
    _chatScrollCtrl.dispose();
    super.dispose();
  }

  Color _parseHex(String hex, {Color fallback = const Color(0xFF22C55E)}) {
    try {
      final clean = hex.replaceFirst('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollCtrl.hasClients) {
        _chatScrollCtrl.animateTo(
          _chatScrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final squadList = widget.store.squadGroups;
    final activeSquad = widget.store.activeSquad;
    final themeColor = activeSquad != null ? _parseHex(activeSquad.themeColorHex) : AppColors.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top App Header & Multi-Room Selector ──────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 22),
                            tooltip: 'Back',
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 4),
                          // Active Room Picker Pill Button
                          GestureDetector(
                            onTap: () => _showRoomSwitchSheet(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: themeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: themeColor.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(activeSquad?.icon ?? '🚀', style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 140),
                                    child: Text(
                                      activeSquad?.name ?? 'Select Room',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: themeColor,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.keyboard_arrow_down_rounded, color: themeColor, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Room Quick Actions (Customization & Add/Join)
                      Row(
                        children: [
                          if (activeSquad != null)
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.tune_rounded, color: AppColors.textPrimary, size: 18),
                              ),
                              tooltip: 'Customize Chat Room',
                              onPressed: () => _showCustomizeRoomModal(context, activeSquad),
                            ),
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: themeColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                            ),
                            tooltip: 'Join / Create Room',
                            onPressed: () => _showJoinOrCreateSquadModal(context),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Room Code Pill & Topic Header
                  if (activeSquad != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'ROOM ${activeSquad.code}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFA3E635),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    activeSquad.description,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: activeSquad.code));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Copied code: ${activeSquad.code} 📋 Share it with friends!'),
                                  backgroundColor: themeColor,
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Icon(Icons.copy_rounded, size: 14, color: themeColor),
                                const SizedBox(width: 4),
                                Text(
                                  'Share',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: themeColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Room Tabs: Live Chat, Bunk Polls, Leaderboard
                  Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ],
                      ),
                      labelColor: themeColor,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.chat_bubble_outline_rounded, size: 14),
                              const SizedBox(width: 6),
                              Text('Chat (${activeSquad?.messages.length ?? 0})'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.how_to_vote_rounded, size: 14),
                              const SizedBox(width: 6),
                              Text('Bunk Polls (${activeSquad?.polls.length ?? 0})'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.leaderboard_rounded, size: 14),
                              const SizedBox(width: 6),
                              Text('Squad (${activeSquad?.members.length ?? 0})'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ─── Main Content Tabs ─────────────────────────────────────────
            Expanded(
              child: activeSquad == null
                  ? _buildNoSquadHero()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Focused Live Chat
                        _buildLiveChatTab(activeSquad, themeColor),

                        // Tab 2: Bunk Polls
                        _buildPollsTab(activeSquad, themeColor),

                        // Tab 3: Squad Members Intel & Leaderboard
                        _buildLeaderboardTab(activeSquad, themeColor),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── TAB 1: Live Chat UI ───────────────────────────────────────────────────
  Widget _buildLiveChatTab(SquadGroup squad, Color themeColor) {
    return Column(
      children: [
        // Messages Feed
        Expanded(
          child: squad.messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(squad.icon, style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: 10),
                      Text(
                        'Welcome to ${squad.name}!',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Drop a message or proxy check update below.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _chatScrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: squad.messages.length,
                  itemBuilder: (context, idx) {
                    final msg = squad.messages[idx];
                    final isMe = msg.senderId == 'me';

                    if (msg.isSystem) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              msg.text,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                            ),
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe) ...[
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: Text(msg.senderAvatar, style: const TextStyle(fontSize: 16)),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                if (!isMe)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                                    child: Text(
                                      msg.senderName,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                                    ),
                                  ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isMe ? themeColor : Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                                      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        msg.text,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isMe ? Colors.white : AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        msg.timestamp,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: isMe ? Colors.white.withValues(alpha: 0.7) : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 8),
                            const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: Text('🎓', style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),

        // Quick Preset Bunk Broadcast Bar
        Container(
          height: 36,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildQuickPill('🚨 Proxy Check alert!', themeColor),
              const SizedBox(width: 8),
              _buildQuickPill('🍕 Anyone for Canteen?', themeColor),
              const SizedBox(width: 8),
              _buildQuickPill('📚 In Library studying', themeColor),
              const SizedBox(width: 8),
              _buildQuickPill('📝 Notes drive updated', themeColor),
            ],
          ),
        ),

        // Chat Input Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatInputCtrl,
                  decoration: InputDecoration(
                    hintText: 'Message #${squad.name}...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      widget.store.sendSquadMessage(val.trim());
                      _chatInputCtrl.clear();
                      setState(() {});
                      _scrollToBottom();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 20,
                backgroundColor: themeColor,
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  onPressed: () {
                    if (_chatInputCtrl.text.trim().isNotEmpty) {
                      widget.store.sendSquadMessage(_chatInputCtrl.text.trim());
                      _chatInputCtrl.clear();
                      setState(() {});
                      _scrollToBottom();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPill(String text, Color themeColor) {
    return GestureDetector(
      onTap: () {
        widget.store.sendSquadMessage(text);
        setState(() {});
        _scrollToBottom();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Center(
          child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  // ─── TAB 2: Live Bunk Polls UI ─────────────────────────────────────────────
  Widget _buildPollsTab(SquadGroup squad, Color themeColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Bunk Polls',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreatePollDialog(context),
                icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                label: const Text('Start Poll', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (squad.polls.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text('No active mass-bunk polls in this room. Tap "Start Poll" to coordinate with your squad!'),
              ),
            )
          else
            ...squad.polls.map((poll) {
              final totalVotes = poll.bunkVotes + poll.attendVotes;
              final bunkPct = totalVotes == 0 ? 0 : ((poll.bunkVotes / totalVotes) * 100).round();

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            poll.subject,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: themeColor),
                          ),
                        ),
                        Text(
                          'Created by ${poll.creator}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      poll.question,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),

                    // Vote Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: totalVotes == 0 ? 0.5 : (poll.bunkVotes / totalVotes),
                        minHeight: 10,
                        backgroundColor: AppColors.safe,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.danger),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '🔥 ${poll.bunkVotes} Bunking ($bunkPct%)',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.danger),
                        ),
                        Text(
                          '📚 ${poll.attendVotes} Attending (${100 - bunkPct}%)',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.safe),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Action Vote Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              widget.store.voteBunkPoll(poll.id, true);
                              setState(() {});
                            },
                            icon: const Icon(Icons.cancel_rounded, size: 16, color: Colors.white),
                            label: const Text("I'm Bunking! 🍕", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: poll.userVotedBunk ? AppColors.critical : const Color(0xFFF97316),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              widget.store.voteBunkPoll(poll.id, false);
                              setState(() {});
                            },
                            icon: const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.safe),
                            label: const Text("I'll Attend 📚", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.safe)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: poll.userVotedAttend ? AppColors.safe : const Color(0xFFCBD5E1), width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ─── TAB 3: Squad Members Intel & Leaderboard ──────────────────────────────
  Widget _buildLeaderboardTab(SquadGroup squad, Color themeColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [themeColor, themeColor.withValues(alpha: 0.8)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SQUAD ATTENDANCE HEALTH',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white70),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${squad.members.length} Friends in #${squad.name}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  squad.category,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        ...squad.members.map((member) {
          final isMe = member.id == 'me';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: isMe ? Border.all(color: themeColor, width: 2) : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(member.avatar, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            member.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                          ),
                          if (isMe)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: themeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('YOU', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: themeColor)),
                            ),
                        ],
                      ),
                      Text(
                        member.statusMessage,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${member.attendancePct}%',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: member.attendancePct >= 75 ? AppColors.safe : AppColors.critical,
                      ),
                    ),
                    Text(
                      '${member.estimatedSGPA.toStringAsFixed(2)} SGPA · 🔥${member.streak}d',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: themeColor),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ─── Modal 1: Switch Multi-Rooms Sheet ───────────────────────────────────────
  void _showRoomSwitchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Connected Rooms',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ...widget.store.squadGroups.map((s) {
              final isSelected = s.id == widget.store.activeSquad?.id;
              final roomColor = _parseHex(s.themeColorHex);

              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: isSelected ? roomColor.withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
                leading: Text(s.icon, style: const TextStyle(fontSize: 24)),
                title: Text(s.name, style: TextStyle(fontWeight: FontWeight.w900, color: isSelected ? roomColor : AppColors.textPrimary)),
                subtitle: Text('Code: ${s.code} · ${s.category} · ${s.members.length} members', style: const TextStyle(fontSize: 11)),
                trailing: isSelected ? Icon(Icons.check_circle_rounded, color: roomColor) : const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  widget.store.switchSquad(s.id);
                  Navigator.pop(ctx);
                  setState(() {});
                },
              );
            }),

            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _showJoinOrCreateSquadModal(context);
              },
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Join Another Room / Create New', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Modal 2: Highly Customizable Room Settings ────────────────────────────
  void _showCustomizeRoomModal(BuildContext context, SquadGroup squad) {
    final nameCtrl = TextEditingController(text: squad.name);
    final descCtrl = TextEditingController(text: squad.description);
    String selectedIcon = squad.icon;
    String selectedColor = squad.themeColorHex;
    String selectedCategory = squad.category;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Room Customization 🎨', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 14),

                // Icon Picker
                const Text('Choose Room Icon:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _roomIcons.map((ic) {
                    final isSel = ic == selectedIcon;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedIcon = ic),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFFE2E8F0) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSel ? AppColors.primary : Colors.transparent, width: 2),
                        ),
                        child: Text(ic, style: const TextStyle(fontSize: 22)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // Theme Color Picker
                const Text('Choose Room Accent Color:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _roomThemes.map((th) {
                    final hex = th['hex']!;
                    final isSel = hex == selectedColor;
                    final c = _parseHex(hex);
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedColor = hex),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: isSel ? Border.all(color: Colors.black, width: 3) : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Room Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Room Topic / Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        widget.store.deleteSquad(squad.id);
                        Navigator.pop(ctx);
                        setState(() {});
                      },
                      icon: const Icon(Icons.logout_rounded, color: AppColors.critical, size: 18),
                      label: const Text('Leave Room', style: TextStyle(color: AppColors.critical)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.critical),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.store.updateSquadDetails(
                            squad.id,
                            name: nameCtrl.text.trim(),
                            icon: selectedIcon,
                            description: descCtrl.text.trim(),
                            colorHex: selectedColor,
                          );
                          Navigator.pop(ctx);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Room settings saved! ✨'), backgroundColor: AppColors.safe),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _parseHex(selectedColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Save Customization', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Modal 3: Join or Create Room ──────────────────────────────────────────
  void _showJoinOrCreateSquadModal(BuildContext context) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    String selectedCat = 'Classroom / Batch';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Join or Create Room',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),

            // Join with Code
            const Text('Enter Friend\'s 6-Digit Room Code:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: codeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'e.g. BUNK42',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (codeCtrl.text.trim().isNotEmpty) {
                      widget.store.joinSquad(codeCtrl.text.trim());
                      Navigator.pop(ctx);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Joined Room ${codeCtrl.text.trim().toUpperCase()}! 🎉'),
                          backgroundColor: AppColors.safe,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  ),
                  child: const Text('Join', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('OR CREATE NEW ROOM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Room Name (e.g. CSE Backbenchers)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: selectedCat,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: 'Classroom / Batch', child: Text('Classroom / Batch')),
                DropdownMenuItem(value: 'Hostel / Flat', child: Text('Hostel / Flat')),
                DropdownMenuItem(value: 'Project Team', child: Text('Project Team')),
                DropdownMenuItem(value: 'Exam Study Group', child: Text('Exam Study Group')),
              ],
              onChanged: (val) {
                if (val != null) selectedCat = val;
              },
            ),
            const SizedBox(height: 14),

            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  widget.store.createSquad(nameCtrl.text.trim(), '🚀', category: selectedCat);
                  Navigator.pop(ctx);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Created ${nameCtrl.text.trim()}! Code: ${widget.store.activeSquad?.code}'),
                      backgroundColor: AppColors.safe,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Create Room & Get Share Code', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePollDialog(BuildContext context) {
    final qCtrl = TextEditingController();
    String selectedSubject = widget.store.subjects.isNotEmpty ? widget.store.subjects.first.name : 'General';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Create Mass-Bunk Poll 🗳️', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qCtrl,
              decoration: const InputDecoration(
                labelText: 'Poll Question / Plan',
                hintText: 'e.g. Mass bunk Friday 3rd period for canteen?',
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedSubject,
              decoration: const InputDecoration(labelText: 'Subject'),
              items: widget.store.subjects.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name))).toList(),
              onChanged: (val) {
                if (val != null) selectedSubject = val;
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (qCtrl.text.trim().isNotEmpty) {
                widget.store.addBunkPoll(qCtrl.text.trim(), selectedSubject);
                Navigator.pop(ctx);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Poll published to your Squad! 🚀'), backgroundColor: AppColors.safe),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Post Poll', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSquadHero() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🤝', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'Create or Join a Chat Room',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Share codes with classmates to chat, coordinate mass bunks, and sync notes in dedicated rooms.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showJoinOrCreateSquadModal(context),
            icon: const Icon(Icons.group_add_rounded, color: Colors.white),
            label: const Text('Join / Create Room', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
