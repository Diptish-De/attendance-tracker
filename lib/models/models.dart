enum AttendanceRisk { safe, caution, danger, critical }

class AttendanceRecord {
  final String date;
  final String status; // 'present', 'absent', 'holiday'

  AttendanceRecord({required this.date, required this.status});

  Map<String, dynamic> toJson() => {'date': date, 'status': status};

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(date: json['date'], status: json['status']);
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
    if (p >= 80) return AttendanceRisk.safe;
    if (p >= 75) return AttendanceRisk.caution;
    if (p >= 70) return AttendanceRisk.danger;
    return AttendanceRisk.critical;
  }

  int get safeSkips {
    if (total == 0) return 0;
    // Formula: how many consecutive skips can we take while keeping attended / (total + skips) >= minRequired
    final minRatio = minRequiredPercentage / 100.0;
    if (attended / total < minRatio) return 0;
    final maxTotal = (attended / minRatio).floor();
    return (maxTotal - total).clamp(0, 999);
  }

  int neededClassesToReach(double targetPercentage) {
    // Formula: (attended + x) / (total + x) >= targetRatio
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
        id: json['id'],
        name: json['name'],
        icon: json['icon'],
        faculty: json['faculty'],
        attended: json['attended'],
        total: json['total'],
        minRequiredPercentage: (json['minRequiredPercentage'] ?? 75.0).toDouble(),
        history: (json['history'] as List<dynamic>?)
                ?.map((e) => AttendanceRecord.fromJson(e))
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
        id: json['id'],
        icon: json['icon'],
        title: json['title'],
        desc: json['desc'],
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
        id: json['id'],
        type: json['type'],
        dates: json['dates'],
        days: json['days'],
        status: json['status'],
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
        name: json['name'],
        icon: json['icon'],
        available: json['available'],
        used: json['used'],
        total: json['total'],
      );
}
