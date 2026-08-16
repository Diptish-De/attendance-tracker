import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/colors.dart';
import '../widgets/painters.dart';

class SimulatorScreen extends StatefulWidget {
  final List<Subject> subjects;
  final String? initialSubjectId;

  const SimulatorScreen({
    super.key,
    required this.subjects,
    this.initialSubjectId,
  });

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  late String _selectedSubjectId;
  double _skipsToSimulate = 1.0;

  @override
  void initState() {
    super.initState();
    _selectedSubjectId = widget.initialSubjectId ??
        (widget.subjects.isNotEmpty ? widget.subjects.first.id : '');
  }

  @override
  void didUpdateWidget(covariant SimulatorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSubjectId != null &&
        widget.initialSubjectId != _selectedSubjectId) {
      _selectedSubjectId = widget.initialSubjectId!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final subject = widget.subjects.firstWhere(
      (s) => s.id == _selectedSubjectId,
      orElse: () => widget.subjects.first,
    );

    final curPct = subject.percentage;
    final skips = _skipsToSimulate.round();
    final afterPct = subject.total + skips == 0
        ? 0
        : ((subject.attended / (subject.total + skips)) * 100).round();

    AttendanceRisk afterRisk = AttendanceRisk.safe;
    if (afterPct < 70) {
      afterRisk = AttendanceRisk.critical;
    } else if (afterPct < 75) {
      afterRisk = AttendanceRisk.danger;
    } else if (afterPct < 80) {
      afterRisk = AttendanceRisk.caution;
    }

    String verdictText = 'VERDICT: SAFE TO BUNK';
    String verdictSub = 'You can skip! Attendance stays comfortably above 75%.';
    IconData verdictIcon = Icons.check_circle_rounded;

    if (afterRisk == AttendanceRisk.caution) {
      verdictText = 'VERDICT: BORDERLINE / RISKY';
      verdictSub = 'Borderline attendance. One more miss will hurt you.';
      verdictIcon = Icons.warning_amber_rounded;
    } else if (afterRisk == AttendanceRisk.danger) {
      verdictText = 'VERDICT: DANGER ZONE';
      verdictSub = 'Very close to falling below university 75% limit.';
      verdictIcon = Icons.local_fire_department_rounded;
    } else if (afterRisk == AttendanceRisk.critical) {
      verdictText = "DON'T EVEN THINK ABOUT IT 💀";
      verdictSub = 'You will drop below 75% criteria. Professor will notice.';
      verdictIcon = Icons.dangerous_rounded;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Bunk Simulator',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Predict future attendance & calculate safe bunker limits',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Simulator Hero Config
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'What if you skip this class?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text('🤔', style: TextStyle(fontSize: 28)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'SELECT SUBJECT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedSubjectId,
                                isExpanded: true,
                                items: widget.subjects.map((s) {
                                  return DropdownMenuItem(
                                    value: s.id,
                                    child: Text(
                                      '${s.name} (${s.faculty})',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedSubjectId = val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Slider Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'CLASSES TO SKIP',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '$skips class${skips > 1 ? 'es' : ''}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: _skipsToSimulate,
                            min: 1,
                            max: 8,
                            divisions: 7,
                            activeColor: AppColors.primary,
                            onChanged: (val) =>
                                setState(() => _skipsToSimulate = val),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Simulation Result Comparison
                    const Text(
                      'Simulation Result',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text(
                                    'Current',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$curPct%',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color:
                                          AppColors.getRiskColor(subject.risk),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFF1F5F9),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'After Skipping',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$afterPct%',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color:
                                          AppColors.getRiskColor(afterRisk),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Verdict Box
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.getRiskBg(afterRisk),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.getRiskColor(afterRisk),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    verdictIcon,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        verdictText,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.getRiskColor(
                                              afterRisk),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        verdictSub,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.getRiskColor(
                                                  afterRisk)
                                              .withOpacity(0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Quick Scenarios
                    const Text(
                      'What if you skip more?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        _buildScenarioCard('Tomorrow', 1, subject),
                        const SizedBox(width: 8),
                        _buildScenarioCard('Next 2 Days', 2, subject),
                        const SizedBox(width: 8),
                        _buildScenarioCard('Whole Week', 5, subject),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScenarioCard(String title, int count, Subject s) {
    final pctResult = ((s.attended / (s.total + count)) * 100).round();
    AttendanceRisk r = AttendanceRisk.safe;
    if (pctResult < 70) {
      r = AttendanceRisk.critical;
    } else if (pctResult < 75) {
      r = AttendanceRisk.danger;
    } else if (pctResult < 80) {
      r = AttendanceRisk.caution;
    }

    final isSelected = _skipsToSimulate.round() == count;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _skipsToSimulate = count.toDouble()),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.getRiskColor(r)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$pctResult%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.getRiskColor(r),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppColors.getRiskLabel(r),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: AppColors.getRiskColor(r),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
