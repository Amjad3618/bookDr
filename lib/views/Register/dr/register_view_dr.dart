import 'package:bookdr/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class RegisterViewDr extends StatefulWidget {
  const RegisterViewDr({super.key});

  @override
  State<RegisterViewDr> createState() => _RegisterViewDrState();
}

class _RegisterViewDrState extends State<RegisterViewDr> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _licenseController;
  late TextEditingController _specialityController;
  late TextEditingController _hospitalController;
  late TextEditingController _yearsExperienceController;
  late TextEditingController _qualificationController;
  late TextEditingController _aboutController;
  late TextEditingController _feeController;

  // Form state
  bool _acceptTerms = false;
  String? _selectedGender;
  String? _selectedDegree;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _licenseController = TextEditingController();
    _specialityController = TextEditingController();
    _hospitalController = TextEditingController();
    _yearsExperienceController = TextEditingController();
    _qualificationController = TextEditingController();
    _aboutController = TextEditingController();
    _feeController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _specialityController.dispose();
    _hospitalController.dispose();
    _yearsExperienceController.dispose();
    _qualificationController.dispose();
    _aboutController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          centerTitle: true,
          title: const Text(
            'Doctor Registration',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Personal Information'),
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  hint: 'Dr. John Doe',
                  icon: Icons.person,
                  validator: (value) => value?.isEmpty ?? true ? 'Name required' : null,
                ),
                const SizedBox(height: 16),
                _buildGenderDropdown(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'doctor@example.com',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Email required';
                    if (!value!.contains('@')) return 'Valid email required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '+92 300 1234567',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) => value?.isEmpty ?? true ? 'Phone required' : null,
                ),
                const SizedBox(height: 32),
                _buildSectionTitle('Professional Information'),
                _buildTextField(
                  controller: _licenseController,
                  label: 'Medical License Number',
                  hint: 'e.g., PMC-12345',
                  icon: Icons.verified_user,
                  validator: (value) => value?.isEmpty ?? true ? 'License required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _specialityController,
                  label: 'Speciality',
                  hint: 'e.g., Cardiologist, Dentist',
                  icon: Icons.local_hospital,
                  validator: (value) => value?.isEmpty ?? true ? 'Speciality required' : null,
                ),
                const SizedBox(height: 16),
                _buildDegreeDropdown(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _yearsExperienceController,
                  label: 'Years of Experience',
                  hint: '10',
                  icon: Icons.work,
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true ? 'Experience required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _qualificationController,
                  label: 'Qualifications',
                  hint: 'e.g., MBBS, MD, FCPS',
                  icon: Icons.school,
                  validator: (value) => value?.isEmpty ?? true ? 'Qualifications required' : null,
                ),
                const SizedBox(height: 32),
                _buildSectionTitle('Practice Information'),
                _buildTextField(
                  controller: _hospitalController,
                  label: 'Hospital / Clinic Name',
                  hint: 'Your Practice Name',
                  icon: Icons.business,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _feeController,
                  label: 'Consultation Fee (PKR)',
                  hint: '2500',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true ? 'Fee required' : null,
                ),
                const SizedBox(height: 32),
                _buildSectionTitle('About You'),
                _buildTextArea(
                  controller: _aboutController,
                  label: 'Professional Bio',
                  hint: 'Tell patients about your experience and expertise...',
                  maxLines: 4,
                ),
                const SizedBox(height: 32),
                _buildTermsCheckbox(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 3,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: const Icon(Icons.wc, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      items: const [
        DropdownMenuItem(value: 'male', child: Text('Male')),
        DropdownMenuItem(value: 'female', child: Text('Female')),
      ],
      onChanged: (value) => setState(() => _selectedGender = value),
      validator: (value) => value == null ? 'Gender required' : null,
    );
  }

  Widget _buildDegreeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDegree,
      decoration: InputDecoration(
        labelText: 'Highest Degree',
        prefixIcon: const Icon(Icons.school, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      items: const [
        DropdownMenuItem(value: 'mbbs', child: Text('MBBS')),
        DropdownMenuItem(value: 'md', child: Text('MD')),
        DropdownMenuItem(value: 'ms', child: Text('MS')),
        DropdownMenuItem(value: 'fcps', child: Text('FCPS')),
        DropdownMenuItem(value: 'bds', child: Text('BDS')),
        DropdownMenuItem(value: 'dds', child: Text('DDS')),
      ],
      onChanged: (value) => setState(() => _selectedDegree = value),
      validator: (value) => value == null ? 'Degree required' : null,
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) => setState(() => _acceptTerms = value ?? false),
          activeColor: AppColors.primary,
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: 'I agree to the ',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              children: [
                TextSpan(
                  text: 'Terms & Conditions',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _acceptTerms ? () => _submitForm() : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          disabledBackgroundColor: AppColors.disabled,
        ),
        child: const Text(
          'Complete Registration',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Handle form submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration submitted successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}