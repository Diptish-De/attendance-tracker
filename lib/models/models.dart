enum AttendanceRisk { safe, caution, danger, critical }

class AttendanceRecord {
  final String date;   // e.g. "Aug 17, 2026"
  final String day;    // e.g. "Monday"
  final String time;   // e.g. "09:00 AM"
  final int periods;   // e.g. 1 or 2
  final String status; // 'present', 'absent', 'holiday'
  final String note;

  AttendanceRecord({
    required this.date,
    this.day = '',
    this.time = '',
    this.periods = 1,
    required this.status,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'day': day,
        'time': time,
        'periods': periods,
        'status': status,
        'note': note,
      };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        date: json['date'] ?? '',
        day: json['day'] ?? '',
        time: json['time'] ?? '',
        periods: json['periods'] ?? 1,
        status: json['status'] ?? 'present',
        note: json['note'] ?? '',
      );
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
  final int periodsCount; // e.g. 1 period (theory) or 2/3 periods (lab / double lecture)

  RoutineSlot({
    required this.id,
    required this.day,
    required this.subjectName,
    required this.subjectId,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.faculty,
    this.periodsCount = 1,
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
        'periodsCount': periodsCount,
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
        periodsCount: json['periodsCount'] ?? 1,
      );
}

// ─── Individual Assessment Entry Model ─────────────────────────────────────────
class ExamAssessment {
  String id;
  String name; // e.g. "CIA 1", "CIA 2", "CIA 3", "End Sem"
  double? obtainedMarks;
  double maxMarks; // e.g. 20.0, 100.0

  ExamAssessment({
    required this.id,
    required this.name,
    this.obtainedMarks,
    this.maxMarks = 20.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'obtainedMarks': obtainedMarks,
        'maxMarks': maxMarks,
      };

  factory ExamAssessment.fromJson(Map<String, dynamic> json) => ExamAssessment(
        id: json['id'] ?? '',
        name: json['name'] ?? 'Exam',
        obtainedMarks: json['obtainedMarks'] != null
            ? (json['obtainedMarks'] as num).toDouble()
            : null,
        maxMarks: (json['maxMarks'] != null
                ? (json['maxMarks'] as num).toDouble()
                : 20.0)
            .clamp(1.0, 1000.0),
      );
}

// ─── Marks Model (Fully Customizable Assessments) ─────────────────────────────
class SubjectMarks {
  final String subjectId;
  final String subjectName;
  int credits;
  List<ExamAssessment> assessments;

  SubjectMarks({
    required this.subjectId,
    required this.subjectName,
    this.credits = 4,
    List<ExamAssessment>? assessments,
  }) : assessments = assessments ??
            [
              ExamAssessment(id: 'cia1', name: 'CIA 1', obtainedMarks: 18, maxMarks: 20),
              ExamAssessment(id: 'cia2', name: 'CIA 2', obtainedMarks: 19, maxMarks: 20),
              ExamAssessment(id: 'cia3', name: 'CIA 3', obtainedMarks: 17, maxMarks: 20),
              ExamAssessment(id: 'endsem', name: 'End Sem', obtainedMarks: 85, maxMarks: 100),
            ];

  double get totalObtained => assessments.fold<double>(
      0.0, (acc, a) => acc + (a.obtainedMarks ?? 0.0));

  double get totalMax =>
      assessments.fold<double>(0.0, (acc, a) => acc + a.maxMarks);

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
        'credits': credits,
        'assessments': assessments.map((a) => a.toJson()).toList(),
      };

  factory SubjectMarks.fromJson(Map<String, dynamic> json) {
    List<ExamAssessment> list = [];
    if (json['assessments'] != null) {
      final List raw = json['assessments'];
      list = raw.map((e) => ExamAssessment.fromJson(e)).toList();
    } else {
      list = [
        ExamAssessment(
          id: 'cia1',
          name: 'CIA 1',
          obtainedMarks: json['internal1'] != null ? (json['internal1'] as num).toDouble() : 18,
          maxMarks: 20,
        ),
        ExamAssessment(
          id: 'cia2',
          name: 'CIA 2',
          obtainedMarks: json['internal2'] != null ? (json['internal2'] as num).toDouble() : 19,
          maxMarks: 20,
        ),
        ExamAssessment(
          id: 'cia3',
          name: 'CIA 3',
          obtainedMarks: json['assignment'] != null ? (json['assignment'] as num).toDouble() : 17,
          maxMarks: 20,
        ),
        ExamAssessment(
          id: 'endsem',
          name: 'End Sem',
          obtainedMarks: json['endSem'] != null ? (json['endSem'] as num).toDouble() : 85,
          maxMarks: 100,
        ),
      ];
    }

    return SubjectMarks(
      subjectId: json['subjectId'] ?? '',
      subjectName: json['subjectName'] ?? '',
      credits: json['credits'] ?? 4,
      assessments: list,
    );
  }
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

  void markPresent(String date, {String day = '', String time = '', int count = 1, String note = ''}) {
    attended += count;
    total += count;
    history.insert(
        0,
        AttendanceRecord(
          date: date,
          day: day,
          time: time,
          periods: count,
          status: 'present',
          note: note,
        ));
  }

  void markAbsent(String date, {String day = '', String time = '', int count = 1, String note = ''}) {
    total += count;
    history.insert(
        0,
        AttendanceRecord(
          date: date,
          day: day,
          time: time,
          periods: count,
          status: 'absent',
          note: note,
        ));
  }

  void deleteRecord(int index) {
    if (index >= 0 && index < history.length) {
      final rec = history[index];
      if (rec.status == 'present') {
        attended = (attended - rec.periods).clamp(0, 9999);
      }
      total = (total - rec.periods).clamp(0, 9999);
      history.removeAt(index);
    }
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
