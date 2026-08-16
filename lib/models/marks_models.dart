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
      // Backwards compatibility migration
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
