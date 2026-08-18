import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/models.dart';
import 'services/attendance_store.dart';
import 'theme/colors.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/subjects_screen.dart';
import 'screens/routine_screen.dart';
import 'screens/attendance_sheet_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/marks_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/squad_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/supabase_config.dart';
import 'services/supabase_sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      debug: false,
    );
  } catch (e) {
    debugPrint('Supabase init note: $e');
  }
  runApp(const BunkQuestApp());
}

class BunkQuestApp extends StatefulWidget {
  const BunkQuestApp({super.key});

  @override
  State<BunkQuestApp> createState() => _BunkQuestAppState();
}

class _BunkQuestAppState extends State<BunkQuestApp> {
  final AttendanceDataStore _store = AttendanceDataStore();

  @override
  void initState() {
    super.initState();
    _store.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BunkQuest - Attendance & Academic OS',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.nunitoTextTheme(),
      ),
      home: !_store.onboardingCompleted
          ? OnboardingScreen(
              store: _store,
              onFinish: () {
                setState(() {});
              },
            )
          : const MainNavigationScreen(),
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
  late final SupabaseSyncService _syncService;

  @override
  void initState() {
    super.initState();
    _syncService = SupabaseSyncService(_store);
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
      _currentIndex = 3; // Simulator tab index in 5-tab bar
    });
  }

  void _onSelectSubjectFromDashboard(String subjectId) {
    setState(() {
      _selectedSubjectIdForDetail = subjectId;
      _currentIndex = 1; // Subjects tab
    });
  }

  void _openMarksScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => MarksScreen(store: _store)),
    );
  }

  void _openLeavesScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => CalendarScreen(store: _store)),
    );
  }

  void _openSquadScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => SquadScreen(store: _store)),
    );
  }

  void _openProfileScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => ProfileScreen(
          store: _store,
          onOpenMarks: () => _openMarksScreen(context),
          onOpenLeaves: () => _openLeavesScreen(context),
          onOpenSquad: () => _openSquadScreen(context),
        ),
      ),
    );
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
          'text': '${s.name} is at ${s.percentage}%. One absence will put you below ${s.minRequiredPercentage.round()}%.',
          'color': AppColors.caution,
          'bg': AppColors.cautionBg,
        });
      } else if (s.risk == AttendanceRisk.danger || s.risk == AttendanceRisk.critical) {
        alerts.add({
          'icon': '💀',
          'text': 'CRITICAL: ${s.name} is below target! Attend next ${s.neededClassesToReach(s.minRequiredPercentage)} classes.',
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
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🔔 Smart Alerts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              ...alerts.map((a) {
                final alertColor = a['color'] as Color;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: a['bg'] as Color,
                    borderRadius: BorderRadius.circular(14),
                    border: Border(left: BorderSide(color: alertColor, width: 4)),
                  ),
                  child: Row(
                    children: [
                      Text(a['icon'] as String, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          a['text'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 5 Clean Tabs: Home, Subjects, Routine, Attendance Sheet (Master + Simulator), History Log
    final screens = [
      DashboardScreen(
        store: _store,
        onSeeAllSubjects: () => setState(() => _currentIndex = 1),
        onSeeAllRoutine: () => setState(() => _currentIndex = 2),
        onOpenMarks: () => _openMarksScreen(context),
        onOpenLeaves: () => _openLeavesScreen(context),
        onOpenSquad: () => _openSquadScreen(context),
        onOpenProfile: () => _openProfileScreen(context),
        onShowNotifications: _showNotificationsModal,
        onShowStreak: _showStreakDialog,
        onSelectSubject: _onSelectSubjectFromDashboard,
      ),
      SubjectsScreen(
        store: _store,
        onSimulateSubject: _onSimulateSubject,
        initialSelectedSubjectId: _selectedSubjectIdForDetail,
      ),
      RoutineScreen(store: _store),
      AttendanceSheetScreen(
        store: _store,
        initialTabIndex: _targetSimulatorSubjectId != null ? 1 : 0,
      ),
      HistoryScreen(store: _store),
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
              if (index != 3) {
                _targetSimulatorSubjectId = null;
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
            BottomNavigationBarItem(icon: Icon(Icons.schedule_rounded), label: 'Routine'),
            BottomNavigationBarItem(icon: Icon(Icons.table_chart_rounded), label: 'Sheet'),
            BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'),
          ],
        ),
      ),
    );
  }
}
