import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/attendance_store.dart';
import '../theme/colors.dart';

class RoutineScreen extends StatefulWidget {
  final AttendanceDataStore store;

  const RoutineScreen({super.key, required this.store});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  late String _selectedDay;

  @override
  void initState() {
    super.initState();
    // Default to today's day of week or Monday
    final todayWeekday = DateTime.now().weekday; // 1=Mon..7=Sun
    if (todayWeekday >= 1 && todayWeekday <= 6) {
      _selectedDay = _days[todayWeekday - 1];
    } else {
      _selectedDay = 'Monday';
    }
  }

  @override
  Widget build(BuildContext context) {
    final slots = widget.store.getRoutineForDay(_selectedDay);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                        'Class Routine & Timetable',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Weekly class schedule, venues & faculty',
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
                    onPressed: () => _showAddRoutineSlotDialog(context),
                  ),
                ],
              ),
            ),

            // Day Selector Pills
            Container(
              height: 52,
              color: Colors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: _days.length,
                itemBuilder: (context, idx) {
                  final day = _days[idx];
                  final isSelected = day == _selectedDay;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = day),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Timetable Slot Cards
            Expanded(
              child: slots.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🏖️', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(
                            'No classes scheduled for $_selectedDay!',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Enjoy your free time or add a slot using +',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
                      itemCount: slots.length,
                      itemBuilder: (context, i) {
                        final slot = slots[i];
                        final sub = widget.store.subjects
                            .where((s) => s.id == slot.subjectId || s.name.toLowerCase() == slot.subjectName.toLowerCase())
                            .firstOrNull;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
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
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.safeBg,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    sub?.icon ?? '📚',
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          slot.subjectName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          '${slot.startTime} – ${slot.endTime}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: slot.periodsCount > 1 ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${slot.periodsCount} Period${slot.periodsCount > 1 ? 's (Double Class)' : ''}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: slot.periodsCount > 1 ? const Color(0xFFD97706) : AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (slot.room.isNotEmpty) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.meeting_room_outlined, size: 12, color: AppColors.textSecondary),
                                                const SizedBox(width: 4),
                                                Text(slot.room, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        if (slot.faculty.isNotEmpty)
                                          Expanded(
                                            child: Text(
                                              slot.faculty,
                                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.textSecondary),
                                onPressed: () {
                                  widget.store.deleteRoutineSlot(slot.id);
                                  setState(() {});
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
    );
  }

  void _showAddRoutineSlotDialog(BuildContext context) {
    String selectedDay = _selectedDay;
    String? selectedSubjectName = widget.store.subjects.isNotEmpty ? widget.store.subjects.first.name : '';
    final startCtrl = TextEditingController(text: '09:00 AM');
    final endCtrl = TextEditingController(text: '10:00 AM');
    final roomCtrl = TextEditingController(text: 'LH-101');
    final facultyCtrl = TextEditingController();
    int selectedPeriodsCount = 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Routine Slot', style: TextStyle(fontWeight: FontWeight.w900)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  decoration: const InputDecoration(labelText: 'Day of Week'),
                  items: _days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedDay = val);
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedSubjectName,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  items: widget.store.subjects.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name))).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedSubjectName = val);
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: selectedPeriodsCount,
                  decoration: const InputDecoration(labelText: 'No. of Periods / Attendance Weight'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('1 Period (Single Lecture)')),
                    DropdownMenuItem(value: 2, child: Text('2 Periods (Double Class / Lab)')),
                    DropdownMenuItem(value: 3, child: Text('3 Periods (Continuous Workshop)')),
                    DropdownMenuItem(value: 4, child: Text('4 Periods (Extended Lab)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedPeriodsCount = val);
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: startCtrl,
                        decoration: const InputDecoration(labelText: 'Start Time'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: endCtrl,
                        decoration: const InputDecoration(labelText: 'End Time'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: roomCtrl,
                  decoration: const InputDecoration(labelText: 'Room / Lab Venue (e.g. LH-101)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: facultyCtrl,
                  decoration: const InputDecoration(labelText: 'Faculty / Professor Name (optional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (selectedSubjectName != null && selectedSubjectName!.isNotEmpty) {
                  widget.store.addRoutineSlot(
                    selectedDay,
                    selectedSubjectName!,
                    startCtrl.text.trim(),
                    endCtrl.text.trim(),
                    roomCtrl.text.trim(),
                    facultyCtrl.text.trim(),
                    periodsCount: selectedPeriodsCount,
                  );
                  Navigator.pop(ctx);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added $selectedSubjectName ($selectedPeriodsCount periods) to $selectedDay routine!'),
                      backgroundColor: AppColors.safe,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Save Slot', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
