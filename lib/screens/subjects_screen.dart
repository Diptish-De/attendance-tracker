import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/attendance_store.dart';
import '../theme/colors.dart';
import '../widgets/painters.dart';

class SubjectsScreen extends StatefulWidget {
  final AttendanceDataStore store;
  final Function(String subjectId) onSimulateSubject;
  final String? initialSelectedSubjectId;

  const SubjectsScreen({
    super.key,
    required this.store,
    required this.onSimulateSubject,
    this.initialSelectedSubjectId,
  });

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  String? _selectedSubjectId;

  @override
  void initState() {
    super.initState();
    _selectedSubjectId = widget.initialSelectedSubjectId;
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedSubjectId != null) {
      final s = widget.store.subjects.firstWhere(
        (item) => item.id == _selectedSubjectId,
        orElse: () => widget.store.subjects.first,
      );
      return _buildSubjectDetail(s);
    }
    return _buildSubjectList();
  }

  Widget _buildSubjectList() {
    final subjects = widget.store.subjects;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'My Subjects',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tap a subject to manage or record attendance',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.safeBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 22),
                    ),
                    onPressed: () => _showAddSubjectDialog(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final s = subjects[index];
                  final color = AppColors.getRiskColor(s.risk);
                  final bg = AppColors.getRiskBg(s.risk);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => setState(() => _selectedSubjectId = s.id),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              DonutWidget(
                                percentage: s.percentage,
                                color: color,
                                size: 60,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          s.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: bg,
                                            borderRadius:
                                                BorderRadius.circular(99),
                                          ),
                                          child: Text(
                                            AppColors.getRiskLabel(s.risk),
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: color,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      s.faculty,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    HealthBarWidget(
                                      percentage: s.percentage,
                                      color: color,
                                      height: 6,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${s.attended}/${s.total} attended',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        Text(
                                          '${s.safeSkips} safe skips left',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: color,
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
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectDetail(Subject s) {
    final color = AppColors.getRiskColor(s.risk);
    final bg = AppColors.getRiskBg(s.risk);
    final today = _formatDate(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          onPressed: () => setState(() => _selectedSubjectId = null),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              s.faculty,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.critical),
                      tooltip: 'Delete Subject',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: const Text('Delete Subject?', style: TextStyle(fontWeight: FontWeight.w900)),
                            content: Text(
                              'Are you sure you want to delete ${s.name}? All attendance logs and marks for this subject will be removed.',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  // Capture copy for 10-second Undo
                                  final deletedSubject = s;
                                  final subjectMarks = widget.store.marks.where((m) => m.subjectId == s.id).firstOrNull;
                                  final routineSlots = widget.store.routine.where((r) => r.subjectId == s.id).toList();
                                  final subjectIndex = widget.store.subjects.indexOf(s);

                                  widget.store.deleteSubject(s.id);
                                  setState(() => _selectedSubjectId = null);

                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      duration: const Duration(seconds: 10),
                                      backgroundColor: const Color(0xFF1E293B),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      content: Row(
                                        children: [
                                          const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Deleted ${deletedSubject.name}',
                                              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                      action: SnackBarAction(
                                        label: 'UNDO (10s)',
                                        textColor: AppColors.primary,
                                        onPressed: () {
                                          widget.store.restoreSubject(
                                            deletedSubject,
                                            m: subjectMarks,
                                            slots: routineSlots,
                                            index: subjectIndex,
                                          );
                                          setState(() => _selectedSubjectId = deletedSubject.id);
                                        },
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.critical,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Donut Hero
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          DonutWidget(
                            percentage: s.percentage,
                            color: color,
                            size: 110,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              AppColors.getRiskLabel(s.risk),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            s.safeSkips > 0
                                ? 'Safe to skip ${s.safeSkips} more class${s.safeSkips > 1 ? 'es' : ''}.'
                                : 'Do NOT skip! Attend next ${s.neededClassesToReach(75.0)} classes to reach 75%.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Stats Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            'Attended',
                            '${s.attended}',
                            AppColors.safe,
                            AppColors.safeBg,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricCard(
                            'Missed',
                            '${s.total - s.attended}',
                            AppColors.critical,
                            AppColors.criticalBg,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMetricCard(
                            'Safe Skips',
                            '${s.safeSkips}',
                            const Color(0xFF3B82F6),
                            const Color(0xFFDBEAFE),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Health Meter
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HEALTH METER',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          HealthBarWidget(
                            percentage: s.percentage,
                            color: color,
                            height: 12,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${s.attended}/${s.total} classes attended',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${s.percentage}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action Buttons Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.3,
                      children: [
                        _buildActionButton(
                          'Mark Present',
                          Icons.check_circle_outline,
                          AppColors.safe,
                          AppColors.safeBg,
                          () {
                            final now = DateTime.now();
                            final dayName = _getDayName(now.weekday);
                            final timeStr = _formatTime(now);
                            widget.store.markPresent(s.id, today, day: dayName, time: timeStr, count: 1);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${s.name}: marked present ✓ on $dayName, $today'),
                                backgroundColor: AppColors.safe,
                              ),
                            );
                            setState(() {});
                          },
                        ),
                        _buildActionButton(
                          'Mark Absent',
                          Icons.cancel_outlined,
                          AppColors.critical,
                          AppColors.criticalBg,
                          () {
                            final now = DateTime.now();
                            final dayName = _getDayName(now.weekday);
                            final timeStr = _formatTime(now);
                            widget.store.markAbsent(s.id, today, day: dayName, time: timeStr, count: 1);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${s.name}: marked absent ✗ on $dayName, $today'),
                                backgroundColor: AppColors.critical,
                              ),
                            );
                            setState(() {});
                          },
                        ),
                        _buildActionButton(
                          'Target: ${s.minRequiredPercentage.round()}%',
                          Icons.tune_rounded,
                          const Color(0xFF3B82F6),
                          const Color(0xFFDBEAFE),
                          () => _showEditTargetDialog(context, s),
                        ),
                        _buildActionButton(
                          'Simulate Skip',
                          Icons.insights_rounded,
                          AppColors.danger,
                          AppColors.dangerBg,
                          () {
                            widget.onSimulateSubject(s.id);
                          },
                        ),
                        _buildActionButton(
                          'History Log',
                          Icons.history_rounded,
                          const Color(0xFF7C3AED),
                          const Color(0xFFEDE9FE),
                          () => _showHistoryModal(context, s),
                        ),
                      ],
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

  Widget _buildMetricCard(String label, String value, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, Color bg, VoidCallback onTap) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final facultyCtrl = TextEditingController();
    final attendedCtrl = TextEditingController(text: '0');
    final totalCtrl = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add New Subject', style: TextStyle(fontWeight: FontWeight.w900)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Subject Name (e.g. AI / ML)'),
              ),
              TextField(
                controller: facultyCtrl,
                decoration: const InputDecoration(labelText: 'Faculty / Professor Name'),
              ),
              TextField(
                controller: attendedCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Classes Attended So Far'),
              ),
              TextField(
                controller: totalCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Classes Conducted'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                widget.store.addSubject(
                  nameCtrl.text.trim(),
                  facultyCtrl.text.trim(),
                  '📘',
                  int.tryParse(attendedCtrl.text) ?? 0,
                  int.tryParse(totalCtrl.text) ?? 0,
                  75.0,
                );
                Navigator.pop(ctx);
                setState(() {});
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Add Subject', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _showHistoryModal(BuildContext context, Subject s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Register Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.5)),
                ),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDE9FE),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.menu_book_rounded, color: Color(0xFF7C3AED), size: 20),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${s.name} Attendance Register',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                                ),
                                Text(
                                  'Physical roll log · ${s.attended} Attended / ${s.total} Total (${s.percentage}%)',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Register Entries
              Expanded(
                child: s.history.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('📋', style: TextStyle(fontSize: 48)),
                            SizedBox(height: 10),
                            Text(
                              'No roll calls recorded yet!',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Mark attendance to automatically log date, day & periods into the register.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: s.history.length,
                        itemBuilder: (context, idx) {
                          final h = s.history[idx];
                          final isPresent = h.status == 'present';
                          final c = isPresent ? AppColors.safe : AppColors.critical;
                          final bg = isPresent ? AppColors.safeBg : AppColors.criticalBg;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                // Status Stamp Icon
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: bg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      isPresent ? 'P' : 'A',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: c,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Date, Day and Time details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            h.date,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          if (h.day.isNotEmpty) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                h.day,
                                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Text(
                                            h.time.isNotEmpty ? h.time : 'Class Session',
                                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '• ${h.periods} Period${h.periods > 1 ? 's' : ''}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: h.periods > 1 ? const Color(0xFFD97706) : AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Status Pill
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: bg,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    isPresent ? 'PRESENT' : 'ABSENT',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: c,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 4),

                                // Delete/Undo entry with confirmation & 10s undo
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFF94A3B8)),
                                  tooltip: 'Remove Entry',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (dialogCtx) => AlertDialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        title: const Text('Remove Attendance Entry?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                        content: Text(
                                          'Delete entry for ${h.date} (${h.status.toUpperCase()} • ${h.periods} period${h.periods > 1 ? 's' : ''})?',
                                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(dialogCtx),
                                            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(dialogCtx);
                                              final deletedRecord = h;
                                              final deletedIdx = idx;

                                              widget.store.deleteAttendanceRecord(s.id, deletedIdx);
                                              setModalState(() {});
                                              setState(() {});

                                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  duration: const Duration(seconds: 10),
                                                  backgroundColor: const Color(0xFF1E293B),
                                                  behavior: SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                  content: Text(
                                                    'Removed entry for ${deletedRecord.date}',
                                                    style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                                                  ),
                                                  action: SnackBarAction(
                                                    label: 'UNDO (10s)',
                                                    textColor: AppColors.primary,
                                                    onPressed: () {
                                                      widget.store.restoreAttendanceRecord(s.id, deletedRecord, deletedIdx);
                                                      setModalState(() {});
                                                      setState(() {});
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.critical,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                            child: const Text('Remove', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditTargetDialog(BuildContext context, Subject s) {
    double currentTarget = s.minRequiredPercentage;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Target Criteria: ${s.name}', style: const TextStyle(fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Set the minimum required percentage for this subject. Safe skips will be recalculated based on this goal.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Text(
                '${currentTarget.round()}%',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
              Slider(
                value: currentTarget,
                min: 50,
                max: 95,
                divisions: 9,
                activeColor: AppColors.primary,
                onChanged: (val) => setModalState(() => currentTarget = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                widget.store.updateSubjectTarget(s.id, currentTarget);
                Navigator.pop(ctx);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Target criteria for ${s.name} updated to ${currentTarget.round()}%'),
                    backgroundColor: AppColors.safe,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Save Target', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _getDayName(int weekday) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[(weekday - 1).clamp(0, 6)];
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min $period';
  }
}
