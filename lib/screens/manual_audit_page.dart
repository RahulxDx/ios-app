import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/stellantis_colors.dart';
import '../models/manual_audit_model.dart';
import '../services/manual_audit_service.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class ManualAuditPage extends StatefulWidget {
  const ManualAuditPage({super.key});

  @override
  State<ManualAuditPage> createState() => _ManualAuditPageState();
}

class _ManualAuditPageState extends State<ManualAuditPage> {
  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dealerIdController = TextEditingController();
  final TextEditingController _dealerNameController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _dealerDetailsController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();

  // Date and Time
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedTime = DateTime.now();

  // Dropdown values
  String _selectedMonth = DateFormat('MMMM').format(DateTime.now());
  String _selectedComplianceStatus = 'Compliant';
  String _selectedShift = 'Morning Shift';
  String _selectedLevel1 = 'Level 1 - Critical';
  String _selectedSubCategory = 'Cleanliness';
  String _selectedCheckpoint = 'Surface Sanitation';
  String _selectedLanguage = 'English';
  String _selectedCountry = 'India';
  String _selectedZone = 'North Zone';

  double _confidenceLevel = 95.0;
  bool _isSubmitting = false;

  // Services
  final ManualAuditService _manualAuditService = ManualAuditService();
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  // Dropdown options
  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final List<String> _complianceStatuses = [
    'Compliant',
    'Non-Compliant',
    'Partial',
    'Under Review',
  ];

  final List<String> _shifts = [
    'Morning Shift',
    'Evening Shift',
    'Night Shift',
  ];

  final List<String> _levels = [
    'Level 1 - Critical',
    'Level 2 - Major',
    'Level 3 - Minor',
  ];

  final List<String> _subCategories = [
    'Cleanliness',
    'Safety',
    'Maintenance',
    'Hygiene',
    'Equipment',
  ];

  final List<String> _checkpoints = [
    'Surface Sanitation',
    'Floor Debris',
    'Sanitizer Stations',
    'Waste Receptacles',
    'Display Cleanliness',
  ];

  final List<String> _languages = [
    'English',
    'Hindi',
    'French',
    'German',
    'Spanish',
  ];

  final List<String> _countries = [
    'India',
    'USA',
    'UK',
    'France',
    'Germany',
    'Spain',
  ];

  final List<String> _zones = [
    'North Zone',
    'South Zone',
    'East Zone',
    'West Zone',
    'Central Zone',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadDraft();
  }

  void _loadUserData() {
    final user = _authService.currentUser;
    if (user != null) {
      _dealerIdController.text = user.id;
      _dealerNameController.text = user.name;
      _emailController.text = user.email;
    } else {
      // Default values if no user logged in
      _dealerIdController.text = 'DEALER001';
      _dealerNameController.text = 'Stellantis Dealer';
      _emailController.text = 'dealer@stellantis.com';
    }
  }

  /// Load draft from storage
  Future<void> _loadDraft() async {
    try {
      final draft = await _storageService.getJson('manual_audit_draft');
      if (draft != null) {
        if (!mounted) return;

        final shouldResume = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Resume Draft?'),
            content: const Text(
              'You have an unsaved draft. Would you like to resume it?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Discard'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Resume'),
              ),
            ],
          ),
        );

        if (shouldResume == true) {
          setState(() {
            _dealerIdController.text = draft['dealerId'] ?? '';
            _dealerNameController.text = draft['dealerName'] ?? '';
            _feedbackController.text = draft['feedback'] ?? '';
            _dealerDetailsController.text = draft['dealerDetails'] ?? '';
            _photoUrlController.text = draft['photoUrl'] ?? '';

            if (draft['month'] != null) _selectedMonth = draft['month'];
            if (draft['compliance'] != null)
              _selectedComplianceStatus = draft['compliance'];
            if (draft['shift'] != null) _selectedShift = draft['shift'];
            if (draft['level1'] != null) _selectedLevel1 = draft['level1'];
            if (draft['subCategory'] != null)
              _selectedSubCategory = draft['subCategory'];
            if (draft['checkpoint'] != null)
              _selectedCheckpoint = draft['checkpoint'];
            if (draft['language'] != null)
              _selectedLanguage = draft['language'];
            if (draft['country'] != null) _selectedCountry = draft['country'];
            if (draft['zone'] != null) _selectedZone = draft['zone'];
            if (draft['confidence'] != null)
              _confidenceLevel = draft['confidence'];
          });
        } else {
          await _storageService.remove('manual_audit_draft');
        }
      }
    } catch (e) {
      print('Error loading draft: $e');
    }
  }

  /// Save draft to storage
  Future<void> _saveDraft() async {
    final draft = {
      'dealerId': _dealerIdController.text,
      'dealerName': _dealerNameController.text,
      'feedback': _feedbackController.text,
      'dealerDetails': _dealerDetailsController.text,
      'photoUrl': _photoUrlController.text,
      'month': _selectedMonth,
      'compliance': _selectedComplianceStatus,
      'shift': _selectedShift,
      'level1': _selectedLevel1,
      'subCategory': _selectedSubCategory,
      'checkpoint': _selectedCheckpoint,
      'language': _selectedLanguage,
      'country': _selectedCountry,
      'zone': _selectedZone,
      'confidence': _confidenceLevel,
      'savedAt': DateTime.now().toIso8601String(),
    };

    await _storageService.saveJson('manual_audit_draft', draft);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved locally'),
        backgroundColor: Colors.grey,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    _dealerIdController.dispose();
    _dealerNameController.dispose();
    _feedbackController.dispose();
    _dealerDetailsController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Manual Audit Entry',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            Text(
              'COMPREHENSIVE AUDIT FORM',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodySmall?.color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save Draft',
            onPressed: _saveDraft,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              _buildHeaderCard(),
              const SizedBox(height: 24),

              // Dealer Information Section
              _buildSectionTitle('DEALER INFORMATION'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _dealerIdController,
                label: 'Dealer ID',
                hint: 'Enter dealer ID',
                icon: Icons.badge,
                required: true,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _dealerNameController,
                label: 'Dealer Name',
                hint: 'Enter dealer name',
                icon: Icons.business,
                required: true,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _dealerDetailsController,
                label: 'Dealer Details',
                hint: 'Additional dealer information',
                icon: Icons.info_outline,
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Date & Time Section
              _buildSectionTitle('DATE & TIME DETAILS'),
              const SizedBox(height: 12),
              _buildDatePicker(),
              const SizedBox(height: 12),
              _buildTimePicker(),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Month',
                value: _selectedMonth,
                items: _months,
                onChanged: (val) => setState(() => _selectedMonth = val!),
                icon: Icons.calendar_month,
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Shift',
                value: _selectedShift,
                items: _shifts,
                onChanged: (val) => setState(() => _selectedShift = val!),
                icon: Icons.access_time,
              ),
              const SizedBox(height: 24),

              // Audit Details Section
              _buildSectionTitle('AUDIT DETAILS'),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Compliance Status',
                value: _selectedComplianceStatus,
                items: _complianceStatuses,
                onChanged: (val) =>
                    setState(() => _selectedComplianceStatus = val!),
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Level 1 Category',
                value: _selectedLevel1,
                items: _levels,
                onChanged: (val) => setState(() => _selectedLevel1 = val!),
                icon: Icons.layers,
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Sub Category',
                value: _selectedSubCategory,
                items: _subCategories,
                onChanged: (val) => setState(() => _selectedSubCategory = val!),
                icon: Icons.category,
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Checkpoint',
                value: _selectedCheckpoint,
                items: _checkpoints,
                onChanged: (val) => setState(() => _selectedCheckpoint = val!),
                icon: Icons.checklist_rtl,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _photoUrlController,
                label: 'Photo URL (Optional)',
                hint: 'Enter photo URL if available',
                icon: Icons.photo_camera,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 24),

              // Confidence & Feedback Section
              _buildSectionTitle('CONFIDENCE & FEEDBACK'),
              const SizedBox(height: 12),
              _buildConfidenceSlider(),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _feedbackController,
                label: 'Feedback / Notes',
                hint: 'Enter detailed feedback or observations',
                icon: Icons.comment,
                maxLines: 4,
                required: true,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _dealerDetailsController,
                label: 'Dealer Consolidated Summary',
                hint: 'Overall summary of the audit',
                icon: Icons.summarize,
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Location Section
              _buildSectionTitle('LOCATION DETAILS'),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Country',
                value: _selectedCountry,
                items: _countries,
                onChanged: (val) => setState(() => _selectedCountry = val!),
                icon: Icons.flag,
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Zone',
                value: _selectedZone,
                items: _zones,
                onChanged: (val) => setState(() => _selectedZone = val!),
                icon: Icons.location_on,
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Language',
                value: _selectedLanguage,
                items: _languages,
                onChanged: (val) => setState(() => _selectedLanguage = val!),
                icon: Icons.language,
              ),
              const SizedBox(height: 24),

              // Credentials Section
              _buildSectionTitle('CREDENTIALS (LOCAL ONLY)'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter email address',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                required: true,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter password',
                icon: Icons.lock,
                obscureText: true,
                required: true,
              ),
              const SizedBox(height: 32),

              // Submit Button
              _buildSubmitButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // UI BUILDER METHODS
  // ========================================================================

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            StellantisColors.stellantisBlue,
            StellantisColors.stellantisBlue.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: StellantisColors.stellantisBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.assignment, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manual Audit Submission',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Complete all fields to submit audit',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).textTheme.bodySmall?.color,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    bool obscureText = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          hintText: hint,
          labelStyle: Theme.of(context).textTheme.bodySmall,
          hintStyle: Theme.of(context).textTheme.bodySmall,
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: value,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: Theme.of(context).textTheme.bodySmall,
                border: InputBorder.none,
              ),
              items: items.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: Theme.of(
                context,
              ).copyWith(colorScheme: Theme.of(context).colorScheme),
              child: child!,
            );
          },
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Audit Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_selectedTime),
          builder: (context, child) {
            return Theme(
              data: Theme.of(
                context,
              ).copyWith(colorScheme: Theme.of(context).colorScheme),
              child: child!,
            );
          },
        );
        if (time != null) {
          setState(() {
            _selectedTime = DateTime(
              _selectedTime.year,
              _selectedTime.month,
              _selectedTime.day,
              time.hour,
              time.minute,
            );
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Audit Time',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('hh:mm a').format(_selectedTime),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceSlider() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confidence Level',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: StellantisColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_confidenceLevel.toInt()}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: StellantisColors.success,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _confidenceLevel,
            min: 0,
            max: 100,
            divisions: 100,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) {
              setState(() => _confidenceLevel = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitAudit,
        style: ElevatedButton.styleFrom(
          backgroundColor: StellantisColors.stellantisBlue,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: StellantisColors.textLight,
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Submit Manual Audit',
                    style: TextStyle(
                      color: StellantisColors.textOnPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.cloud_upload,
                    color: StellantisColors.textOnPrimary,
                    size: 20,
                  ),
                ],
              ),
      ),
    );
  }

  // ========================================================================
  // BUSINESS LOGIC METHODS
  // ========================================================================

  Future<void> _submitAudit() async {
    // Save draft before validating just in case, or clear it?
    // Usually submit clears draft.
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Create audit model
      final audit = ManualAuditModel(
        dealerId: _dealerIdController.text.trim(),
        dealerName: _dealerNameController.text.trim(),
        date: _selectedDate,
        month: _selectedMonth,
        complianceStatus: _selectedComplianceStatus,
        shift: _selectedShift,
        dealerConsolidatedSummary: _dealerDetailsController.text.trim(),
        level1: _selectedLevel1,
        subCategory: _selectedSubCategory,
        checkpoint: _selectedCheckpoint,
        photoUrl: _photoUrlController.text.trim().isEmpty
            ? null
            : _photoUrlController.text.trim(),
        confidenceLevel: _confidenceLevel,
        feedback: _feedbackController.text.trim(),
        language: _selectedLanguage,
        country: _selectedCountry,
        dealerDetails: _dealerDetailsController.text.trim(),
        zone: _selectedZone,
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        time: _selectedTime,
      );

      // Save local history record first (offline capable)
      await _storageService.addAuditToHistory({
        'type': 'Manual',
        'checkpoint': _selectedCheckpoint,
        'date': DateTime.now().toIso8601String(),
        'status': _selectedComplianceStatus,
        'score': _confidenceLevel.toInt(),
        'details': _feedbackController.text.trim(),
      });

      // Clear draft on success (or we can keep it until successful submission?)
      // Let's keep draft clearing here, assuming local save is "safe" enough for now.
      await _storageService.remove('manual_audit_draft');

      // Submit to backend
      final response = await _manualAuditService.submitManualAudit(audit);

      if (!mounted) return;

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: StellantisColors.success,
                size: 32,
              ),
              const SizedBox(width: 12),
              const Text('Audit Submitted'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your manual audit has been successfully submitted.'),
              const SizedBox(height: 12),
              if (response['id'] != null)
                Text(
                  'Audit ID: ${response['id']}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: StellantisColors.stellantisBlue,
                  ),
                ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to previous screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: StellantisColors.stellantisBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.error, color: StellantisColors.red, size: 32),
              const SizedBox(width: 12),
              const Text('Submission Failed'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Failed to submit audit. Please check:'),
              const SizedBox(height: 8),
              const Text('• Backend server is running'),
              const Text('• Network connection is active'),
              const Text('• All fields are correctly filled'),
              const SizedBox(height: 12),
              Text(
                'Error: ${e.toString()}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}

/*
 * ========================================================================
 * End of manual_audit_page.dart
 * Author: Rahul Raja
 * Website: https://www.stellantis.com/
 * ========================================================================
 */
