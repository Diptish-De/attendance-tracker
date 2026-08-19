import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AttendanceDataStore extends ChangeNotifier {
  static final AttendanceDataStore _instance = AttendanceDataStore._internal();
  factory AttendanceDataStore() => _instance;
  AttendanceDataStore._internal();

  bool isInitialized = false;
  VoidCallback? onDataChanged;

  String studentName = 'Arjun';
  String studentAvatar = '🎓';
  String degree = 'B.Tech';
  String course = 'CSE';
  String semester = 'Semester 3';
  int streakDays = 0;
  bool onboardingCompleted = false;
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
  List<SquadGroup> squadGroups = [];
  String? activeSquadId;
  Map<String, String> dailyNotes = {};

  String get academicDetailsFormatted => '$degree $course · $semester';

  SquadGroup? get activeSquad {
    if (squadGroups.isEmpty) return null;
    if (activeSquadId == null) return squadGroups.first;
    return squadGroups.where((s) => s.id == activeSquadId).firstOrNull ?? squadGroups.first;
  }

  Future<void> init() async {
    if (isInitialized) return;
    await _loadFromPreferences();
    isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      studentName = prefs.getString('studentName') ?? studentName;
      studentAvatar = prefs.getString('studentAvatar') ?? '🎓';
      
      final savedDeg = prefs.getString('degree') ?? 'B.Tech';
      if (savedDeg.contains('·') || savedDeg.contains('Semester') || savedDeg.contains('CSE')) {
        degree = 'B.Tech';
      } else {
        degree = savedDeg;
      }
      course = prefs.getString('course') ?? 'CSE';
      semester = prefs.getString('semester') ?? 'Semester 3';
      streakDays = prefs.getInt('streakDays') ?? 0;
      onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;

      final startStr = prefs.getString('semesterStartDate');
      if (startStr != null) {
        semesterStartDate = DateTime.tryParse(startStr) ?? semesterStartDate;
      }
      final endStr = prefs.getString('semesterEndDate');
      if (endStr != null) {
        semesterEndDate = DateTime.tryParse(endStr) ?? semesterEndDate;
      }

      // Safe load: Subjects
      try {
        final subjectsJson = prefs.getString('subjects');
        if (subjectsJson != null) {
          final List list = jsonDecode(subjectsJson);
          subjects = list.map((e) => Subject.fromJson(e)).toList();
        } else {
          subjects = [];
        }
      } catch (e) {
        debugPrint('Error loading subjects: $e');
        subjects = [];
      }

      // Safe load: Routine
      try {
        final routineJson = prefs.getString('routine');
        if (routineJson != null) {
          final List list = jsonDecode(routineJson);
          routine = list.map((e) => RoutineSlot.fromJson(e)).toList();
        } else {
          routine = [];
        }
      } catch (e) {
        debugPrint('Error loading routine: $e');
        routine = [];
      }

      // Safe load: Marks
      try {
        final marksJson = prefs.getString('marks');
        if (marksJson != null) {
          final List list = jsonDecode(marksJson);
          marks = list.map((e) => SubjectMarks.fromJson(e)).toList();
        } else {
          marks = [];
        }
      } catch (e) {
        debugPrint('Error loading marks: $e');
        marks = [];
      }

      // Safe load: Achievements
      try {
        final achievementsJson = prefs.getString('achievements');
        if (achievementsJson != null) {
          final List list = jsonDecode(achievementsJson);
          achievements = list.map((e) => Achievement.fromJson(e)).toList();
        } else {
          _initDefaultAchievements();
          if (!onboardingCompleted) {
            for (final a in achievements) {
              a.unlocked = false;
            }
          }
        }
      } catch (e) {
        _initDefaultAchievements();
      }

      // Safe load: Leaves
      try {
        final leavesJson = prefs.getString('leaves');
        if (leavesJson != null) {
          final List list = jsonDecode(leavesJson);
          leaveHistory = list.map((e) => LeaveItem.fromJson(e)).toList();
        } else {
          leaveHistory = [];
        }
      } catch (e) {
        leaveHistory = [];
      }

      // Safe load: Leave Categories
      try {
        final leaveCatJson = prefs.getString('leaveCategories');
        if (leaveCatJson != null) {
          final List list = jsonDecode(leaveCatJson);
          leaveCategories = list.map((e) => LeaveCategory.fromJson(e)).toList();
        } else {
          _initDefaultLeaveCategories();
          if (!onboardingCompleted) {
            leaveCategories = leaveCategories.map((c) => LeaveCategory(
              name: c.name,
              icon: c.icon,
              available: c.total,
              used: 0,
              total: c.total,
            )).toList();
          }
        }
      } catch (e) {
        _initDefaultLeaveCategories();
      }

      // Safe load: Squad Groups
      try {
        activeSquadId = prefs.getString('activeSquadId');
        final squadListJson = prefs.getString('squadGroups');
        if (squadListJson != null) {
          final List list = jsonDecode(squadListJson);
          squadGroups = list.map((e) => SquadGroup.fromJson(e)).toList();
        } else {
          squadGroups = [];
        }
      } catch (e) {
        squadGroups = [];
      }

      // Safe load: Daily Notes
      try {
        final dailyNotesJson = prefs.getString('dailyNotes');
        if (dailyNotesJson != null) {
          final Map<String, dynamic> decoded = jsonDecode(dailyNotesJson);
          dailyNotes = decoded.map((key, value) => MapEntry(key, value.toString()));
        } else {
          dailyNotes = {};
        }
      } catch (e) {
        dailyNotes = {};
      }

      // Auto-delete chats and polls older than 24 hours
      _cleanupExpiredSquadData();
    } catch (e) {
      debugPrint('Preferences load error: $e');
    }
  }

  void _cleanupExpiredSquadData() {
    for (final group in squadGroups) {
      group.messages.removeWhere((msg) => msg.isExpired);
      group.polls.removeWhere((poll) => poll.isExpired);
    }
  }

  Future<void> saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('studentName', studentName);
      await prefs.setString('studentAvatar', studentAvatar);
      await prefs.setString('degree', degree);
      await prefs.setString('course', course);
      await prefs.setString('semester', semester);
      await prefs.setInt('streakDays', streakDays);
      await prefs.setBool('onboardingCompleted', onboardingCompleted);
      await prefs.setString('semesterStartDate', semesterStartDate.toIso8601String());
      await prefs.setString('semesterEndDate', semesterEndDate.toIso8601String());
      await prefs.setString('subjects', jsonEncode(subjects.map((s) => s.toJson()).toList()));
      await prefs.setString('routine', jsonEncode(routine.map((r) => r.toJson()).toList()));
      await prefs.setString('marks', jsonEncode(marks.map((m) => m.toJson()).toList()));
      await prefs.setString('achievements', jsonEncode(achievements.map((a) => a.toJson()).toList()));
      await prefs.setString('leaves', jsonEncode(leaveHistory.map((l) => l.toJson()).toList()));
      await prefs.setString('leaveCategories', jsonEncode(leaveCategories.map((c) => c.toJson()).toList()));
      await prefs.setString('squadGroups', jsonEncode(squadGroups.map((s) => s.toJson()).toList()));
      await prefs.setString('dailyNotes', jsonEncode(dailyNotes));
      if (activeSquadId != null) {
        await prefs.setString('activeSquadId', activeSquadId!);
      }
    } catch (e) {
      debugPrint('Save preferences error: $e');
    }
    onDataChanged?.call();
    notifyListeners();
  }

  void _initDefaultAchievements() {
    achievements = [
      Achievement(id: 'first', icon: '🎯', title: 'First Step', desc: 'Add your first real subject', unlocked: subjects.isNotEmpty),
      Achievement(id: 'streak', icon: '🔥', title: 'On Fire', desc: 'Maintain 5-day attendance streak', unlocked: streakDays >= 5),
      Achievement(id: 'safe', icon: '🛡️', title: 'Safety Champion', desc: 'Keep attendance above 75% target', unlocked: subjects.isNotEmpty && overallPercentage >= 75),
      Achievement(id: 'hundred', icon: '💯', title: 'Perfect Score', desc: 'Score 100% in any subject CIA or Exam', unlocked: false),
    ];
  }

  void _initDefaultLeaveCategories() {
    leaveCategories = [
      LeaveCategory(name: 'Annual Leave', icon: '🌴', available: 15, used: 0, total: 15),
      LeaveCategory(name: 'Casual Leave', icon: '☕', available: 10, used: 0, total: 10),
      LeaveCategory(name: 'Sick Leave', icon: '🩺', available: 10, used: 0, total: 10),
      LeaveCategory(name: 'Duty Leave', icon: '💼', available: 10, used: 0, total: 10),
    ];
  }

  // ─── Squad & Multi-Room Actions ───────────────────────────────────────────
  void switchSquad(String squadId) {
    if (squadGroups.any((s) => s.id == squadId)) {
      activeSquadId = squadId;
      saveToPreferences();
      notifyListeners();
    }
  }

  void joinSquad(String code) {
    final cleanCode = code.toUpperCase().trim();
    // Check if already in squad with this code
    final existing = squadGroups.where((s) => s.code.toUpperCase() == cleanCode).firstOrNull;
    if (existing != null) {
      activeSquadId = existing.id;
      saveToPreferences();
      notifyListeners();
      return;
    }

    final newSquad = SquadGroup(
      id: 'sq_${DateTime.now().millisecondsSinceEpoch}',
      code: cleanCode,
      name: 'Squad $cleanCode',
      icon: '⚡',
      description: 'Connected via invite room code',
      category: 'Peer Study Group',
      themeColorHex: '#3B82F6',
      members: [
        SquadMember(id: 'me', name: studentName, avatar: studentAvatar, attendancePct: overallPercentage, streak: streakDays, estimatedSGPA: cumulativeGPA, statusMessage: 'Joined Squad!'),
        SquadMember(id: 'm1', name: 'Rohan S.', avatar: '🦁', attendancePct: 82, streak: 14, estimatedSGPA: 8.85, statusMessage: 'In Class'),
        SquadMember(id: 'm2', name: 'Priya P.', avatar: '👩‍🔬', attendancePct: 91, streak: 26, estimatedSGPA: 9.40, statusMessage: 'Studying'),
      ],
      messages: [
        ChatMessage(id: 'm_join', senderId: 'system', senderName: 'System', senderAvatar: '🤖', text: '$studentName joined the room with code $cleanCode!', timestamp: 'Just now', isSystem: true),
      ],
    );

    squadGroups.add(newSquad);
    activeSquadId = newSquad.id;
    saveToPreferences();
    notifyListeners();
  }

  void createSquad(String name, String icon, {String description = '', String category = 'Classroom', String colorHex = '#22C55E'}) {
    final code = 'BQ${(1000 + (DateTime.now().millisecondsSinceEpoch % 9000))}';
    final newSquad = SquadGroup(
      id: 'sq_${DateTime.now().millisecondsSinceEpoch}',
      code: code,
      name: name.trim().isEmpty ? 'My College Squad' : name.trim(),
      icon: icon.isEmpty ? '🚀' : icon,
      description: description.isEmpty ? 'General student chat & bunk room' : description,
      category: category,
      themeColorHex: colorHex,
      members: [
        SquadMember(id: 'me', name: studentName, avatar: studentAvatar, attendancePct: overallPercentage, streak: streakDays, estimatedSGPA: cumulativeGPA, statusMessage: 'Squad Host 👑'),
      ],
      messages: [
        ChatMessage(id: 'm_init', senderId: 'system', senderName: 'System', senderAvatar: '🤖', text: 'Room created by $studentName. Share code $code with your classmates!', timestamp: 'Just now', isSystem: true),
      ],
    );

    squadGroups.add(newSquad);
    activeSquadId = newSquad.id;
    saveToPreferences();
    notifyListeners();
  }

  void updateSquadDetails(String squadId, {String? name, String? icon, String? description, String? category, String? colorHex}) {
    final s = squadGroups.where((item) => item.id == squadId).firstOrNull;
    if (s != null) {
      if (name != null && name.isNotEmpty) s.name = name;
      if (icon != null && icon.isNotEmpty) s.icon = icon;
      if (description != null) s.description = description;
      if (category != null) s.category = category;
      if (colorHex != null) s.themeColorHex = colorHex;
      saveToPreferences();
      notifyListeners();
    }
  }

  void deleteSquad(String squadId) {
    squadGroups.removeWhere((s) => s.id == squadId);
    if (squadGroups.isNotEmpty) {
      activeSquadId = squadGroups.first.id;
    } else {
      activeSquadId = null;
    }
    saveToPreferences();
    notifyListeners();
  }

  void sendSquadMessage(String text, {bool isBunkAlert = false}) {
    final s = activeSquad;
    if (s == null || text.trim().isEmpty) return;

    final now = DateTime.now();
    final hour = now.hour == 0 ? 12 : (now.hour > 12 ? now.hour - 12 : now.hour);
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final min = now.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$min $period';

    s.messages.add(ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'me',
      senderName: studentName,
      senderAvatar: studentAvatar,
      text: text.trim(),
      timestamp: timeStr,
      isBunkAlert: isBunkAlert,
    ));

    saveToPreferences();
    notifyListeners();
  }

  void voteBunkPoll(String pollId, bool voteBunk) {
    if (activeSquad == null) return;
    final p = activeSquad!.polls.where((item) => item.id == pollId).firstOrNull;
    if (p != null) {
      if (voteBunk) {
        if (!p.userVotedBunk) {
          p.bunkVotes += 1;
          if (p.userVotedAttend) {
            p.attendVotes = (p.attendVotes - 1).clamp(0, 9999);
            p.userVotedAttend = false;
          }
          p.userVotedBunk = true;
        }
      } else {
        if (!p.userVotedAttend) {
          p.attendVotes += 1;
          if (p.userVotedBunk) {
            p.bunkVotes = (p.bunkVotes - 1).clamp(0, 9999);
            p.userVotedBunk = false;
          }
          p.userVotedAttend = true;
        }
      }
      saveToPreferences();
      notifyListeners();
    }
  }

  void addBunkPoll(String question, String subject) {
    if (activeSquad == null) return;
    activeSquad!.polls.insert(
      0,
      BunkPoll(
        id: 'p_${DateTime.now().millisecondsSinceEpoch}',
        question: question,
        subject: subject,
        creator: studentName,
        bunkVotes: 1,
        userVotedBunk: true,
      ),
    );
    saveToPreferences();
    notifyListeners();
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

  void addRoutineSlot(String day, String subjectName, String startTime, String endTime, String room, String faculty, {int periodsCount = 1}) {
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
      periodsCount: periodsCount,
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

  void saveSubjectMarks(SubjectMarks updatedMarks) {
    final idx = marks.indexWhere((m) => m.subjectId == updatedMarks.subjectId);
    if (idx != -1) {
      marks[idx] = updatedMarks;
    } else {
      marks.add(updatedMarks);
    }
    saveToPreferences();
    notifyListeners();
  }

  void updateAssessment(String subjectId, String assessmentId, {String? name, double? obtained, double? maxMarks}) {
    final m = marks.where((item) => item.subjectId == subjectId).firstOrNull;
    if (m != null) {
      final a = m.assessments.where((item) => item.id == assessmentId).firstOrNull;
      if (a != null) {
        if (name != null) a.name = name;
        if (obtained != null) a.obtainedMarks = obtained;
        if (maxMarks != null) a.maxMarks = maxMarks;
        saveToPreferences();
        notifyListeners();
      }
    }
  }

  void addAssessment(String subjectId, String name, double maxMarks, double? obtainedMarks) {
    final m = marks.where((item) => item.subjectId == subjectId).firstOrNull;
    if (m != null) {
      m.assessments.add(ExamAssessment(
        id: 'asm_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        maxMarks: maxMarks,
        obtainedMarks: obtainedMarks,
      ));
      saveToPreferences();
      notifyListeners();
    }
  }

  void removeAssessment(String subjectId, String assessmentId) {
    final m = marks.where((item) => item.subjectId == subjectId).firstOrNull;
    if (m != null) {
      m.assessments.removeWhere((a) => a.id == assessmentId);
      saveToPreferences();
      notifyListeners();
    }
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

  int get totalTeachingDays {
    if (semesterEndDate.isBefore(semesterStartDate)) return 0;
    int days = 0;
    DateTime cur = semesterStartDate;
    while (cur.isBefore(semesterEndDate)) {
      if (cur.weekday != DateTime.saturday && cur.weekday != DateTime.sunday) {
        days++;
      }
      cur = cur.add(const Duration(days: 1));
    }
    return days;
  }

  void updateSemesterDates(DateTime start, DateTime end) {
    semesterStartDate = start;
    semesterEndDate = end;
    saveToPreferences();
    notifyListeners();
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

  void setDailyNote(String dateStr, String note) {
    if (note.trim().isEmpty) {
      dailyNotes.remove(dateStr);
    } else {
      dailyNotes[dateStr] = note;
    }
    saveToPreferences();
    notifyListeners();
  }

  void completeOnboarding() {
    onboardingCompleted = true;
    saveToPreferences();
    notifyListeners();
  }

  void updateProfile(String name, {String? deg, String? crs, String? sem, String? avatar}) {
    studentName = name;
    if (deg != null) degree = deg;
    if (crs != null) course = crs;
    if (sem != null) semester = sem;
    if (avatar != null) studentAvatar = avatar;
    saveToPreferences();
    notifyListeners();
  }

  void markPresent(String subjectId, String date, {String day = '', String time = '', int count = 1, String note = ''}) {
    final s = subjects.where((item) => item.id == subjectId).firstOrNull;
    if (s != null) {
      s.markPresent(date, day: day, time: time, count: count, note: note);
      streakDays += 1;
      _checkAchievements();
      saveToPreferences();
      notifyListeners();
    }
  }

  void markAbsent(String subjectId, String date, {String day = '', String time = '', int count = 1, String note = ''}) {
    final s = subjects.where((item) => item.id == subjectId).firstOrNull;
    if (s != null) {
      s.markAbsent(date, day: day, time: time, count: count, note: note);
      saveToPreferences();
      notifyListeners();
    }
  }

  void deleteAttendanceRecord(String subjectId, int recordIndex) {
    final s = subjects.where((item) => item.id == subjectId).firstOrNull;
    if (s != null) {
      s.deleteRecord(recordIndex);
      saveToPreferences();
      notifyListeners();
    }
  }

  void restoreAttendanceRecord(String subjectId, AttendanceRecord record, int index) {
    final s = subjects.where((item) => item.id == subjectId).firstOrNull;
    if (s != null) {
      if (index >= 0 && index <= s.history.length) {
        s.history.insert(index, record);
      } else {
        s.history.add(record);
      }
      if (record.status.toLowerCase() == 'present') {
        s.attended += record.periods;
      }
      s.total += record.periods;
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

  void restoreSubject(Subject s, {SubjectMarks? m, List<RoutineSlot>? slots, int? index}) {
    if (index != null && index >= 0 && index <= subjects.length) {
      subjects.insert(index, s);
    } else {
      subjects.add(s);
    }
    if (m != null) {
      marks.add(m);
    } else {
      marks.add(SubjectMarks(subjectId: s.id, subjectName: s.name));
    }
    if (slots != null && slots.isNotEmpty) {
      routine.addAll(slots);
    }
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
