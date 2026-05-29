import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mongez/core/theme/app_theme.dart';
import 'package:mongez/features/home/domain/entities/area_entity.dart';
import 'package:mongez/features/home/domain/entities/service_entity.dart';
import 'package:mongez/features/home/presentation/bloc/home_bloc.dart';
import 'package:mongez/features/patient/domain/entities/order_entity.dart';
import 'package:mongez/features/patient/domain/repositories/patient_repository.dart';
import 'package:mongez/features/patient/presentation/bloc/patient_bloc.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    context.read<PatientBloc>().add(const LoadPatientDashboard());
    context.read<HomeBloc>().add(const HomePageLoaded());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PatientBloc, PatientState>(
      listener: (context, state) {
        if (state is OrderCreated) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle, size: 48, color: Color(0xFF10B981)),
                  ),
                  const SizedBox(height: 16),
                  const Text('تم إرسال طلبك بنجاح!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                  const SizedBox(height: 8),
                  Text('سيتم التواصل معك قريباً', style: TextStyle(fontSize: 14, color: Colors.grey[600], fontFamily: 'Cairo')),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<PatientBloc>().add(const LoadPatientDashboard());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0d9488),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('تم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo')),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is OrderActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          context.read<PatientBloc>().add(const LoadPatientDashboard());
        }
      },
      child: Scaffold(
        body: BlocBuilder<PatientBloc, PatientState>(
          builder: (context, state) {
            if (state is PatientLoading && state is! PatientDashboardLoaded) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is PatientError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(state.message, style: const TextStyle(fontSize: 16, color: Colors.red, fontFamily: 'Cairo')),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.read<PatientBloc>().add(const LoadPatientDashboard()),
                        child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo')),
                      ),
                    ],
                  ),
                ),
              );
            }
            return IndexedStack(
              index: _currentTab,
              children: [
                _buildHomeTab(context, state),
                _buildOrdersTab(context, state),
                _buildProfileTab(context, state),
              ],
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: (i) => setState(() => _currentTab = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'طلباتي'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الملف الشخصي'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context, PatientState state) {
    PatientProfile? profile;
    if (state is PatientDashboardLoaded) {
      profile = state.profile;
    }
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppTheme.headerGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile?.name ?? '',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile?.phone ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8), fontFamily: 'Cairo'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildProfileField('الاسم', profile?.name ?? ''),
            _buildProfileField('رقم الهاتف', profile?.phone ?? ''),
            _buildProfileField('البريد الإلكتروني', profile?.email ?? ''),
            _buildProfileField('الجنس', profile?.gender ?? 'غير محدد'),
            const SizedBox(height: 16),
            const Text('العنوان', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1F2937), fontFamily: 'Cairo')),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: profile?.address ?? ''),
              decoration: InputDecoration(
                hintText: 'أدخل عنوانك',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0d9488),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('حفظ التغييرات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontFamily: 'Cairo')),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab(BuildContext context, PatientState state) {
    final orders = (state is PatientDashboardLoaded) ? state.orders : <OrderEntity>[];
    return SafeArea(
      child: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('لا توجد طلبات بعد', style: TextStyle(fontSize: 18, color: Colors.grey[500], fontFamily: 'Cairo')),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (_, index) => _buildOrderCard(context, orders[index]),
            ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderEntity order) {
    final statusColors = {
      'pending': const Color(0xFFF59E0B),
      'accepted': const Color(0xFF06b6d4),
      'in_progress': const Color(0xFF3B82F6),
      'completed': const Color(0xFF10B981),
      'cancelled': const Color(0xFFEF4444),
    };
    final statusLabels = {
      'pending': 'قيد الانتظار',
      'accepted': 'تم القبول',
      'in_progress': 'قيد التنفيذ',
      'completed': 'مكتمل',
      'cancelled': 'ملغي',
    };
    final color = statusColors[order.status] ?? Colors.grey;
    final label = statusLabels[order.status] ?? order.status;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('طلب #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo')),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (order.services.isNotEmpty) ...[
            Text(order.services.join('، '), style: TextStyle(fontSize: 13, color: Colors.grey[600], fontFamily: 'Cairo')),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(order.area, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontFamily: 'Cairo')),
              const Spacer(),
              Text('${order.totalPrice.toStringAsFixed(0)} ر.س', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0d9488), fontSize: 14, fontFamily: 'Cairo')),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            order.date.toString().substring(0, 16),
            style: TextStyle(fontSize: 11, color: Colors.grey[400], fontFamily: 'Cairo'),
          ),
          if (order.status == 'accepted' || order.status == 'in_progress') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => context.read<PatientBloc>().add(CompleteOrder(id: order.id)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('تأكيد الاكتمال', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () => _showCancelConfirmDialog(context, order.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('إلغاء', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (order.status == 'completed' && order.rating == null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () => _showRatingDialog(context, order.id),
                icon: const Icon(Icons.star, size: 18),
                label: const Text('تقييم الخدمة', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showOrderDetailSheet(context, order),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('عرض التفاصيل', style: TextStyle(fontSize: 12, color: AppTheme.primary, fontFamily: 'Cairo')),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, size: 18, color: AppTheme.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تأكيد الإلغاء', style: TextStyle(fontFamily: 'Cairo')),
        content: const Text('هل أنت متأكد من إلغاء هذا الطلب؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('تراجع', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<PatientBloc>().add(CancelOrder(id: orderId));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('تأكيد الإلغاء', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, String orderId) {
    int selectedScore = 5;
    final commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const Text('تقييم الخدمة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedScore = star),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        star <= selectedScore ? Icons.star : Icons.star_border,
                        color: const Color(0xFFF59E0B),
                        size: 40,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'أضف تعليقك (اختياري)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<PatientBloc>().add(RateOrder(id: orderId, score: selectedScore, comment: commentController.text.isEmpty ? null : commentController.text));
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0d9488),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('إرسال التقييم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetailSheet(BuildContext context, OrderEntity order) {
    final statusLabels = {
      'pending': 'قيد الانتظار',
      'accepted': 'تم القبول',
      'in_progress': 'قيد التنفيذ',
      'completed': 'مكتمل',
      'cancelled': 'ملغي',
    };
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Center(
              child: Text('تفاصيل الطلب #${order.orderNumber}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
            ),
            const SizedBox(height: 24),
            _detailRow('رقم الطلب', order.orderNumber),
            _detailRow('الحالة', statusLabels[order.status] ?? order.status),
            _detailRow('اسم المريض', order.patientName),
            _detailRow('رقم الهاتف', order.patientPhone),
            _detailRow('العنوان', order.patientAddress),
            _detailRow('المنطقة', order.area),
            _detailRow('الخدمات', order.services.join('، ')),
            if (order.nurseName != null) _detailRow('الممرض', order.nurseName!),
            _detailRow('الإجمالي', '${order.totalPrice.toStringAsFixed(0)} ر.س'),
            _detailRow('التاريخ', order.date.toString().substring(0, 16)),
            if (order.rating != null) _detailRow('التقييم', '${'★' * order.rating!}${'☆' * (5 - order.rating!)}'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[500], fontFamily: 'Cairo'))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Cairo'))),
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context, PatientState patientState) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, homeState) {
        final services = (homeState is HomeLoaded) ? homeState.services : <ServiceEntity>[];
        final areas = (homeState is HomeLoaded) ? homeState.areas : <AreaEntity>[];
        return _OrderWizard(services: services, areas: areas);
      },
    );
  }
}

class _OrderWizard extends StatefulWidget {
  final List<ServiceEntity> services;
  final List<AreaEntity> areas;
  const _OrderWizard({required this.services, required this.areas});

  @override
  State<_OrderWizard> createState() => _OrderWizardState();
}

class _OrderWizardState extends State<_OrderWizard> {
  int _step = 1;
  final Set<String> _selectedServiceIds = {};
  String? _selectedAreaId;
  String _address = '';
  int? _fullCareHours;
  String? _fullCareGender;
  final _addressController = TextEditingController();
  double _totalPrice = 0;

  void _calculateTotal() {
    double total = 0;
    for (final svc in widget.services) {
      if (_selectedServiceIds.contains(svc.id)) {
        if (svc.perHour && _fullCareHours != null) {
          total += svc.price * _fullCareHours!;
        } else {
          total += svc.price;
        }
      }
    }
    setState(() => _totalPrice = total);
  }

  @override
  void initState() {
    super.initState();
    _addressController.addListener(() => _address = _addressController.text);
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppTheme.headerGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('مرحباً بك في غيث', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo')),
                  const SizedBox(height: 4),
                  Text('اطلب خدمات تمريضية منزلية', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8), fontFamily: 'Cairo')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildStepIndicator(),
            const SizedBox(height: 20),
            if (_step == 1) _buildStep1(),
            if (_step == 2) _buildStep2(),
            if (_step == 3) _buildStep3(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [1, 2, 3].map((s) {
        final isActive = s <= _step;
        final isCurrent = s == _step;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? const Color(0xFF0d9488) : Colors.grey[200],
                        border: isCurrent ? Border.all(color: const Color(0xFF0d9488), width: 3) : null,
                      ),
                      child: Center(
                        child: Text('$s', style: TextStyle(
                          color: isActive ? Colors.white : Colors.grey[500],
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        )),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s == 1 ? 'الخدمات' : s == 2 ? 'الموقع' : 'التأكيد',
                      style: TextStyle(
                        fontSize: 11,
                        color: isCurrent ? const Color(0xFF0d9488) : Colors.grey[500],
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
              if (s < 3)
                Expanded(
                  child: Container(
                    height: 2,
                    color: s < _step ? const Color(0xFF0d9488) : Colors.grey[300],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStep1() {
    if (widget.services.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('لا توجد خدمات متاحة حالياً', style: TextStyle(fontSize: 16, color: Colors.grey[500], fontFamily: 'Cairo')),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('اختر الخدمات المطلوبة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        const SizedBox(height: 4),
        Text('يمكنك اختيار خدمة أو أكثر', style: TextStyle(fontSize: 13, color: Colors.grey[500], fontFamily: 'Cairo')),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: widget.services.length,
          itemBuilder: (_, index) {
            final svc = widget.services[index];
            final selected = _selectedServiceIds.contains(svc.id);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (selected) {
                    _selectedServiceIds.remove(svc.id);
                  } else {
                    _selectedServiceIds.add(svc.id);
                  }
                  _calculateTotal();
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFF0FDFA) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? const Color(0xFF0d9488) : Colors.grey[200]!,
                    width: selected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(svc.icon, style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text(svc.nameAr, textAlign: TextAlign.center, style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? const Color(0xFF0d9488) : const Color(0xFF1F2937),
                      fontFamily: 'Cairo',
                    )),
                    const SizedBox(height: 4),
                    Text('${svc.price.toStringAsFixed(0)} ر.س${svc.perHour ? '/ساعة' : ''}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0d9488), fontFamily: 'Cairo')),
                    if (selected)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0d9488),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('محدد', style: TextStyle(fontSize: 10, color: Colors.white, fontFamily: 'Cairo')),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        if (_selectedServiceIds.any((id) => widget.services.any((s) => s.id == id && s.perHour))) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('تفاصيل الرعاية الكاملة', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('عدد الساعات:', style: TextStyle(fontFamily: 'Cairo')),
                    const SizedBox(width: 12),
                    Container(
                      width: 100,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '8',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        style: const TextStyle(fontFamily: 'Cairo'),
                        onChanged: (v) {
                          setState(() => _fullCareHours = int.tryParse(v));
                          _calculateTotal();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('ساعة', style: TextStyle(fontFamily: 'Cairo')),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('الجنس المفضل:', style: TextStyle(fontFamily: 'Cairo')),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _genderChip('ذكر', 'male'),
                    const SizedBox(width: 8),
                    _genderChip('أنثى', 'female'),
                    const SizedBox(width: 8),
                    _genderChip('لا يهم', null),
                  ],
                ),
              ],
            ),
          ),
        ],
        if (_totalPrice > 0) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('المجموع التقريبي: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                Text('${_totalPrice.toStringAsFixed(0)} ر.س', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0d9488), fontFamily: 'Cairo')),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _selectedServiceIds.isEmpty ? null : () => setState(() => _step = 2),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0d9488),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: const Text('التالي: الموقع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo')),
          ),
        ),
      ],
    );
  }

  Widget _genderChip(String label, String? value) {
    final selected = _fullCareGender == value;
    return GestureDetector(
      onTap: () => setState(() => _fullCareGender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0d9488) : Colors.grey[100],
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(label, style: TextStyle(
          color: selected ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        )),
      ),
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('اختر المنطقة وأدخل العنوان', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        const SizedBox(height: 16),
        if (widget.areas.isNotEmpty) ...[
          const Text('المنطقة:', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: widget.areas.map((area) {
                final selected = _selectedAreaId == area.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAreaId = area.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: selected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: selected ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)] : null,
                    ),
                    child: Row(
                      children: [
                        Text(area.nameAr, style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600,
                          color: selected ? const Color(0xFF0d9488) : const Color(0xFF1F2937),
                          fontFamily: 'Cairo',
                        )),
                        const Spacer(),
                        Text('${area.price.toStringAsFixed(0)} ر.س', style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold,
                          color: selected ? const Color(0xFF0d9488) : Colors.grey[600],
                          fontFamily: 'Cairo',
                        )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        const SizedBox(height: 16),
        const Text('العنوان:', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
        const SizedBox(height: 8),
        TextField(
          controller: _addressController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'أدخل عنوانك بالتفصيل',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDFA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ملخص الطلب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo')),
              const SizedBox(height: 8),
              Text('الخدمات: ${widget.services.where((s) => _selectedServiceIds.contains(s.id)).map((s) => s.nameAr).join('، ')}',
                style: TextStyle(fontSize: 13, color: Colors.grey[700], fontFamily: 'Cairo')),
              if (_fullCareHours != null)
                Text('عدد الساعات: $_fullCareHours', style: TextStyle(fontSize: 13, color: Colors.grey[700], fontFamily: 'Cairo')),
              if (_fullCareGender != null)
                Text('الجنس المفضل: ${_fullCareGender == 'male' ? 'ذكر' : 'أنثى'}', style: TextStyle(fontSize: 13, color: Colors.grey[700], fontFamily: 'Cairo')),
              const SizedBox(height: 4),
              Text('الإجمالي التقريبي: ${_totalPrice.toStringAsFixed(0)} ر.س',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0d9488), fontFamily: 'Cairo')),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () => setState(() => _step = 1),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('السابق', style: TextStyle(fontFamily: 'Cairo')),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: (_selectedAreaId == null || _address.isEmpty) ? null : () => setState(() => _step = 3),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0d9488),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: const Text('التالي: التأكيد', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo')),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('تأكيد الطلب', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('تفاصيل الطلب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              const Divider(height: 24),
              _summaryRow('الخدمات', widget.services.where((s) => _selectedServiceIds.contains(s.id)).map((s) => s.nameAr).join('، ')),
              _summaryRow('المنطقة', widget.areas.where((a) => a.id == _selectedAreaId).firstOrNull?.nameAr ?? ''),
              _summaryRow('العنوان', _address),
              if (_fullCareHours != null) _summaryRow('عدد الساعات', '$_fullCareHours ساعة'),
              if (_fullCareGender != null) _summaryRow('الجنس المفضل', _fullCareGender == 'male' ? 'ذكر' : 'أنثى'),
              const Divider(height: 24),
              _summaryRow('الإجمالي التقريبي', '${_totalPrice.toStringAsFixed(0)} ر.س',
                valueStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0d9488), fontFamily: 'Cairo')),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber, color: Color(0xFFF59E0B), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'بعد تأكيد الطلب، يمكنك إلغاؤه قبل أن يقوم ممرض بقبوله. في حال قبول الممرض للطلب، يرجى التواصل مع الدعم الفني للإلغاء.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700], fontFamily: 'Cairo', height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () => setState(() => _step = 2),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('السابق', style: TextStyle(fontFamily: 'Cairo')),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _submitOrder(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0d9488),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('تأكيد وطلب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo')),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontFamily: 'Cairo'))),
          Expanded(
            child: Text(value, style: valueStyle ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  void _submitOrder() {
    context.read<PatientBloc>().add(CreateOrder(
      services: _selectedServiceIds.toList(),
      areaId: _selectedAreaId!,
      address: _address,
      fullCareHours: _fullCareHours,
      fullCareGender: _fullCareGender,
    ));
  }
}
