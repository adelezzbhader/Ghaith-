import 'package:flutter/material.dart';
import 'package:mongez/core/theme/app_theme.dart';

class DisclaimerModal extends StatelessWidget {
  final VoidCallback onAgree;

  const DisclaimerModal({super.key, required this.onAgree});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DisclaimerModal(
        onAgree: () => Navigator.of(context).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'إخلاء مسؤولية طبية',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _section(
                    context,
                    'مقدمة',
                    'منصة غيث هي منصة وسيطة تهدف إلى ربط المرضى بالممرضين المؤهلين. '
                        'نحن لسنا مقدمي رعاية صحية ولا نقدم أي خدمات طبية بشكل مباشر.',
                  ),
                  _section(
                    context,
                    'دور المنصة',
                    'دور منصة غيث يقتصر على التوصيل بين المريض والممرض، وتوفير بيئة آمنة '
                        'وموثوقة للتواصل. نحن لا نتحمل مسؤولية التشخيص أو العلاج أو أي إجراء طبي.',
                  ),
                  _section(
                    context,
                    'مسؤولية الممرض',
                    'الممرض هو المسؤول الوحيد عن الخدمات الطبية التي يقدمها، وعليه '
                        'الالتزام بمعايير الرعاية الصحية والمهنية. المنصة لا تتحمل أي مسؤولية '
                        'عن أي أخطاء طبية قد تحدث.',
                  ),
                  _section(
                    context,
                    'مسؤولية المريض',
                    'المريض مسؤول عن تقديم معلومات دقيقة عن حالته الصحية، وعليه متابعة '
                        'تعليمات الممرض بدقة. المنصة لا تتحمل مسؤولية أي مضاعفات ناتجة عن '
                        'عدم اتباع التعليمات.',
                  ),
                  _section(
                    context,
                    'الخصوصية',
                    'نحن ملتزمون بحماية خصوصية بياناتك. جميع المعلومات الطبية والشخصية '
                        'تخضع لسياسة الخصوصية الخاصة بالمنصة.',
                  ),
                  _section(
                    context,
                    'الموافقة',
                    'باستخدامك للمنصة، فإنك توافق على جميع الشروط والأحكام المذكورة أعلاه، '
                        'وتقر بأنك فهمت دور المنصة ومسؤوليات الأطراف المختلفة.',
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onAgree,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'أوافق على جميع التعليمات والشروط',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
