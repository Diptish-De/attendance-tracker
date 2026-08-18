import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/attendance_store.dart';
import '../theme/colors.dart';
import '../widgets/painters.dart';
import 'simulator_screen.dart';

class AttendanceSheetScreen extends StatefulWidget {
  final AttendanceDataStore store;
  final Function(String subjectId)? onSelectSubject;
  final int initialTabIndex; // 0 for Master Sheet, 1 for Simulator

  const AttendanceSheetScreen({
    super.key,
    required this.store,
    this.onSelectSubject,
    this.initialTabIndex = 0,
  });

  @override
  State<AttendanceSheetScreen> createState() => _AttendanceSheetScreenState();
}

class _AttendanceSheetScreenState extends State<AttendanceSheetScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final subjects = store.subjects;
    final overallPct = store.overallPercentage;
    final overallRisk = store.overallRisk;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attendance & Simulator Sheet',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Master ledger, percentages & predictive simulator',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.getRiskBg(overallRisk),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.getRiskColor(overallRisk).withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
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
                                color: AppColors.getRiskColor(overallRisk),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Segmented Tabs Header
                  Container(
                    height: 42,
                    padding: const EdgeInsets.all(3),
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
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                      tabs: const [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.table_chart_rounded, size: 16),
                              SizedBox(width: 6),
                              Text('Master Sheet'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.sports_esports_rounded, size: 16),
                              SizedBox(width: 6),
                              Text('Bunk Simulator'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 1. Master Attendance Sheet View
                  _buildMasterSheetView(subjects),

                  // 2. Predictive Simulator View
                  SimulatorScreen(subjects: subjects),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterSheetView(List<Subject> subjects) {
    if (subjects.isEmpty) {
      return const Center(
        child: Text(
          'No subjects found in attendance sheet',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textSecondary),
        ),
      );
    }

    final totalAttended = subjects.fold<int>(0, (a, b) => a + b.attended);
    final totalClasses = subjects.fold<int>(0, (a, b) => a + b.total);
    final totalMissed = totalClasses - totalAttended;
    final totalSafeSkips = subjects.fold<int>(0, (a, b) => a + b.safeSkips);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Sheet Aggregate Summary
          Container(
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
                  child: _buildSummaryItem('Total Classes', '$totalClasses', const Color(0xFF3B82F6), const Color(0xFFDBEAFE)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryItem('Attended', '$totalAttended', AppColors.safe, AppColors.safeBg),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryItem('Missed', '$totalMissed', AppColors.critical, AppColors.criticalBg),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryItem('Safe Skips', '$totalSafeSkips', const Color(0xFFF97316), const Color(0xFFFFEDD5)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Subject Attendance Matrix',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          // Subject Rows Sheet
          ...subjects.map((s) {
            final color = AppColors.getRiskColor(s.risk);
            final bg = AppColors.getRiskBg(s.risk);
            final missed = s.total - s.attended;

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
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      DonutWidget(percentage: s.percentage, color: color, size: 54),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  s.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: bg,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    AppColors.getRiskLabel(s.risk),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              s.faculty,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress Bar
                  HealthBarWidget(percentage: s.percentage, color: color, height: 6),
                  const SizedBox(height: 10),
                  // Stats Grid in Sheet
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniBadge('Attended', '${s.attended}', AppColors.safe),
                      _buildMiniBadge('Missed', '$missed', AppColors.critical),
                      _buildMiniBadge('Total', '${s.total}', const Color(0xFF64748B)),
                      _buildMiniBadge('Target', '${s.minRequiredPercentage.round()}%', const Color(0xFF3B82F6)),
                      _buildMiniBadge('Safe Skips', '${s.safeSkips}', color),
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

  Widget _buildSummaryItem(String label, String val, Color c, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: c),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: c),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(String label, String value, Color c) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: c),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
