class Validators {
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
    if (!RegExp(r'^[A-Za-z\u0600-\u06FF\s]{3,}$').hasMatch(value)) {
      return 'الاسم يجب أن يحتوي على حروف فقط';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
    if (!RegExp(r'^(010|011|012|015)\d{8}$').hasMatch(value)) {
      return 'رقم مصري صالح (11 رقم)';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
      return 'بريد إلكتروني غير صالح';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
    if (value.length < 8 ||
        !RegExp(r'[A-Za-z]{2,}').hasMatch(value) ||
        !RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
      return 'كلمة المرور 8 أحرف على الأقل وتحتوي على حرفين ورمز';
    }
    return null;
  }

  static String? validateConfirmPassword(String? password, String? confirm) {
    if (confirm == null || confirm.isEmpty) return 'هذا الحقل مطلوب';
    if (password != confirm) return 'كلمة المرور غير متطابقة';
    return null;
  }

  static String? validateRequired(String? value) {
    if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
    return null;
  }
}
