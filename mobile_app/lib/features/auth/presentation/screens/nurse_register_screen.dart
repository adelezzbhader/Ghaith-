import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mongez/core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class NurseRegisterScreen extends StatefulWidget {
  const NurseRegisterScreen({super.key});

  @override
  State<NurseRegisterScreen> createState() => _NurseRegisterScreenState();
}

class _NurseRegisterScreenState extends State<NurseRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _walletController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _interviewDateController = TextEditingController();
  String _selectedGender = 'ذكر';
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  Map<String, List<String>> _fieldErrors = {};

  XFile? _photo;
  XFile? _certificate;
  XFile? _syndicateCard;

  final List<String> _genders = ['ذكر', 'أنثى'];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _walletController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _interviewDateController.dispose();
    super.dispose();
  }

  String? _fieldError(String field) {
    final errors = _fieldErrors[field];
    if (errors != null && errors.isNotEmpty) return errors.first;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          _showSuccessScreen(state.message);
        } else if (state is AuthError) {
          setState(() => _fieldErrors = state.fieldErrors);
          if (state.fieldErrors.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تسجيل ممرض'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: _fieldErrors.isNotEmpty
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'التسجيل كممرض',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'أدخل بياناتك للانضمام كمرمرض في فريق غيث',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _nameController,
                  label: 'الاسم الكامل',
                  hint: 'أدخل اسمك الكامل',
                  icon: Icons.person_outline,
                  errorText: _fieldError('full_name'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'من فضلك أدخل اسمك' : _fieldError('full_name'),
                  onChanged: (_) {
                    if (_fieldErrors.containsKey('full_name')) {
                      setState(() => _fieldErrors.remove('full_name'));
                      _formKey.currentState?.validate();
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'رقم الهاتف',
                  hint: '05xxxxxxxx',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  errorText: _fieldError('phone'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'من فضلك أدخل رقم هاتفك';
                    if (v.length < 10) return 'رقم الهاتف غير صالح';
                    return _fieldError('phone');
                  },
                  onChanged: (_) {
                    if (_fieldErrors.containsKey('phone')) {
                      setState(() => _fieldErrors.remove('phone'));
                      _formKey.currentState?.validate();
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'البريد الإلكتروني',
                  hint: 'example@email.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _fieldError('email'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'من فضلك أدخل بريدك الإلكتروني';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                      return 'البريد الإلكتروني غير صالح';
                    }
                    return _fieldError('email');
                  },
                  onChanged: (_) {
                    if (_fieldErrors.containsKey('email')) {
                      setState(() => _fieldErrors.remove('email'));
                      _formKey.currentState?.validate();
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  label: 'العنوان',
                  hint: 'أدخل عنوانك',
                  icon: Icons.location_on_outlined,
                  errorText: _fieldError('address'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'من فضلك أدخل عنوانك' : _fieldError('address'),
                  onChanged: (_) {
                    if (_fieldErrors.containsKey('address')) {
                      setState(() => _fieldErrors.remove('address'));
                      _formKey.currentState?.validate();
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _walletController,
                  label: 'المحفظة (اختياري)',
                  hint: 'رقم المحفظة الإلكترونية',
                  icon: Icons.account_balance_wallet_outlined,
                  errorText: _fieldError('wallet_number'),
                  onChanged: (_) {
                    if (_fieldErrors.containsKey('wallet_number')) {
                      setState(() => _fieldErrors.remove('wallet_number'));
                      _formKey.currentState?.validate();
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildGenderDropdown(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  label: 'كلمة المرور',
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  errorText: _fieldError('password'),
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppTheme.textHint,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'من فضلك أدخل كلمة المرور';
                    if (v.length < 6) return 'كلمة المرور قصيرة جدًا';
                    return _fieldError('password');
                  },
                  onChanged: (_) {
                    if (_fieldErrors.containsKey('password')) {
                      setState(() => _fieldErrors.remove('password'));
                      _formKey.currentState?.validate();
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'تأكيد كلمة المرور',
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscureText: _obscureConfirm,
                  errorText: _fieldError('confirm_password'),
                  suffix: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppTheme.textHint,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'من فضلك تأكيد كلمة المرور';
                    if (v != _passwordController.text) return 'كلمة المرور غير متطابقة';
                    return _fieldError('confirm_password');
                  },
                  onChanged: (_) {
                    if (_fieldErrors.containsKey('confirm_password')) {
                      setState(() => _fieldErrors.remove('confirm_password'));
                      _formKey.currentState?.validate();
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _interviewDateController,
                  label: 'تاريخ المقابلة',
                  hint: 'اختر تاريخ المقابلة',
                  icon: Icons.calendar_today_outlined,
                  readOnly: true,
                  errorText: _fieldError('interview_date'),
                  onTap: _pickInterviewDate,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'من فضلك اختر تاريخ المقابلة' : _fieldError('interview_date'),
                  onChanged: (_) {
                    if (_fieldErrors.containsKey('interview_date')) {
                      setState(() => _fieldErrors.remove('interview_date'));
                      _formKey.currentState?.validate();
                    }
                  },
                ),
                const SizedBox(height: 24),
                _buildFileUpload(
                  label: 'الصورة الشخصية',
                  file: _photo,
                  icon: Icons.camera_alt_outlined,
                  errorText: _fieldError('profile_image'),
                  onPick: () => _pickFile('photo'),
                  onClear: () => setState(() => _photo = null),
                ),
                const SizedBox(height: 12),
                _buildFileUpload(
                  label: 'الشهادة الدراسية',
                  file: _certificate,
                  icon: Icons.school_outlined,
                  errorText: _fieldError('graduation_certificate'),
                  onPick: () => _pickFile('certificate'),
                  onClear: () => setState(() => _certificate = null),
                ),
                const SizedBox(height: 12),
                _buildFileUpload(
                  label: 'كارنيه النقابة',
                  file: _syndicateCard,
                  icon: Icons.badge_outlined,
                  errorText: _fieldError('syndicate_card'),
                  onPick: () => _pickFile('syndicateCard'),
                  onClear: () => setState(() => _syndicateCard = null),
                ),
                const SizedBox(height: 24),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            isLoading ? null : () => _submitForm(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppTheme.primary.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'إرسال طلب التسجيل',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لديك حساب بالفعل؟',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    bool readOnly = false,
    Widget? suffix,
    String? errorText,
    TextInputType? keyboardType,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.textHint),
        suffixIcon: suffix,
        errorText: errorText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.error, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'الجنس',
        prefixIcon:
            const Icon(Icons.people_outline, color: AppTheme.textHint),
        errorText: _fieldError('gender'),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.error, width: 1.5),
        ),
      ),
      items: _genders.map((g) {
        return DropdownMenuItem(value: g, child: Text(g));
      }).toList(),
      onChanged: (v) {
        setState(() {
          _selectedGender = v ?? 'ذكر';
          _fieldErrors.remove('gender');
        });
        _formKey.currentState?.validate();
      },
    );
  }

  Widget _buildFileUpload({
    required String label,
    required XFile? file,
    required IconData icon,
    String? errorText,
    required VoidCallback onPick,
    required VoidCallback onClear,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError ? AppTheme.error : AppTheme.border,
              width: hasError ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Text(
                      file != null
                          ? file.name
                          : 'لم يتم اختيار ملف',
                      style: TextStyle(
                        fontSize: 12,
                        color: file != null ? AppTheme.textPrimary : AppTheme.textHint,
                        fontFamily: 'Cairo',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (file != null)
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.error, size: 20),
                  onPressed: onClear,
                ),
              TextButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text('اختيار'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  textStyle: const TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 12),
            child: Text(
              errorText,
              style: const TextStyle(
                color: AppTheme.error,
                fontSize: 12,
                fontFamily: 'Cairo',
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickFile(String type) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        if (type == 'photo') _photo = image;
        if (type == 'certificate') _certificate = image;
        if (type == 'syndicateCard') _syndicateCard = image;
      });
    }
  }

  Future<void> _pickInterviewDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      _interviewDateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (_photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('من فضلك اختر الصورة الشخصية'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final genderMap = {'ذكر': 'MALE', 'أنثى': 'FEMALE'};
    context.read<AuthBloc>().add(
          RegisterNurseEvent(
            data: {
              'fullName': _nameController.text.trim(),
              'phone': _phoneController.text.trim(),
              'email': _emailController.text.trim(),
              'address': _addressController.text.trim(),
              'wallet': _walletController.text.trim(),
              'gender': genderMap[_selectedGender] ?? 'male',
              'password': _passwordController.text,
              'confirmPassword': _confirmPasswordController.text,
              'interviewDate': _interviewDateController.text,
              'role': 'nurse',
            },
            photo: _photo,
            certificate: _certificate,
            syndicateCard: _syndicateCard,
          ),
        );
  }

  void _showSuccessScreen(String message) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10b981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'تم إرسال طلبك بنجاح!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontFamily: 'Cairo',
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }
}
