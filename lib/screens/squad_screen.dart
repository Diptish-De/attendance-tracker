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

class _SquadScreenState extends State<SquadScreen> {
  @override
  Widget build(BuildContext context) {
    final squad = widget.store.activeSquad;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Squad Room & Friends',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Join via code, compare CIA & mass-bunk polls',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.safeBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
                          ),
                          tooltip: 'Create / Join Squad',
                          onPressed: () => _showJoinOrCreateSquadModal(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (squad == null)
                _buildNoSquadHero()
              else
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Squad Code Hero Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(squad.icon, style: const TextStyle(fontSize: 24)),
                                    const SizedBox(width: 8),
                                    Text(
                                      squad.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    '${squad.members.length} Members',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'INVITE ROOM CODE',
                                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.8),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        squad.code,
                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFFA3E635), letterSpacing: 3),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: squad.code));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Copied Squad Code: ${squad.code} 📋 Share it with your friends!'),
                                          backgroundColor: AppColors.safe,
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.textPrimary),
                                    label: const Text('Share Code', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ─── Live Mass-Bunk Polls ──────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '🗳️ Live Mass-Bunk Polls',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _showCreatePollDialog(context),
                            icon: const Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                            label: const Text('New Poll', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (squad.polls.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              'No active mass-bunk polls. Tap "New Poll" to start one!',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
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
                                        color: AppColors.safeBg,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        poll.subject,
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary),
                                      ),
                                    ),
                                    Text(
                                      'Started by ${poll.creator}',
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

                      const SizedBox(height: 18),

                      // ─── Squad Leaderboard & Peer Comparison ──────────────
                      const Text(
                        '🏆 Squad Leaderboard & Peer Intel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),

                      ...squad.members.map((member) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
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
                                    Text(
                                      member.name,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
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
                                  Row(
                                    children: [
                                      Text(
                                        '${member.attendancePct}%',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: member.attendancePct >= 75 ? AppColors.safe : AppColors.critical,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${member.estimatedSGPA.toStringAsFixed(2)} SGPA · 🔥${member.streak}d',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF7C3AED)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoSquadHero() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Text('🤝', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'Create or Join a Squad',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Share code with college classmates to coordinate mass bunks, sync schedules & track CIAs together.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showJoinOrCreateSquadModal(context),
            icon: const Icon(Icons.group_add_rounded, color: Colors.white),
            label: const Text('Join / Create Squad', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
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

  void _showJoinOrCreateSquadModal(BuildContext context) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

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
              'Squad Room Hub',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),

            // Join with Code
            const Text('Enter Friend\'s 6-Digit Squad Code:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
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
                          content: Text('Joined Squad ${codeCtrl.text.trim().toUpperCase()}! 🎉'),
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
                  child: Text('OR CREATE NEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'New Squad Name (e.g. CSE Backbenchers)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  widget.store.createSquad(nameCtrl.text.trim(), '🚀');
                  Navigator.pop(ctx);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Created ${nameCtrl.text.trim()}! Share code: ${widget.store.activeSquad?.code}'),
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
              child: const Text('Create New Squad & Get Code', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
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
}
