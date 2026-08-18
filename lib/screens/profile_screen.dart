import 'package:flutter/material.dart';
import '../services/attendance_store.dart';
import '../theme/colors.dart';

class ProfileScreen extends StatefulWidget {
  final AttendanceDataStore store;
  final VoidCallback onOpenMarks;
  final VoidCallback onOpenLeaves;
  final VoidCallback onOpenSquad;

  const ProfileScreen({
    super.key,
    required this.store,
    required this.onOpenMarks,
    required this.onOpenLeaves,
    required this.onOpenSquad,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final overallPct = widget.store.overallPercentage;
    final achievements = widget.store.achievements;
    final unlockedCount = achievements.where((a) => a.unlocked).length;
    final currentMonthIndex = DateTime.now().month;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (Navigator.canPop(context))
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                            onPressed: () => Navigator.pop(context),
                          ),
                        const Text(
                          'Profile & Student Center',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: AppColors.textSecondary, size: 20),
                      onPressed: () => _showEditProfileDialog(context),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => _showAvatarPicker(context),
                            child: Stack(
                              children: [
                                Container(
                                  width: 76,
                                  height: 76,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [Color(0xFFA3E635), Color(0xFF22C55E)],
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(widget.store.studentAvatar, style: const TextStyle(fontSize: 38)),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.store.studentName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.store.degree,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDE9FE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.store.course,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF7C3AED)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.store.semester,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFD97706)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildPill('Overall', '$overallPct%', AppColors.safe, AppColors.safeBg),
                              const SizedBox(width: 8),
                              _buildPill('Credits', '${widget.store.totalCredits}', const Color(0xFF3B82F6), const Color(0xFFDBEAFE)),
                              const SizedBox(width: 8),
                              _buildPill('Badges', '$unlockedCount/${achievements.length}', AppColors.caution, AppColors.cautionBg),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ─── Academic Hub & Records ──────────────────────────────
                    const Text(
                      'Student Records & Management',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: widget.onOpenMarks,
                            child: Container(
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEDE9FE),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.grade_rounded, color: Color(0xFF7C3AED), size: 20),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Exam Marks & SGPA',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${widget.store.cumulativeGPA.toStringAsFixed(2)} SGPA (${widget.store.marks.length} Subjects)',
                                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: widget.onOpenLeaves,
                            child: Container(
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDBEAFE),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.calendar_month_rounded, color: Color(0xFF3B82F6), size: 20),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Leave Applications',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${widget.store.leaveHistory.length} Past Requests',
                                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Squad Room card in profile
                    GestureDetector(
                      onTap: widget.onOpenSquad,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text('🚀', style: TextStyle(fontSize: 18)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.store.activeSquad != null
                                        ? '${widget.store.activeSquad!.name} (Room: ${widget.store.activeSquad!.code})'
                                        : 'Join or Create Squad Room',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                                  ),
                                  Text(
                                    widget.store.activeSquad != null
                                        ? '${widget.store.activeSquad!.members.length} Squad Members Connected'
                                        : 'Share codes with friends for mass-bunk polls',
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Semester Campaign Map
                    const Text(
                      'Semester Strategy Campaign',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _buildCampaignStep('⛺', 'August', 'Base Camp', currentMonthIndex > 8, currentMonthIndex == 8),
                          _buildCampaignStep('📚', 'September', 'Regular Season', currentMonthIndex > 9, currentMonthIndex == 9),
                          _buildCampaignStep('🎉', 'October', 'Festival Expansion Arc', currentMonthIndex > 10, currentMonthIndex == 10),
                          _buildCampaignStep('⚔️', 'November', 'Survival Arc', currentMonthIndex > 11, currentMonthIndex == 11),
                          _buildCampaignStep('💀', 'December', 'Final Boss Exams', currentMonthIndex > 12, currentMonthIndex == 12, isLast: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Achievements Section
                    const Text(
                      'Achievements & Badges',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap a locked badge to unlock it',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: achievements.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.1,
                      ),
                      itemBuilder: (context, i) {
                        final a = achievements[i];
                        return GestureDetector(
                          onTap: () {
                            if (!a.unlocked) {
                              widget.store.unlockAchievement(a.id);
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Unlocked badge: ${a.title}! ⭐'),
                                  backgroundColor: AppColors.caution,
                                ),
                              );
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: a.unlocked ? const Color(0xFFFBBF24) : const Color(0xFFE2E8F0),
                                width: a.unlocked ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.icon, style: const TextStyle(fontSize: 26)),
                                const SizedBox(height: 6),
                                Text(
                                  a.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  a.desc,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                Text(
                                  a.unlocked ? '★ UNLOCKED' : 'Tap to unlock',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: a.unlocked ? AppColors.caution : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: widget.store.studentName);
    final degCtrl = TextEditingController(text: widget.store.degree);
    final crsCtrl = TextEditingController(text: widget.store.course);
    String selectedSem = widget.store.semester;

    final semestersList = [
      'Semester 1',
      'Semester 2',
      'Semester 3',
      'Semester 4',
      'Semester 5',
      'Semester 6',
      'Semester 7',
      'Semester 8',
    ];

    if (!semestersList.contains(selectedSem)) {
      semestersList.add(selectedSem);
    }

    DateTime tempStart = widget.store.semesterStartDate;
    DateTime tempEnd = widget.store.semesterEndDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Edit Academic Profile', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Student Name',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: degCtrl,
                        decoration: InputDecoration(
                          labelText: 'Degree',
                          hintText: 'e.g. B.Tech, B.Sc, BCA',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: TextField(
                        controller: crsCtrl,
                        decoration: InputDecoration(
                          labelText: 'Course / Branch',
                          hintText: 'e.g. CSE, ECE, IT',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedSem,
                  decoration: InputDecoration(
                    labelText: 'Current Semester',
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: semestersList
                      .map((sem) => DropdownMenuItem(value: sem, child: Text(sem)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedSem = val);
                    }
                  },
                ),
                const SizedBox(height: 14),
                const Text('Semester Dates Timeline', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: tempStart,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setDialogState(() => tempStart = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Start Date', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text('${tempStart.day}/${tempStart.month}/${tempStart.year}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: tempEnd,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setDialogState(() => tempEnd = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('End Date', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text('${tempEnd.day}/${tempEnd.month}/${tempEnd.year}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                widget.store.updateProfile(
                  nameCtrl.text.trim(),
                  deg: degCtrl.text.trim().isEmpty ? 'B.Tech' : degCtrl.text.trim(),
                  crs: crsCtrl.text.trim().isEmpty ? 'CSE' : crsCtrl.text.trim(),
                  sem: selectedSem,
                );
                widget.store.updateSemesterDates(tempStart, tempEnd);
                Navigator.pop(ctx);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Academic profile updated! 🎓'),
                    backgroundColor: AppColors.safe,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Save Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarPicker(BuildContext context) {
    final avatars = [
      '🎓', '🧑', '🧑‍🎓', '👨‍🎓', '👩‍🎓', '🦁', '🦊', '🐼', '🐨', '🐯', 
      '🦖', '👾', '🤖', '🚀', '⭐', '🌈', '⚽', '🎮', '🍕', 
      '☕', '📚', '👑', '🍀', '🦄', '🎸', '🧁', '🍉', '🎈', '🎨'
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Profile Avatar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: avatars.length,
                  itemBuilder: (context, index) {
                    final av = avatars[index];
                    final isSelected = widget.store.studentAvatar == av;
                    return GestureDetector(
                      onTap: () {
                        widget.store.updateProfile(
                          widget.store.studentName,
                          avatar: av,
                        );
                        Navigator.pop(context);
                        setState(() {});
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            av,
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPill(String label, String val, Color c, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              val,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: c,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: c,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignStep(
      String icon, String month, String title, bool done, bool active,
      {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: done
                    ? AppColors.primary
                    : active
                        ? AppColors.safeBg
                        : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 18)),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 24,
                color: done ? AppColors.primary : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: done || active
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      month,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (done)
                  const Text(
                    'DONE ✓',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                if (active)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.safeBg,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      'CURRENT',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
