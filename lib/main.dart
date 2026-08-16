import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/models.dart';
import 'services/attendance_store.dart';
import 'theme/colors.dart';
import 'screens/dashboard_screen.dart';
import 'screens/subjects_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/simulator_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const BunkQuestApp());
}

class BunkQuestApp extends StatelessWidget {
  const BunkQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BunkQuest - Attendance OS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.nunitoTextTheme(),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  String? _targetSimulatorSubjectId;
  String? _selectedSubjectIdForDetail;
  final AttendanceDataStore _store = AttendanceDataStore();

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreUpdate);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreUpdate);
    super.dispose();
  }

  void _onStoreUpdate() {
    setState(() {});
  }

  void _onSimulateSubject(String subjectId) {
    setState(() {
      _targetSimulatorSubjectId = subjectId;
      _currentIndex = 3; // Simulator tab
    });
  }

  void _onSelectSubjectFromDashboard(String subjectId) {
    setState(() {
      _selectedSubjectIdForDetail = subjectId;
      _currentIndex = 1; // Subjects tab
    });
  }

  void _showStreakDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Center(
          child: Text('🔥 ${_store.streakDays}-Day Streak!', style: const TextStyle(fontWeight: FontWeight.w900)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_store.streakDays}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
            const Text(
              'consecutive days attended.\nKeep marking attendance to maintain your rank!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Keep it going!', style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  void _showNotificationsModal() {
    final alerts = <Map<String, dynamic>>[];
    for (final s in _store.subjects) {
      if (s.risk == AttendanceRisk.safe && s.safeSkips > 2) {
        alerts.add({
          'icon': '✅',
          'text': 'You have ${s.safeSkips} safe skips remaining in ${s.name}.',
          'color': AppColors.safe,
          'bg': AppColors.safeBg,
        });
      } else if (s.risk == AttendanceRisk.caution) {
        alerts.add({
          'icon': '⚠️',
          'text': '${s.name} is at ${s.percentage}%. One absence will put you below 75%.',
          'color': AppColors.caution,
          'bg': AppColors.cautionBg,
        });
      } else if (s.risk == AttendanceRisk.danger || s.risk == AttendanceRisk.critical) {
        alerts.add({
          'icon': '💀',
          'text': 'CRITICAL: ${s.name} is below 75%! Attend next ${s.neededClassesToReach(75.0)} classes.',
          'color': AppColors.critical,
          'bg': AppColors.criticalBg,
        });
      }
    }

    alerts.add({
      'icon': '🎉',
      'text': '${_store.upcomingHolidayName} in ${_store.upcomingHolidayDaysLeft} days. Attendance budget adjusted.',
      'color': AppColors.danger,
      'bg': AppColors.dangerBg,
    });

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔔 Smart Alerts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            ...alerts.map((a) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: a['bg'] as Color,
                    borderRadius: BorderRadius.circular(14),
                    border: Border(left: BorderSide(color: a['color'] as Color, width: 4)),
                  ),
                  child: Row(
                    children: [
                      Text(a['icon'] as String, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          a['text'] as String,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        store: _store,
        onSeeAllSubjects: () => setState(() => _currentIndex = 1),
        onShowNotifications: _showNotificationsModal,
        onShowStreak: _showStreakDialog,
        onSelectSubject: _onSelectSubjectFromDashboard,
      ),
      SubjectsScreen(
        store: _store,
        onSimulateSubject: _onSimulateSubject,
        initialSelectedSubjectId: _selectedSubjectIdForDetail,
      ),
      CalendarScreen(store: _store),
      SimulatorScreen(
        subjects: _store.subjects,
        initialSubjectId: _targetSimulatorSubjectId,
      ),
      ProfileScreen(store: _store),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              if (index != 1) {
                _selectedSubjectIdForDetail = null;
              }
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Subjects'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Calendar'),
            BottomNavigationBarItem(icon: Icon(Icons.sports_esports_rounded), label: 'Simulator'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
