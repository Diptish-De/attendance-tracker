import 'package:flutter/material.dart';
import '../services/attendance_store.dart';
import '../theme/colors.dart';

class OnboardingScreen extends StatefulWidget {
  final AttendanceDataStore store;
  final VoidCallback onFinish;

  const OnboardingScreen({
    super.key,
    required this.store,
    required this.onFinish,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  // Profile setup inputs
  final TextEditingController _nameController = TextEditingController(text: 'Arjun');
  final TextEditingController _degreeController = TextEditingController(text: 'B.Tech');
  final TextEditingController _courseController = TextEditingController(text: 'CSE');
  String _selectedSemester = 'Semester 3';

  final List<String> _semesters = [
    'Semester 1', 'Semester 2', 'Semester 3', 'Semester 4',
    'Semester 5', 'Semester 6', 'Semester 7', 'Semester 8'
  ];

  late DateTime _semesterStartDate;
  late DateTime _semesterEndDate;

  @override
  void initState() {
    super.initState();
    _semesterStartDate = widget.store.semesterStartDate;
    _semesterEndDate = widget.store.semesterEndDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Branding Logo
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset('assets/logo.png', width: 32, height: 32, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'BunkQuest',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  // Skip option (hidden on final setup screen)
                  if (_currentPageIndex < 3)
                    TextButton(
                      onPressed: () {
                        _pageController.animateToPage(
                          3,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text(
                        'Skip Setup',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Onboarding Slides (PageView)
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (idx) {
                  setState(() => _currentPageIndex = idx);
                },
                children: [
                  _buildSlide(
                    title: 'Smarter Attendance OS 🎓',
                    desc: 'Ditch basic registers. Track classes with real-time analytics, safe skips calculations, and smart academic schedules.',
                    iconText: '📊',
                    cardTitle: 'Dashboard Hub',
                    cardDesc: 'Your overall safety metric (Safe, Caution, Danger) is automatically calculated, telling you exactly where you stand in each subject.',
                    bgGradient: const [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
                  ),
                  _buildSlide(
                    title: 'Safe Bunk Simulator 🎯',
                    desc: 'Never get detailment letters. Input simulated leaves or bunk schedules to see exactly how your future attendance changes.',
                    iconText: '🔮',
                    cardTitle: 'Predict & Play',
                    cardDesc: 'Simulate marking future dates present or absent. Check how many classes you must attend to return to target 75%.',
                    bgGradient: const [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                  ),
                  _buildSlide(
                    title: 'Realtime Class Squads 💬',
                    desc: 'Connect with classmates. Join dedicated rooms to coordinate mass bunks, sync schedules, and share class notes in real-time.',
                    iconText: '⚡',
                    cardTitle: 'Supabase Live Chat',
                    cardDesc: 'Real-time room polls, group chat, and ephemeral messages that auto-delete after 24 hours to keep the squad chat clean.',
                    bgGradient: const [Color(0xFFFDF2F8), Color(0xFFFCE7F3)],
                  ),
                  _buildProfileSetupSlide(),
                ],
              ),
            ),

            // Bottom Navigation Indicators
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators dots
                  Row(
                    children: List.generate(4, (index) {
                      final active = index == _currentPageIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 6),
                        width: active ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active ? AppColors.primary : const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      );
                    }),
                  ),

                  // Action Button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPageIndex < 3) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _submitProfile();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentPageIndex == 3 ? "Let's Get Started!" : 'Next Slide',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide({
    required String title,
    required String desc,
    required String iconText,
    required String cardTitle,
    required String cardDesc,
    required List<Color> bgGradient,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: bgGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(iconText, style: const TextStyle(fontSize: 60)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),

          // Feature explanation card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cardTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cardDesc,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildProfileSetupSlide() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personalize BunkQuest ✏️',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Set your student profile details to customize your academic semester dashboard.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          // Setup Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name Input
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Your Full Name',
                    hintText: 'e.g. Arjun Dev',
                    prefixIcon: const Icon(Icons.person_rounded, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),

                // Degree & Course Row
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: _degreeController,
                        decoration: InputDecoration(
                          labelText: 'Degree',
                          hintText: 'e.g. B.Tech',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: TextField(
                        controller: _courseController,
                        decoration: InputDecoration(
                          labelText: 'Course / Branch',
                          hintText: 'e.g. CSE',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Semester Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedSemester,
                  decoration: InputDecoration(
                    labelText: 'Current Semester',
                    prefixIcon: const Icon(Icons.school_rounded, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _semesters
                      .map((sem) => DropdownMenuItem(value: sem, child: Text(sem)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedSemester = val);
                    }
                  },
                ),
                const SizedBox(height: 14),

                // Semester Term Dates
                const Text(
                  'Semester Duration (Teaching Days)',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _semesterStartDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => _semesterStartDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Start Date', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text('${_semesterStartDate.day}/${_semesterStartDate.month}/${_semesterStartDate.year}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _semesterEndDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => _semesterEndDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('End Date', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text('${_semesterEndDate.day}/${_semesterEndDate.month}/${_semesterEndDate.year}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitProfile() {
    final name = _nameController.text.trim();
    final deg = _degreeController.text.trim();
    final crs = _courseController.text.trim();

    widget.store.updateProfile(
      name.isEmpty ? 'Student' : name,
      deg: deg.isEmpty ? 'B.Tech' : deg,
      crs: crs.isEmpty ? 'CSE' : crs,
      sem: _selectedSemester,
    );

    widget.store.updateSemesterDates(_semesterStartDate, _semesterEndDate);
    widget.store.completeOnboarding();
    widget.onFinish();
  }
}
