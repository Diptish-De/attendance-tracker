enum AttendanceRisk { safe, caution, danger, critical }

class AttendanceRecord {
  final String date;
  final String status; // 'present', 'absent', 'holiday'

  AttendanceRecord({required this.date, required this.status});

  Map<String, dynamic> toJson() => {'date': date, 'status': status};

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(date: json['date'] ?? '', status: json['status'] ?? 'present');
}

// ─── Routine / Timetable Model ────────────────────────────────────────────────
class RoutineSlot {
  final String id;
  final String day; // 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  final String subjectName;
  final String subjectId;
  final String startTime; // '09:00 AM'
  final String endTime;   // '10:00 AM'
  final String room;
  final String faculty;

  RoutineSlot({
    required this.id,
    required this.day,
    required this.subjectName,
    required this.subjectId,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.faculty,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'day': day,
        'subjectName': subjectName,
        'subjectId': subjectId,
        'startTime': startTime,
        'endTime': endTime,
        'room': room,
        'faculty': faculty,
      };

  factory RoutineSlot.fromJson(Map<String, dynamic> json) => RoutineSlot(
        id: json['id'] ?? '',
        day: json['day'] ?? 'Monday',
        subjectName: json['subjectName'] ?? '',
        subjectId: json['subjectId'] ?? '',
        startTime: json['startTime'] ?? '09:00 AM',
        endTime: json['endTime'] ?? '10:00 AM',
        room: json['room'] ?? '',
        faculty: json['faculty'] ?? '',
      );
}

// ─── Marks Model (Internal + End-Sem) ─────────────────────────────────────────
class SubjectMarks {
  final String subjectId;
  final String subjectName;
  double? internal1;
  double? internal1Max;
  double? internal2;
  double? internal2Max;
  double? assignment;
  double? assignmentMax;
  double? endSem;
  double? endSemMax;
  int credits;

  SubjectMarks({
    required this.subjectId,
    required this.subjectName,
    this.internal1,
    this.internal1Max = 25,
    this.internal2,
    this.internal2Max = 25,
    this.assignment,
    this.assignmentMax = 10,
    this.endSem,
    this.endSemMax = 100,
    this.credits = 4,
  });

  double get totalObtained =>
      (internal1 ?? 0) + (internal2 ?? 0) + (assignment ?? 0) + (endSem ?? 0);

  double get totalMax =>
      (internal1Max ?? 25) + (internal2Max ?? 25) + (assignmentMax ?? 10) + (endSemMax ?? 100);

  double get percentage =>
      totalMax == 0 ? 0 : ((totalObtained / totalMax) * 100);

  String get grade {
    final p = percentage;
    if (p >= 90) return 'O (Outstanding)';
    if (p >= 80) return 'A+ (Excellent)';
    if (p >= 70) return 'A (Very Good)';
    if (p >= 60) return 'B+ (Good)';
    if (p >= 50) return 'B (Average)';
    if (p >= 40) return 'P (Pass)';
    return 'F (Fail)';
  }

  double get gradePoint {
    final p = percentage;
    if (p >= 90) return 10.0;
    if (p >= 80) return 9.0;
    if (p >= 70) return 8.0;
    if (p >= 60) return 7.0;
    if (p >= 50) return 6.0;
    if (p >= 40) return 5.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() => {
        'subjectId': subjectId,
        'subjectName': subjectName,
        'internal1': internal1,
        'internal1Max': internal1Max,
        'internal2': internal2,
        'internal2Max': internal2Max,
        'assignment': assignment,
        'assignmentMax': assignmentMax,
        'endSem': endSem,
        'endSemMax': endSemMax,
        'credits': credits,
      };

  factory SubjectMarks.fromJson(Map<String, dynamic> json) => SubjectMarks(
        subjectId: json['subjectId'] ?? '',
        subjectName: json['subjectName'] ?? '',
        internal1: json['internal1'] != null ? (json['internal1'] as num).toDouble() : null,
        internal1Max: json['internal1Max'] != null ? (json['internal1Max'] as num).toDouble() : 25,
        internal2: json['internal2'] != null ? (json['internal2'] as num).toDouble() : null,
        internal2Max: json['internal2Max'] != null ? (json['internal2Max'] as num).toDouble() : 25,
        assignment: json['assignment'] != null ? (json['assignment'] as num).toDouble() : null,
        assignmentMax: json['assignmentMax'] != null ? (json['assignmentMax'] as num).toDouble() : 10,
        endSem: json['endSem'] != null ? (json['endSem'] as num).toDouble() : null,
        endSemMax: json['endSemMax'] != null ? (json['endSemMax'] as num).toDouble() : 100,
        credits: json['credits'] ?? 4,
      );
}

class Subject {
  final String id;
  String name;
  String icon;
  String faculty;
  int attended;
  int total;
  double minRequiredPercentage;
  List<AttendanceRecord> history;

  Subject({
    required this.id,
    required this.name,
    required this.icon,
    required this.faculty,
    required this.attended,
    required this.total,
    this.minRequiredPercentage = 75.0,
    List<AttendanceRecord>? history,
  }) : history = history ?? [];

  int get percentage => total == 0 ? 0 : ((attended / total) * 100).round();

  AttendanceRisk get risk {
    final p = percentage;
    if (p >= minRequiredPercentage + 5) return AttendanceRisk.safe;
    if (p >= minRequiredPercentage) return AttendanceRisk.caution;
    if (p >= minRequiredPercentage - 5) return AttendanceRisk.danger;
    return AttendanceRisk.critical;
  }

  int get safeSkips {
    if (total == 0) return 0;
    final minRatio = minRequiredPercentage / 100.0;
    if (attended / total < minRatio) return 0;
    final maxTotal = (attended / minRatio).floor();
    return (maxTotal - total).clamp(0, 999);
  }

  int neededClassesToReach(double targetPercentage) {
    final targetRatio = targetPercentage / 100.0;
    if (targetRatio >= 1.0) return 0;
    final needed = ((targetRatio * total - attended) / (1 - targetRatio)).ceil();
    return needed > 0 ? needed : 0;
  }

  void markPresent(String date) {
    attended += 1;
    total += 1;
    history.insert(0, AttendanceRecord(date: date, status: 'present'));
  }

  void markAbsent(String date) {
    total += 1;
    history.insert(0, AttendanceRecord(date: date, status: 'absent'));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'faculty': faculty,
        'attended': attended,
        'total': total,
        'minRequiredPercentage': minRequiredPercentage,
        'history': history.map((h) => h.toJson()).toList(),
      };

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        icon: json['icon'] ?? '📚',
        faculty: json['faculty'] ?? '',
        attended: json['attended'] ?? 0,
        total: json['total'] ?? 0,
        minRequiredPercentage: (json['minRequiredPercentage'] ?? 75.0).toDouble(),
        history: (json['history'] as List<dynamic>?)
                ?.map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class Achievement {
  final String id;
  final String icon;
  final String title;
  final String desc;
  bool unlocked;

  Achievement({
    required this.id,
    required this.icon,
    required this.title,
    required this.desc,
    this.unlocked = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'icon': icon,
        'title': title,
        'desc': desc,
        'unlocked': unlocked,
      };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'] ?? '',
        icon: json['icon'] ?? '🏆',
        title: json['title'] ?? '',
        desc: json['desc'] ?? '',
        unlocked: json['unlocked'] ?? false,
      );
}

class LeaveItem {
  final int id;
  final String type;
  final String dates;
  final int days;
  final String status;

  LeaveItem({
    required this.id,
    required this.type,
    required this.dates,
    required this.days,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'dates': dates,
        'days': days,
        'status': status,
      };

  factory LeaveItem.fromJson(Map<String, dynamic> json) => LeaveItem(
        id: json['id'] ?? 0,
        type: json['type'] ?? '',
        dates: json['dates'] ?? '',
        days: json['days'] ?? 1,
        status: json['status'] ?? 'Pending',
      );
}

class LeaveCategory {
  final String name;
  final String icon;
  int available;
  int used;
  final int total;

  LeaveCategory({
    required this.name,
    required this.icon,
    required this.available,
    required this.used,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'icon': icon,
        'available': available,
        'used': used,
        'total': total,
      };

  factory LeaveCategory.fromJson(Map<String, dynamic> json) => LeaveCategory(
        name: json['name'] ?? '',
        icon: json['icon'] ?? '🌴',
        available: json['available'] ?? 0,
        used: json['used'] ?? 0,
        total: json['total'] ?? 0,
      );
}
