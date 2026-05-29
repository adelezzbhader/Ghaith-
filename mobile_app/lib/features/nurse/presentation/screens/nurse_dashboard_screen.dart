import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../data/models/nurse_order_model.dart';
import '../bloc/nurse_bloc.dart';

class NurseDashboardScreen extends StatefulWidget {
  const NurseDashboardScreen({super.key});

  @override
  State<NurseDashboardScreen> createState() => _NurseDashboardScreenState();
}

class _NurseDashboardScreenState extends State<NurseDashboardScreen> {
  int _currentTab = 0;

  static const List<_TabConfig> _tabs = [
    _TabConfig(icon: Icons.home_rounded, label: 'الرئيسية'),
    _TabConfig(icon: Icons.list_alt_rounded, label: 'الطلبات المتاحة'),
    _TabConfig(icon: Icons.assignment_rounded, label: 'طلباتي'),
    _TabConfig(icon: Icons.person_rounded, label: 'الملف الشخصي'),
    _TabConfig(icon: Icons.account_balance_wallet_rounded, label: 'الأرباح'),
    _TabConfig(icon: Icons.star_rounded, label: 'التقييمات'),
  ];

  @override
  void initState() {
    super.initState();
    context.read<NurseBloc>().add(const LoadNurseDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: BlocConsumer<NurseBloc, NurseState>(
        listener: (context, state) {
          if (state is NurseOrderActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
          if (state is NurseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NurseDashboardLoaded) {
            return _buildDashboard(state);
          }
          if (state is NurseLoading) {
            return const LoadingWidget(text: 'جارٍ تحميل البيانات...');
          }
          if (state is NurseError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<NurseBloc>().add(const LoadNurseDashboard()),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (index) {
              final tab = _tabs[index];
              final isSelected = _currentTab == index;
              return Expanded(
                child: InkWell(
                  onTap: () => setState(() => _currentTab = index),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.icon,
                          size: 22,
                          color: isSelected ? AppTheme.primary : AppTheme.textHint,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 9.sp,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppTheme.primary : AppTheme.textHint,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(NurseDashboardLoaded state) {
    switch (_currentTab) {
      case 0:
        return _buildHomeTab(state);
      case 1:
        return _buildActiveOrdersTab(state);
      case 2:
        return _buildMyOrdersTab(state);
      case 3:
        return _buildProfileTab(state);
      case 4:
        return _buildEarningsTab(state);
      case 5:
        return _buildRatingsTab(state);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHeader(String title) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16.h, left: 20.w, right: 20.w, bottom: 24.h),
      decoration: const BoxDecoration(
        gradient: AppTheme.headerGradient,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab(NurseDashboardLoaded state) {
    final profile = state.profile;
    final firstName = (profile['first_name'] as String?) ??
        (profile['firstName'] as String?) ??
        (profile['name'] as String?) ??
        'ممرض';
    final stats = state.stats;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16.h, left: 20.w, right: 20.w, bottom: 24.h),
            decoration: const BoxDecoration(
              gradient: AppTheme.headerGradient,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                      onPressed: () {},
                    ),
                    Text(
                      'غيث',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'مرحباً بعودتك, $firstName',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'نرحب بتواجدك معنا',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 16.h)),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.list_alt_rounded,
                    label: 'الطلبات النشطة',
                    value: '${stats['active_orders'] ?? stats['activeOrders'] ?? 0}',
                    gradient: const LinearGradient(colors: [Color(0xFF0d9488), Color(0xFF14b8a6)]),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle_rounded,
                    label: 'إجمالي الزيارات',
                    value: '${stats['total_visits'] ?? stats['totalVisits'] ?? stats['total_orders'] ?? 0}',
                    gradient: const LinearGradient(colors: [Color(0xFF06b6d4), Color(0xFF22d3ee)]),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 8.h)),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'الأرباح الشهرية',
                    value: '${stats['monthly_earnings'] ?? stats['monthlyEarnings'] ?? 0} ج.م',
                    gradient: const LinearGradient(colors: [Color(0xFF0f766e), Color(0xFF0d9488)]),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _StatCard(
                    icon: Icons.star_rounded,
                    label: 'متوسط التقييم',
                    value: '${stats['avg_rating'] ?? stats['avgRating'] ?? 0}',
                    gradient: const LinearGradient(colors: [Color(0xFFf59e0b), Color(0xFFf97316)]),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 16.h)),
        if (state.activeOrders.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'أحدث الطلبات المتاحة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 8.h)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final order = state.activeOrders[index];
                return _buildActiveOrderCard(order, state);
              },
              childCount: state.activeOrders.length > 3 ? 3 : state.activeOrders.length,
            ),
          ),
        ],
        SliverToBoxAdapter(child: SizedBox(height: 24.h)),
      ],
    );
  }

  Widget _buildActiveOrdersTab(NurseDashboardLoaded state) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader('الطلبات المتاحة')),
        if (state.activeOrders.isEmpty)
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: const EmptyStateWidget(
                icon: Icons.inbox_outlined,
                message: 'لا توجد طلبات متاحة حالياً',
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final order = state.activeOrders[index];
                return _buildActiveOrderCard(order, state);
              },
              childCount: state.activeOrders.length,
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: 24.h)),
      ],
    );
  }

  Widget _buildMyOrdersTab(NurseDashboardLoaded state) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader('طلباتي')),
        if (state.myOrders.isEmpty)
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: const EmptyStateWidget(
                icon: Icons.assignment_outlined,
                message: 'لا توجد طلبات',
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final order = state.myOrders[index];
                return _buildMyOrderCard(order, state);
              },
              childCount: state.myOrders.length,
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: 24.h)),
      ],
    );
  }

  Widget _buildProfileTab(NurseDashboardLoaded state) {
    final profile = state.profile;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader('الملف الشخصي')),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  child: Icon(Icons.person, size: 48, color: AppTheme.primary),
                ),
                SizedBox(height: 12.h),
                Text(
                  profile['name'] as String? ?? profile['full_name'] as String? ?? profile['username'] as String? ?? 'ممرض',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  profile['email'] as String? ?? '',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp, color: AppTheme.textSecondary),
                ),
                SizedBox(height: 24.h),
                _ProfileField(label: 'الاسم', value: profile['name'] as String? ?? profile['full_name'] as String? ?? ''),
                _ProfileField(label: 'رقم الهاتف', value: profile['phone'] as String? ?? ''),
                _ProfileField(label: 'البريد الإلكتروني', value: profile['email'] as String? ?? ''),
                _ProfileField(label: 'العنوان', value: profile['address'] as String? ?? 'غير محدد'),
                _ProfileField(label: 'الجنس', value: profile['gender'] as String? ?? 'غير محدد'),
                _ProfileField(label: 'رصيد المحفظة', value: '${profile['wallet'] ?? profile['wallet_balance'] ?? 0} ج.م'),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 24.h)),
      ],
    );
  }

  Widget _buildEarningsTab(NurseDashboardLoaded state) {
    final earnings = state.earnings;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader('الأرباح')),
        SliverToBoxAdapter(child: SizedBox(height: 8.h)),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.calculate_rounded,
                    label: 'الإجمالي',
                    value: '${earnings.totalMonth.toStringAsFixed(2)} ج.م',
                    gradient: const LinearGradient(colors: [Color(0xFF0d9488), Color(0xFF14b8a6)]),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _StatCard(
                    icon: Icons.remove_circle_outline,
                    label: 'الخصم',
                    value: '${earnings.deducted.toStringAsFixed(2)} ج.م',
                    gradient: const LinearGradient(colors: [Color(0xFFef4444), Color(0xFFf87171)]),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 8.h)),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _StatCard(
              icon: Icons.account_balance_wallet_rounded,
              label: 'الصافي',
              value: '${earnings.actual.toStringAsFixed(2)} ج.م',
              gradient: const LinearGradient(colors: [Color(0xFF0f766e), Color(0xFF0d9488)]),
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 16.h)),
        if (earnings.breakdown.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'تفاصيل الأرباح',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 8.h)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = earnings.breakdown[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.receipt_rounded, color: AppTheme.primary),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              item.order,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              item.date,
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${item.amount.toStringAsFixed(2)} ج.م',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: earnings.breakdown.length,
            ),
          ),
        ],
        SliverToBoxAdapter(child: SizedBox(height: 24.h)),
      ],
    );
  }

  Widget _buildRatingsTab(NurseDashboardLoaded state) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader('التقييمات')),
        if (state.ratings.isEmpty)
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: const EmptyStateWidget(
                icon: Icons.star_outline,
                message: 'لا توجد تقييمات بعد',
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final rating = state.ratings[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            rating.date,
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: AppTheme.textSecondary),
                          ),
                          Row(
                            children: List.generate(5, (i) {
                              return Icon(
                                i < rating.rating ? Icons.star : Icons.star_border,
                                size: 18,
                                color: AppTheme.warning,
                              );
                            }),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        rating.patientName,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (rating.comment != null && rating.comment!.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          rating.comment!,
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, color: AppTheme.textSecondary),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ],
                  ),
                );
              },
              childCount: state.ratings.length,
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: 24.h)),
      ],
    );
  }

  Widget _buildActiveOrderCard(NurseOrderModel order, NurseDashboardLoaded state) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showOrderDetailModal(order),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _OrderStatusBadge(status: order.statusText, statusColor: order.isActive ? AppTheme.warning : AppTheme.primary),
                    Text(
                      order.patientName,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: AppTheme.textSecondary),
                    SizedBox(width: 4.w),
                    Text(
                      order.date,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: AppTheme.textSecondary),
                    ),
                    SizedBox(width: 16.w),
                    Icon(Icons.location_on, size: 14, color: AppTheme.textSecondary),
                    SizedBox(width: 4.w),
                    Text(
                      order.area,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  direction: Axis.horizontal,
                  children: order.services.map((s) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp, color: AppTheme.primary),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomButton(
                      text: 'قبول الطلب',
                      onPressed: () => context.read<NurseBloc>().add(AcceptNurseOrder(orderId: order.id)),
                      width: 120.w,
                      height: 40,
                    ),
                    Text(
                      '${order.totalPrice.toStringAsFixed(0)} ج.م',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyOrderCard(NurseOrderModel order, NurseDashboardLoaded state) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showOrderDetailModal(order),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _OrderStatusBadge(
                      status: order.statusText,
                      statusColor: order.isInProgress
                          ? AppTheme.primary
                          : order.isAwaitingCompletion
                              ? AppTheme.warning
                              : order.isCompleted
                                  ? AppTheme.success
                                  : order.isCancelled
                                      ? AppTheme.error
                                      : AppTheme.textSecondary,
                    ),
                    Text(
                      order.patientName,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: AppTheme.textSecondary),
                    SizedBox(width: 4.w),
                    Text(
                      order.date,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: AppTheme.textSecondary),
                    ),
                    SizedBox(width: 16.w),
                    Icon(Icons.location_on, size: 14, color: AppTheme.textSecondary),
                    SizedBox(width: 4.w),
                    Text(
                      order.area,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  direction: Axis.horizontal,
                  children: order.services.map((s) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp, color: AppTheme.primary),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (order.isInProgress)
                          CustomButton(
                            text: 'إتمام الطلب',
                            onPressed: () => context.read<NurseBloc>().add(CompleteNurseOrder(orderId: order.id)),
                            width: 110.w,
                            height: 38,
                          ),
                        if (order.isInProgress || order.isAwaitingCompletion) ...[
                          SizedBox(width: 8.w),
                          OutlinedButton(
                            onPressed: () => _confirmCancelOrder(order),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.error,
                              side: const BorderSide(color: AppTheme.error),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            ),
                            child: Text(
                              'إلغاء',
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${order.totalPrice.toStringAsFixed(0)} ج.م',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOrderDetailModal(NurseOrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'تفاصيل الطلب',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(width: 48.w),
                  ],
                ),
              ),
              Divider(color: Colors.grey[200], height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _DetailRow(label: 'رقم الطلب', value: order.orderNumber ?? order.id),
                      SizedBox(height: 12.h),
                      _DetailRow(label: 'اسم المريض', value: order.patientName),
                      SizedBox(height: 12.h),
                      _DetailRow(label: 'رقم الهاتف', value: order.patientPhone),
                      SizedBox(height: 12.h),
                      _DetailRow(label: 'العنوان', value: order.patientAddress),
                      SizedBox(height: 12.h),
                      _DetailRow(label: 'المنطقة', value: order.area),
                      SizedBox(height: 12.h),
                      _DetailRow(label: 'الحالة', value: order.statusText),
                      SizedBox(height: 12.h),
                      _DetailRow(label: 'التاريخ', value: order.date),
                      SizedBox(height: 16.h),
                      Text(
                        'الخدمات المطلوبة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      ...order.services.map((s) {
                        return Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 6.h),
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, color: AppTheme.textPrimary),
                            textAlign: TextAlign.right,
                          ),
                        );
                      }),
                      SizedBox(height: 16.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${order.totalPrice.toStringAsFixed(0)} ج.م',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                            Text(
                              'الإجمالي',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmCancelOrder(NurseOrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تأكيد الإلغاء', style: TextStyle(fontFamily: 'Cairo')),
        content: const Text('هل أنت متأكد من إلغاء هذا الطلب؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تراجع', style: TextStyle(fontFamily: 'Cairo')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NurseBloc>().add(CancelNurseOrder(orderId: order.id));
            },
            child: const Text('تأكيد', style: TextStyle(fontFamily: 'Cairo', color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

class _TabConfig {
  final IconData icon;
  final String label;

  const _TabConfig({required this.icon, required this.label});
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Gradient gradient;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 28),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.sp,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderStatusBadge extends StatelessWidget {
  final String status;
  final Color statusColor;

  const _OrderStatusBadge({required this.status, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: statusColor,
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              value.isEmpty ? 'غير محدد' : value,
              style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp, color: AppTheme.textPrimary),
              textAlign: TextAlign.left,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, color: AppTheme.textPrimary),
            textAlign: TextAlign.left,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }
}
