import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/attendance_store.dart';
import '../theme/colors.dart';

class HistoryScreen extends StatefulWidget {
  final AttendanceDataStore store;

  const HistoryScreen({super.key, required this.store});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedSubjectFilter = 'All';
  String _selectedStatusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    // Gather all attendance logs across all subjects
    final allLogs = <_FlattenedAttendanceLog>[];
    for (final s in widget.store.subjects) {
      for (int i = 0; i < s.history.length; i++) {
        allLogs.add(_FlattenedAttendanceLog(
          subject: s,
          historyIndex: i,
          item: s.history[i],
        ));
      }
    }

    // Filter by subject
    var filtered = allLogs;
    if (_selectedSubjectFilter != 'All') {
      filtered = filtered.where((l) => l.subject.id == _selectedSubjectFilter).toList();
    }

    // Filter by status
    if (_selectedStatusFilter == 'Present') {
      filtered = filtered.where((l) => l.item.status.toLowerCase() == 'present').toList();
    } else if (_selectedStatusFilter == 'Absent') {
      filtered = filtered.where((l) => l.item.status.toLowerCase() == 'absent').toList();
    }

    final totalLogs = allLogs.length;
    final totalPresent = allLogs.where((l) => l.item.status.toLowerCase() == 'present').length;
    final totalAbsent = allLogs.where((l) => l.item.status.toLowerCase() == 'absent').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attendance History Log',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Physical register & session entries',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '$totalLogs Entries',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Summary Stats Row
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryPill('Total Sessions', '$totalLogs', const Color(0xFF3B82F6), const Color(0xFFDBEAFE)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryPill('Presents ✓', '$totalPresent', AppColors.safe, AppColors.safeBg),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSummaryPill('Absents ✗', '$totalAbsent', AppColors.critical, AppColors.criticalBg),
                  ),
                ],
              ),
            ),

            // Filter Chips Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Subject Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          'All Subjects',
                          _selectedSubjectFilter == 'All',
                          () => setState(() => _selectedSubjectFilter = 'All'),
                        ),
                        ...widget.store.subjects.map((s) => _buildFilterChip(
                              s.name,
                              _selectedSubjectFilter == s.id,
                              () => setState(() => _selectedSubjectFilter = s.id),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Status Filter Chips
                  Row(
                    children: [
                      _buildFilterChip(
                        'All Status',
                        _selectedStatusFilter == 'All',
                        () => setState(() => _selectedStatusFilter = 'All'),
                      ),
                      _buildFilterChip(
                        'Present Only ✓',
                        _selectedStatusFilter == 'Present',
                        () => setState(() => _selectedStatusFilter = 'Present'),
                      ),
                      _buildFilterChip(
                        'Absent Only ✗',
                        _selectedStatusFilter == 'Absent',
                        () => setState(() => _selectedStatusFilter = 'Absent'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // History Log List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('📋', style: TextStyle(fontSize: 44)),
                          const SizedBox(height: 10),
                          const Text(
                            'No Attendance Logs Found',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedSubjectFilter != 'All' || _selectedStatusFilter != 'All'
                                ? 'Try changing the filters above'
                                : 'Mark attendance from Home or Subjects to see history records',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final log = filtered[index];
                        final h = log.item;
                        final isPresent = h.status.toLowerCase() == 'present';
                        final c = isPresent ? AppColors.safe : AppColors.critical;
                        final bg = isPresent ? AppColors.safeBg : AppColors.criticalBg;

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
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Status Avatar Icon
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: bg,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    isPresent ? 'P' : 'A',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: c,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          log.subject.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        if (h.day.isNotEmpty) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              h.day,
                                              style: const TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          h.date,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF475569),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
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

                              // Delete Action
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFF94A3B8)),
                                tooltip: 'Remove Entry',
                                onPressed: () {
                                  widget.store.deleteAttendanceRecord(log.subject.id, log.historyIndex);
                                  setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Removed attendance register entry')),
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
    );
  }

  Widget _buildSummaryPill(String label, String value, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(99),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _FlattenedAttendanceLog {
  final Subject subject;
  final int historyIndex;
  final AttendanceRecord item;

  _FlattenedAttendanceLog({
    required this.subject,
    required this.historyIndex,
    required this.item,
  });
}
