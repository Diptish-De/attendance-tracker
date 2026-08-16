import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AttendanceDataStore extends ChangeNotifier {
  static final AttendanceDataStore _instance = AttendanceDataStore._internal();
  factory AttendanceDataStore() => _instance;
  AttendanceDataStore._internal() {
    _loadFromPreferences();
  }

  bool isDarkMode = false;
  String studentName = 'Arjun';
  String degree = 'B.Tech CSE · Semester 3';
  int streakDays = 12;
  DateTime semesterStartDate = DateTime(2026, 7, 1);
  DateTime semesterEndDate = DateTime(2026, 12, 15);
  
  String upcomingHolidayName = 'Durga Puja';
  DateTime upcomingHolidayDate = DateTime(2026, 8, 25);

  List<Subject> subjects = [];
  List<Achievement> achievements = [];
  List<LeaveCategory> leaveCategories = [];
  List<LeaveItem> leaveHistory = [];
  List<RoutineSlot> routine = [];
  List<SubjectMarks> marks = [];

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      studentName = prefs.getString('studentName') ?? 'Arjun';
      degree = prefs.getString('degree') ?? 'B.Tech CSE · Semester 3';
      streakDays = prefs.getInt('streakDays') ?? 12;

      final subjectsJson = prefs.getString('subjects');
      if (subjectsJson != null) {
        final List list = jsonDecode(subjectsJson);
        subjects = list.map((e) => Subject.fromJson(e)).toList();
      } else {
        _initDefaultSubjects();
      }

      final routineJson = prefs.getString('routine');
      if (routineJson != null) {
        final List list = jsonDecode(routineJson);
        routine = list.map((e) => RoutineSlot.fromJson(e)).toList();
      } else {
        _initDefaultRoutine();
      }

      final marksJson = prefs.getString('marks');
      if (marksJson != null) {
        final List list = jsonDecode(marksJson);
        marks = list.map((e) => SubjectMarks.fromJson(e)).toList();
      } else {
        _initDefaultMarks();
      }

      final achievementsJson = prefs.getString('achievements');
      if (achievementsJson != null) {
        final List list = jsonDecode(achievementsJson);
        achievements = list.map((e) => Achievement.fromJson(e)).toList();
      } else {
        _initDefaultAchievements();
      }

      final leavesJson = prefs.getString('leaves');
      if (leavesJson != null) {
        final List list = jsonDecode(leavesJson);
        leaveHistory = list.map((e) => LeaveItem.fromJson(e)).toList();
      } else {
        _initDefaultLeaves();
      }

      final leaveCatJson = prefs.getString('leaveCategories');
      if (leaveCatJson != null) {
        final List list = jsonDecode(leaveCatJson);
        leaveCategories = list.map((e) => LeaveCategory.fromJson(e)).toList();
      } else {
        _initDefaultLeaveCategories();
      }
    } catch (e) {
      _initAllDefaults();
    }
    notifyListeners();
  }

  Future<void> saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', isDarkMode);
      await prefs.setString('studentName', studentName);
      await prefs.setString('degree', degree);
      await prefs.setInt('streakDays', streakDays);
      await prefs.setString('subjects', jsonEncode(subjects.map((s) => s.toJson()).toList()));
      await prefs.setString('routine', jsonEncode(routine.map((r) => r.toJson()).toList()));
      await prefs.setString('marks', jsonEncode(marks.map((m) => m.toJson()).toList()));
      await prefs.setString('achievements', jsonEncode(achievements.map((a) => a.toJson()).toList()));
      await prefs.setString('leaves', jsonEncode(leaveHistory.map((l) => l.toJson()).toList()));
      await prefs.setString('leaveCategories', jsonEncode(leaveCategories.map((c) => c.toJson()).toList()));
    } catch (_) {}
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    saveToPreferences();
    notifyListeners();
  }

  void _initAllDefaults() {
    _initDefaultSubjects();
    _initDefaultRoutine();
    _initDefaultMarks();
    _initDefaultAchievements();
    _initDefaultLeaves();
    _initDefaultLeaveCategories();
  }

  void _initDefaultSubjects() {
    subjects = [
      Subject(id: 'dsa', name: 'DSA', icon: '🌐', faculty: 'Prof. Sharma', attended: 34, total: 40, minRequiredPercentage: 75),
      Subject(id: 'oop', name: 'OOP', icon: '🧩', faculty: 'Dr. Mehta', attended: 28, total: 37, minRequiredPercentage: 75),
      Subject(id: 'dm', name: 'DM', icon: '∑', faculty: 'Prof. Gupta', attended: 29, total: 33, minRequiredPercentage: 75),
      Subject(id: 'dsco', name: 'DSCO', icon: '⚙️', faculty: 'Dr. Verma', attended: 17, total: 23, minRequiredPercentage: 75),
      Subject(id: 'dbms', name: 'DBMS', icon: '🗄️', faculty: 'Dr. Nair', attended: 15, total: 22, minRequiredPercentage: 75),
    ];
  }

  void _initDefaultRoutine() {
    routine = [
      RoutineSlot(id: 'r1', day: 'Monday', subjectName: 'DSA', subjectId: 'dsa', startTime: '09:00 AM', endTime: '10:00 AM', room: 'LH-101', faculty: 'Prof. Sharma'),
      RoutineSlot(id: 'r2', day: 'Monday', subjectName: 'OOP', subjectId: 'oop', startTime: '10:15 AM', endTime: '11:15 AM', room: 'Lab-2', faculty: 'Dr. Mehta'),
      RoutineSlot(id: 'r3', day: 'Monday', subjectName: 'DBMS', subjectId: 'dbms', startTime: '11:30 AM', endTime: '12:30 PM', room: 'LH-104', faculty: 'Dr. Nair'),
      RoutineSlot(id: 'r4', day: 'Tuesday', subjectName: 'DM', subjectId: 'dm', startTime: '09:30 AM', endTime: '10:30 AM', room: 'LH-102', faculty: 'Prof. Gupta'),
      RoutineSlot(id: 'r5', day: 'Tuesday', subjectName: 'DSCO', subjectId: 'dsco', startTime: '11:00 AM', endTime: '12:00 PM', room: 'LH-105', faculty: 'Dr. Verma'),
      RoutineSlot(id: 'r6', day: 'Wednesday', subjectName: 'DSA', subjectId: 'dsa', startTime: '10:00 AM', endTime: '11:00 AM', room: 'LH-101', faculty: 'Prof. Sharma'),
      RoutineSlot(id: 'r7', day: 'Wednesday', subjectName: 'OOP', subjectId: 'oop', startTime: '02:00 PM', endTime: '04:00 PM', room: 'Computing Lab', faculty: 'Dr. Mehta'),
      RoutineSlot(id: 'r8', day: 'Thursday', subjectName: 'DM', subjectId: 'dm', startTime: '09:00 AM', endTime: '10:00 AM', room: 'LH-102', faculty: 'Prof. Gupta'),
      RoutineSlot(id: 'r9', day: 'Thursday', subjectName: 'DBMS', subjectId: 'dbms', startTime: '10:15 AM', endTime: '11:15 AM', room: 'LH-104', faculty: 'Dr. Nair'),
      RoutineSlot(id: 'r10', day: 'Friday', subjectName: 'DSCO', subjectId: 'dsco', startTime: '09:00 AM', endTime: '10:00 AM', room: 'LH-105', faculty: 'Dr. Verma'),
      RoutineSlot(id: 'r11', day: 'Friday', subjectName: 'DSA', subjectId: 'dsa', startTime: '11:15 AM', endTime: '12:15 PM', room: 'LH-101', faculty: 'Prof. Sharma'),
    ];
  }

  void _initDefaultMarks() {
    marks = [
      SubjectMarks(subjectId: 'dsa', subjectName: 'DSA', internal1: 22, internal2: 24, assignment: 9, endSem: 88, credits: 4),
      SubjectMarks(subjectId: 'oop', subjectName: 'OOP', internal1: 20, internal2: 22, assignment: 8.5, endSem: 82, credits: 4),
      SubjectMarks(subjectId: 'dm', subjectName: 'DM', internal1: 24, internal2: 23, assignment: 10, endSem: 91, credits: 3),
      SubjectMarks(subjectId: 'dsco', subjectName: 'DSCO', internal1: 17, internal2: 19, assignment: 7, endSem: 74, credits: 3),
      SubjectMarks(subjectId: 'dbms', subjectName: 'DBMS', internal1: 18, internal2: 21, assignment: 8, endSem: 79, credits: 4),
    ];
  }

  void _initDefaultAchievements() {
    achievements = [
      Achievement(id: 'lab', icon: '🔬', title: 'Lab Guardian', desc: '100% lab attendance', unlocked: true),
      Achievement(id: 'week', icon: '⚡', title: 'Perfect Week', desc: 'All classes for one week', unlocked: true),
      Achievement(id: 'bunker', icon: '🎯', title: 'Pro Bunker', desc: 'Maintain 75%+ all semester', unlocked: false),
      Achievement(id: 'recovery', icon: '💪', title: 'Recovery Master', desc: 'Recovered from below 70%', unlocked: false),
      Achievement(id: 'streak', icon: '🔥', title: '10-Day Streak', desc: '10 days attended consecutively', unlocked: true),
      Achievement(id: 'ghost', icon: '👻', title: 'Ghost Mode', desc: '5 strategic skips in a week', unlocked: false),
    ];
  }

  void _initDefaultLeaves() {
    leaveHistory = [
      LeaveItem(id: 1, type: 'Annual Leave', dates: 'May 05 – May 07, 2026', days: 3, status: 'Approved'),
      LeaveItem(id: 2, type: 'Sick Leave', dates: 'Apr 21, 2026', days: 1, status: 'Pending'),
      LeaveItem(id: 3, type: 'Casual Leave', dates: 'Mar 14, 2026', days: 2, status: 'Approved'),
    ];
  }

  void _initDefaultLeaveCategories() {
    leaveCategories = [
      LeaveCategory(name: 'Annual Leave', icon: '🌴', available: 12, used: 3, total: 15),
      LeaveCategory(name: 'Casual Leave', icon: '☕', available: 6, used: 4, total: 10),
      LeaveCategory(name: 'Sick Leave', icon: '🩺', available: 5, used: 5, total: 10),
      LeaveCategory(name: 'Medical Leave', icon: '💊', available: 4, used: 6, total: 10),
    ];
  }

  // Routine Methods
  List<RoutineSlot> getRoutineForDay(String day) {
    return routine.where((r) => r.day.toLowerCase() == day.toLowerCase()).toList();
  }

  List<RoutineSlot> getTodayRoutine() {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final today = days[DateTime.now().weekday - 1];
    return getRoutineForDay(today);
  }

  void addRoutineSlot(String day, String subjectName, String startTime, String endTime, String room, String faculty) {
    final s = subjects.where((sub) => sub.name.toLowerCase() == subjectName.toLowerCase()).firstOrNull;
    final subjectId = s?.id ?? subjectName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    routine.add(RoutineSlot(
      id: 'r_${DateTime.now().millisecondsSinceEpoch}',
      day: day,
      subjectName: subjectName,
      subjectId: subjectId,
      startTime: startTime,
      endTime: endTime,
      room: room,
      faculty: faculty,
    ));
    saveToPreferences();
    notifyListeners();
  }

  void deleteRoutineSlot(String slotId) {
    routine.removeWhere((r) => r.id == slotId);
    saveToPreferences();
    notifyListeners();
  }

  // Marks Methods
  double get cumulativeGPA {
    if (marks.isEmpty) return 0.0;
    double totalPoints = 0.0;
    int totalCredits = 0;
    for (final m in marks) {
      totalPoints += (m.gradePoint * m.credits);
      totalCredits += m.credits;
    }
    return totalCredits == 0 ? 0.0 : (totalPoints / totalCredits);
  }

  double get overallMarksPercentage {
    if (marks.isEmpty) return 0.0;
    double obtained = 0.0;
    double maximum = 0.0;
    for (final m in marks) {
      obtained += m.totalObtained;
      maximum += m.totalMax;
    }
    return maximum == 0 ? 0.0 : ((obtained / maximum) * 100);
  }

  void updateMarks(String subjectId, {double? internal1, double? internal2, double? assignment, double? endSem}) {
    final mIndex = marks.indexWhere((item) => item.subjectId == subjectId);
    if (mIndex != -1) {
      final m = marks[mIndex];
      if (internal1 != null) m.internal1 = internal1;
      if (internal2 != null) m.internal2 = internal2;
      if (assignment != null) m.assignment = assignment;
      if (endSem != null) m.endSem = endSem;
    } else {
      final s = subjects.where((sub) => sub.id == subjectId).firstOrNull;
      marks.add(SubjectMarks(
        subjectId: subjectId,
        subjectName: s?.name ?? subjectId.toUpperCase(),
        internal1: internal1,
        internal2: internal2,
        assignment: assignment,
        endSem: endSem,
      ));
    }
    saveToPreferences();
    notifyListeners();
  }

  // Target Criteria Modification per Subject
  void updateSubjectTarget(String subjectId, double newTarget) {
    final s = subjects.where((sub) => sub.id == subjectId).firstOrNull;
    if (s != null) {
      s.minRequiredPercentage = newTarget;
      saveToPreferences();
      notifyListeners();
    }
  }

  // Calculations & Actions
  int get teachingDaysLeft {
    final now = DateTime.now();
    if (now.isAfter(semesterEndDate)) return 0;
    int days = 0;
    DateTime cur = now;
    while (cur.isBefore(semesterEndDate)) {
      if (cur.weekday != DateTime.saturday && cur.weekday != DateTime.sunday) {
        days++;
      }
      cur = cur.add(const Duration(days: 1));
    }
    return days;
  }

  double get semesterProgress {
    final now = DateTime.now();
    final totalDuration = semesterEndDate.difference(semesterStartDate).inDays;
    if (totalDuration <= 0) return 100.0;
    final elapsed = now.difference(semesterStartDate).inDays;
    return ((elapsed / totalDuration) * 100).clamp(0.0, 100.0);
  }

  int get upcomingHolidayDaysLeft {
    final diff = upcomingHolidayDate.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  int get overallPercentage {
    if (subjects.isEmpty) return 0;
    final totalAttended = subjects.fold<int>(0, (acc, s) => acc + s.attended);
    final totalClasses = subjects.fold<int>(0, (acc, s) => acc + s.total);
    if (totalClasses == 0) return 0;
    return ((totalAttended / totalClasses) * 100).round();
  }

  int get totalSafeSkips => subjects.fold<int>(0, (sum, s) => sum + s.safeSkips);

  int get totalCredits => subjects.fold<int>(0, (sum, s) => sum + s.safeSkips);

  AttendanceRisk get overallRisk {
    final p = overallPercentage;
    if (p >= 80) return AttendanceRisk.safe;
    if (p >= 75) return AttendanceRisk.caution;
    if (p >= 70) return AttendanceRisk.danger;
    return AttendanceRisk.critical;
  }

  void updateProfile(String name, String deg) {
    studentName = name;
    degree = deg;
    saveToPreferences();
    notifyListeners();
  }

  void markPresent(String subjectId, String date) {
    final s = subjects.where((item) => item.id == subjectId).firstOrNull;
    if (s != null) {
      s.markPresent(date);
      streakDays += 1;
      _checkAchievements();
      saveToPreferences();
      notifyListeners();
    }
  }

  void markAbsent(String subjectId, String date) {
    final s = subjects.where((item) => item.id == subjectId).firstOrNull;
    if (s != null) {
      s.markAbsent(date);
      saveToPreferences();
      notifyListeners();
    }
  }

  void addSubject(String name, String faculty, String icon, int attended, int total, double minReq) {
    final id = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    subjects.add(Subject(
      id: id,
      name: name,
      icon: icon.isEmpty ? '📚' : icon,
      faculty: faculty,
      attended: attended,
      total: total,
      minRequiredPercentage: minReq,
    ));
    marks.add(SubjectMarks(subjectId: id, subjectName: name));
    _checkAchievements();
    saveToPreferences();
    notifyListeners();
  }

  void deleteSubject(String subjectId) {
    subjects.removeWhere((s) => s.id == subjectId);
    marks.removeWhere((m) => m.subjectId == subjectId);
    routine.removeWhere((r) => r.subjectId == subjectId);
    saveToPreferences();
    notifyListeners();
  }

  void applyLeave(String type, int days, String dates) {
    final newId = DateTime.now().millisecondsSinceEpoch;
    leaveHistory.insert(
      0,
      LeaveItem(
        id: newId,
        type: type,
        dates: dates,
        days: days,
        status: 'Pending',
      ),
    );

    final catIndex = leaveCategories.indexWhere((c) => c.name.toLowerCase().contains(type.toLowerCase()));
    if (catIndex != -1) {
      leaveCategories[catIndex].available = (leaveCategories[catIndex].available - days).clamp(0, leaveCategories[catIndex].total);
      leaveCategories[catIndex].used += days;
    }
    saveToPreferences();
    notifyListeners();
  }

  void unlockAchievement(String id) {
    final target = achievements.where((a) => a.id == id).firstOrNull;
    if (target != null && !target.unlocked) {
      target.unlocked = true;
      saveToPreferences();
      notifyListeners();
    }
  }

  void _checkAchievements() {
    if (overallPercentage >= 75) {
      final b = achievements.where((a) => a.id == 'bunker').firstOrNull;
      if (b != null) b.unlocked = true;
    }
    if (streakDays >= 10) {
      final s = achievements.where((a) => a.id == 'streak').firstOrNull;
      if (s != null) s.unlocked = true;
    }
  }
}
