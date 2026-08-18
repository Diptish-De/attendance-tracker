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

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
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

      final subjectsJson = prefs.getString('subjects');
      if (subjectsJson != null) {
        final List list = jsonDecode(subjectsJson);
        subjects = list.map((e) => Subject.fromJson(e)).toList();
      } else {
        if (onboardingCompleted) {
          _initDefaultSubjects();
        } else {
          subjects = [];
        }
      }

      final routineJson = prefs.getString('routine');
      if (routineJson != null) {
        final List list = jsonDecode(routineJson);
        routine = list.map((e) => RoutineSlot.fromJson(e)).toList();
      } else {
        if (onboardingCompleted) {
          _initDefaultRoutine();
        } else {
          routine = [];
        }
      }

      final marksJson = prefs.getString('marks');
      if (marksJson != null) {
        final List list = jsonDecode(marksJson);
        marks = list.map((e) => SubjectMarks.fromJson(e)).toList();
      } else {
        if (onboardingCompleted) {
          _initDefaultMarks();
        } else {
          marks = [];
        }
      }

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

      final leavesJson = prefs.getString('leaves');
      if (leavesJson != null) {
        final List list = jsonDecode(leavesJson);
        leaveHistory = list.map((e) => LeaveItem.fromJson(e)).toList();
      } else {
        if (onboardingCompleted) {
          _initDefaultLeaves();
        } else {
          leaveHistory = [];
        }
      }

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

      activeSquadId = prefs.getString('activeSquadId');
      final squadListJson = prefs.getString('squadGroups');
      if (squadListJson != null) {
        final List list = jsonDecode(squadListJson);
        squadGroups = list.map((e) => SquadGroup.fromJson(e)).toList();
      } else {
        if (onboardingCompleted) {
          _initDefaultSquad();
        } else {
          squadGroups = [];
        }
      }

      final dailyNotesJson = prefs.getString('dailyNotes');
      if (dailyNotesJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(dailyNotesJson);
        dailyNotes = decoded.map((key, value) => MapEntry(key, value.toString()));
      } else {
        dailyNotes = {};
      }

      // Auto-delete chats and polls older than 24 hours
      _cleanupExpiredSquadData();
    } catch (e) {
      _initAllDefaults();
    }
    notifyListeners();
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
    } catch (_) {}
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
      SubjectMarks(
        subjectId: 'dsa',
        subjectName: 'DSA',
        credits: 4,
        assessments: [
          ExamAssessment(id: 'cia1', name: 'CIA 1', obtainedMarks: 18, maxMarks: 20),
          ExamAssessment(id: 'cia2', name: 'CIA 2', obtainedMarks: 19, maxMarks: 20),
          ExamAssessment(id: 'cia3', name: 'CIA 3', obtainedMarks: 17, maxMarks: 20),
          ExamAssessment(id: 'endsem', name: 'End Sem', obtainedMarks: 88, maxMarks: 100),
        ],
      ),
      SubjectMarks(
        subjectId: 'oop',
        subjectName: 'OOP',
        credits: 4,
        assessments: [
          ExamAssessment(id: 'cia1', name: 'CIA 1', obtainedMarks: 16, maxMarks: 20),
          ExamAssessment(id: 'cia2', name: 'CIA 2', obtainedMarks: 17.5, maxMarks: 20),
          ExamAssessment(id: 'cia3', name: 'CIA 3', obtainedMarks: 18, maxMarks: 20),
          ExamAssessment(id: 'endsem', name: 'End Sem', obtainedMarks: 82, maxMarks: 100),
        ],
      ),
      SubjectMarks(
        subjectId: 'dm',
        subjectName: 'DM',
        credits: 3,
        assessments: [
          ExamAssessment(id: 'cia1', name: 'CIA 1', obtainedMarks: 19, maxMarks: 20),
          ExamAssessment(id: 'cia2', name: 'CIA 2', obtainedMarks: 20, maxMarks: 20),
          ExamAssessment(id: 'cia3', name: 'CIA 3', obtainedMarks: 18.5, maxMarks: 20),
          ExamAssessment(id: 'endsem', name: 'End Sem', obtainedMarks: 91, maxMarks: 100),
        ],
      ),
      SubjectMarks(
        subjectId: 'dsco',
        subjectName: 'DSCO',
        credits: 3,
        assessments: [
          ExamAssessment(id: 'cia1', name: 'CIA 1', obtainedMarks: 14, maxMarks: 20),
          ExamAssessment(id: 'cia2', name: 'CIA 2', obtainedMarks: 15, maxMarks: 20),
          ExamAssessment(id: 'cia3', name: 'CIA 3', obtainedMarks: 13.5, maxMarks: 20),
          ExamAssessment(id: 'endsem', name: 'End Sem', obtainedMarks: 74, maxMarks: 100),
        ],
      ),
      SubjectMarks(
        subjectId: 'dbms',
        subjectName: 'DBMS',
        credits: 4,
        assessments: [
          ExamAssessment(id: 'cia1', name: 'CIA 1', obtainedMarks: 15, maxMarks: 20),
          ExamAssessment(id: 'cia2', name: 'CIA 2', obtainedMarks: 16.5, maxMarks: 20),
          ExamAssessment(id: 'cia3', name: 'CIA 3', obtainedMarks: 16, maxMarks: 20),
          ExamAssessment(id: 'endsem', name: 'End Sem', obtainedMarks: 79, maxMarks: 100),
        ],
      ),
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

  void _initDefaultSquad() {
    squadGroups = [
      SquadGroup(
        id: 'sq_cse_a',
        code: 'BUNK42',
        name: 'CSE Backbenchers',
        icon: '🚀',
        description: 'Official mass-bunk planning & notes sync for Section A',
        category: 'Classroom / Batch',
        themeColorHex: '#22C55E',
        members: [
          SquadMember(id: 'me', name: studentName, avatar: studentAvatar, attendancePct: overallPercentage, streak: streakDays, estimatedSGPA: cumulativeGPA, statusMessage: 'In Class 💻'),
          SquadMember(id: 'm1', name: 'Rohan Sharma', avatar: '🦁', attendancePct: 82, streak: 14, estimatedSGPA: 8.85, statusMessage: 'In DSA Lab 💻'),
          SquadMember(id: 'm2', name: 'Priya Patel', avatar: '👩‍🔬', attendancePct: 91, streak: 26, estimatedSGPA: 9.40, statusMessage: 'Front row note taker 📚'),
          SquadMember(id: 'm3', name: 'Kabir Verma', avatar: '🕶️', attendancePct: 76, streak: 4, estimatedSGPA: 7.90, statusMessage: 'Bunking DBMS today 🍕'),
          SquadMember(id: 'm4', name: 'Sneha Roy', avatar: '🎨', attendancePct: 88, streak: 18, estimatedSGPA: 8.95, statusMessage: 'In Library with assignment ☕'),
        ],
        polls: [
          BunkPoll(
            id: 'p1',
            question: 'Mass bunk DBMS 3rd period for Canteen Treat? 🍕',
            subject: 'DBMS',
            creator: 'Kabir Verma',
            bunkVotes: 7,
            attendVotes: 2,
          ),
        ],
        messages: [
          ChatMessage(id: 'msg1', senderId: 'm3', senderName: 'Kabir Verma', senderAvatar: '🕶️', text: 'Prof is taking proxy checks in DBMS today, be alert guys!', timestamp: '09:15 AM'),
          ChatMessage(id: 'msg2', senderId: 'm1', senderName: 'Rohan Sharma', senderAvatar: '🦁', text: 'DSA assignment solutions uploaded to the drive 📑', timestamp: '09:22 AM'),
          ChatMessage(id: 'msg3', senderId: 'm2', senderName: 'Priya Patel', senderAvatar: '👩‍🔬', text: 'Who wants to study for CIA 2 after lunch?', timestamp: '10:05 AM'),
        ],
      ),
      SquadGroup(
        id: 'sq_hostel',
        code: 'HOSTEL7',
        name: 'Block 4 Warriors',
        icon: '🍕',
        description: 'Night outs, gaming sessions & late-night attendance check',
        category: 'Hostel / Flat',
        themeColorHex: '#8B5CF6',
        members: [
          SquadMember(id: 'me', name: studentName, avatar: studentAvatar, attendancePct: overallPercentage, streak: streakDays, estimatedSGPA: cumulativeGPA, statusMessage: 'Hostel Room 402'),
          SquadMember(id: 'm1', name: 'Aakash Roy', avatar: '⚡', attendancePct: 78, streak: 8, estimatedSGPA: 8.10, statusMessage: 'Gaming in 405 🎮'),
          SquadMember(id: 'm2', name: 'Dev Sen', avatar: '🎧', attendancePct: 74, streak: 3, estimatedSGPA: 7.60, statusMessage: 'Sleeping 😴'),
        ],
        messages: [
          ChatMessage(id: 'msg_h1', senderId: 'm1', senderName: 'Aakash Roy', senderAvatar: '⚡', text: 'Anyone awake for FIFA in room 405?', timestamp: 'Yesterday, 11:30 PM'),
        ],
      ),
    ];
    activeSquadId = 'sq_cse_a';
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
