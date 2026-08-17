import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/attendance_store.dart';
import '../theme/colors.dart';
import '../widgets/painters.dart';

class DashboardScreen extends StatefulWidget {
  final AttendanceDataStore store;
  final VoidCallback onSeeAllSubjects;
  final VoidCallback onSeeAllRoutine;
  final VoidCallback onOpenMarks;
  final VoidCallback onOpenLeaves;
  final VoidCallback onOpenSquad;
  final VoidCallback onOpenProfile;
  final VoidCallback onShowNotifications;
  final VoidCallback onShowStreak;
  final Function(String subjectId) onSelectSubject;

  const DashboardScreen({
    super.key,
    required this.store,
    required this.onSeeAllSubjects,
    required this.onSeeAllRoutine,
    required this.onOpenMarks,
    required this.onOpenLeaves,
    required this.onOpenSquad,
    required this.onOpenProfile,
    required this.onShowNotifications,
    required this.onShowStreak,
    required this.onSelectSubject,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DateTime _selectedDate;
  final List<String> _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  String _getDayName(DateTime dt) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dt.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final overallPct = store.overallPercentage;
    final totalSkips = store.totalSafeSkips;
    final overallRisk = store.overallRisk;
    final subjects = store.subjects;
    
    final selectedDayName = _getDayName(_selectedDate);
    final isToday = _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day;
    final dayRoutine = store.getRoutineForDay(selectedDayName);
    final selectedDateStr = _formatDate(_selectedDate);

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
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: widget.onOpenProfile,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFFA3E635), Color(0xFF22C55E)],
                                ),
                              ),
                              child: const Center(
                                child: Text('🎓', style: TextStyle(fontSize: 22)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Hi, ${store.studentName} 👋',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textSecondary),
                                  ],
                                ),
                                Text(
                                  store.academicDetailsFormatted,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        // Compact Overall Attendance Pill Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.getRiskBg(overallRisk),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.getRiskColor(overallRisk).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.getRiskColor(overallRisk),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$overallPct%',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.getRiskColor(overallRisk),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Overall',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.getRiskColor(overallRisk).withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          onPressed: widget.onShowNotifications,
                          icon: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFF1F5F9),
                                ),
                                child: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: Color(0xFF64748B),
                                  size: 20,
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Subject Overview (Top Header) ────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subject Overview',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: widget.onSeeAllSubjects,
                          child: const Text(
                            'See All',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Horizontal Subject List
                    SizedBox(
                      height: 135,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: subjects.length,
                        itemBuilder: (context, index) {
                          final s = subjects[index];
                          final color = AppColors.getRiskColor(s.risk);
                          final bg = AppColors.getRiskBg(s.risk);
                          return GestureDetector(
                            onTap: () => widget.onSelectSubject(s.id),
                            child: Container(
                              width: 105,
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  DonutWidget(
                                    percentage: s.percentage,
                                    color: color,
                                    size: 52,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    s.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: bg,
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: Text(
                                      '${s.safeSkips} skips',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ─── Single Row 3-Stats Bar ──────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'SAFE SKIPS',
                            '$totalSkips',
                            '🎯',
                            AppColors.safe,
                            AppColors.safeBg,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'TEACHING DAYS',
                            '${store.teachingDaysLeft}',
                            '📅',
                            const Color(0xFF3B82F6),
                            const Color(0xFFDBEAFE),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'PROGRESS',
                            '${store.semesterProgress.round()}%',
                            '📈',
                            const Color(0xFFF97316),
                            const Color(0xFFFFEDD5),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ─── Quick Academic & Leave Hub Cards ────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: widget.onOpenMarks,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEDE9FE),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.grade_rounded, color: Color(0xFF7C3AED), size: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'SGPA & Marks',
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                        ),
                                        Text(
                                          '${store.cumulativeGPA.toStringAsFixed(2)} / 10.0',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF7C3AED)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 18),
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
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDBEAFE),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.calendar_month_rounded, color: Color(0xFF3B82F6), size: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Leaves Hub',
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                        ),
                                        Text(
                                          '${store.leaveCategories.fold<int>(0, (a, b) => a + b.available)} days left',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF3B82F6)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Squad Room Banner
                    GestureDetector(
                      onTap: widget.onOpenSquad,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text('🚀', style: TextStyle(fontSize: 20)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    store.activeSquad != null ? store.activeSquad!.name : 'Join Class Squad Room',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white),
                                  ),
                                  Text(
                                    store.activeSquad != null
                                        ? 'Room Code: ${store.activeSquad!.code} · ${store.activeSquad!.members.length} Friends Online'
                                        : 'Coordinate mass bunks & share timetables with code',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFA3E635),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: const Text(
                                'Squad Room',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ─── Interactive Date/Day Quick Attendance Widget ────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        isToday ? "Today's Attendance" : "Attendance for $selectedDayName",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (isToday) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.safeBg,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'LIVE TODAY',
                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.primary),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    selectedDateStr,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  // Quick Date Picker Button
                                  IconButton(
                                    icon: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.edit_calendar_rounded, size: 18, color: AppColors.primary),
                                    ),
                                    tooltip: 'Pick Custom Date',
                                    onPressed: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: _selectedDate,
                                        firstDate: DateTime(2025, 1, 1),
                                        lastDate: DateTime(2027, 12, 31),
                                      );
                                      if (picked != null) {
                                        setState(() => _selectedDate = picked);
                                      }
                                    },
                                  ),
                                  TextButton(
                                    onPressed: widget.onSeeAllRoutine,
                                    child: const Text(
                                      'Routine',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Horizontal Weekday Quick Selector Chips
                          SizedBox(
                            height: 34,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: _weekdays.map((day) {
                                final isSel = day.toLowerCase() == selectedDayName.toLowerCase();
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ChoiceChip(
                                    label: Text(day.substring(0, 3)),
                                    selected: isSel,
                                    onSelected: (selected) {
                                      if (selected) {
                                        final targetWeekday = _weekdays.indexOf(day) + 1;
                                        final currentWeekday = DateTime.now().weekday;
                                        final diff = targetWeekday - currentWeekday;
                                        setState(() {
                                          _selectedDate = DateTime.now().add(Duration(days: diff));
                                        });
                                      }
                                    },
                                    selectedColor: AppColors.primary,
                                    labelStyle: TextStyle(
                                      color: isSel ? Colors.white : AppColors.textPrimary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                    backgroundColor: const Color(0xFFF8FAFC),
                                    side: BorderSide(color: isSel ? AppColors.primary : const Color(0xFFE2E8F0)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    showCheckmark: false,
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (dayRoutine.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Text('🏖️', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No classes scheduled for $selectedDayName! Enjoy your off day or customize your timetable in Routine.',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: dayRoutine.map((slot) {
                          final sub = store.subjects.where((s) => s.id == slot.subjectId || s.name.toLowerCase() == slot.subjectName.toLowerCase()).firstOrNull;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
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
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.safeBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(sub?.icon ?? '📚', style: const TextStyle(fontSize: 20)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        slot.subjectName,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '${slot.startTime} · ${slot.room}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                          ),
                                          if (slot.periodsCount > 1) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFEF3C7),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '${slot.periodsCount} Periods',
                                                style: const TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFFD97706),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (sub != null) ...[
                                  IconButton(
                                    icon: const Icon(Icons.check_circle_rounded, color: AppColors.safe, size: 28),
                                    tooltip: 'Mark Attended (${slot.periodsCount} period${slot.periodsCount > 1 ? 's' : ''}) on $selectedDateStr',
                                    onPressed: () {
                                      store.markPresent(
                                        sub.id,
                                        selectedDateStr,
                                        day: slot.day,
                                        time: slot.startTime,
                                        count: slot.periodsCount,
                                      );
                                      setState(() {});
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Marked ${sub.name} (+${slot.periodsCount} periods) as Present ✓ on $selectedDateStr ($selectedDayName)'),
                                          backgroundColor: AppColors.safe,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cancel_rounded, color: AppColors.critical, size: 28),
                                    tooltip: 'Mark Bunked (${slot.periodsCount} period${slot.periodsCount > 1 ? 's' : ''}) on $selectedDateStr',
                                    onPressed: () {
                                      store.markAbsent(
                                        sub.id,
                                        selectedDateStr,
                                        day: slot.day,
                                        time: slot.startTime,
                                        count: slot.periodsCount,
                                      );
                                      setState(() {});
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Marked ${sub.name} (+${slot.periodsCount} periods) as Absent ✗ on $selectedDateStr ($selectedDayName)'),
                                          backgroundColor: AppColors.critical,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 18),



                    // Streak Banner Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 34)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "You're doing great! 🚀",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Keep it up to maintain your streak.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: widget.onShowStreak,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: const Text(
                                      'View Streak',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '${store.streakDays}',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                              const Text(
                                'days',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildStatCard(
      String label, String value, String icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF334155),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          Text(icon, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
