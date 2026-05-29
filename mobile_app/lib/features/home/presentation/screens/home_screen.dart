import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mongez/core/constants/app_constants.dart';
import 'package:mongez/core/theme/app_theme.dart';
import 'package:mongez/features/home/domain/entities/service_entity.dart';
import 'package:mongez/features/home/domain/entities/stats_entity.dart';
import 'package:mongez/features/home/presentation/bloc/home_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;
  bool _showAppBar = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final show = _scrollController.offset > 300;
      if (show != _showAppBar) {
        setState(() => _showAppBar = show);
      }
    });
    context.read<HomeBloc>().add(const HomePageLoaded());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HomeError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message, style: const TextStyle(fontSize: 16, color: Colors.red)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.read<HomeBloc>().add(const HomePageLoaded()),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            );
          }
          final services = (state is HomeLoaded) ? state.services : <ServiceEntity>[];
          final stats = (state is HomeLoaded) ? state.stats : null;
          return SafeArea(
            child: Stack(
              children: [
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    _buildHeroSection(context, stats),
                    _buildRoleSelectionSection(context),
                    _buildStatsSection(context, stats),
                    _buildAboutSection(context),
                    _buildWhyChooseUsSection(context),
                    _buildHowItWorksSection(context),
                    _buildServicesSection(context, services),
                    _buildContactSection(context),
                  ],
                ),
                if (_showAppBar)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
                      decoration: BoxDecoration(
                        gradient: AppTheme.headerGradient,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Row(
                          children: [
                            Image.asset('assets/images/logo.png', height: 40, errorBuilder: (_, __, ___) =>
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text('غيث', style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Cairo',
                                )),
                              ),
                            ),
                            const Spacer(),
                            _buildSmallButton(context, 'دخول كممرض', AppTheme.primary, () {}),
                            const SizedBox(width: 8),
                            _buildSmallButton(context, 'دخول كمريض', AppTheme.secondary, () {}),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSmallButton(BuildContext context, String text, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.4)),
        ),
        child: Text(text, style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        )),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, StatsEntity? stats) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
        decoration: const BoxDecoration(
          gradient: AppTheme.headerGradient,
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('غيث', style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Cairo',
                letterSpacing: 4,
              )),
            ),
            const SizedBox(height: 12),
            const Text(
              'خدمات تمريضية منزلية موثوقة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'رعاية صحية احترافية في منزلك',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelectionSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0d9488), Color(0xFF0f766e)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0d9488).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.medical_services, size: 40, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text('دخول كممرض', style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Cairo',
                      )),
                      const SizedBox(height: 8),
                      Text('للحصول على فرص عمل', style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: 'Cairo',
                      )),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF06b6d4), Color(0xFF0891b2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF06b6d4).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.person, size: 40, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text('دخول كمريض', style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Cairo',
                      )),
                      const SizedBox(height: 8),
                      Text('لطلب خدمات تمريضية', style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                        fontFamily: 'Cairo',
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, StatsEntity? stats) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            Expanded(child: _buildStatCard('طلبات يومية', '${stats?.dailyRequests ?? 0}+', const Color(0xFF0d9488))),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('ثقة العملاء', '${stats?.clientTrust ?? 0}%', const Color(0xFF06b6d4))),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('ممرضين نشطين', '${stats?.activeNurses ?? 0}+', const Color(0xFF0f766e))),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'Cairo',
          )),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontFamily: 'Cairo',
          )),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('عن غيث', style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
              fontFamily: 'Cairo',
            )),
            const SizedBox(height: 8),
            Text(
              'منصتك الموثوقة للخدمات التمريضية المنزلية',
              style: TextStyle(fontSize: 14, color: Colors.grey[600], fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDFA),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF0d9488).withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0d9488).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.visibility, color: Color(0xFF0d9488), size: 28),
                        ),
                        const SizedBox(height: 16),
                        const Text('رؤيتنا', style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          fontFamily: 'Cairo',
                        )),
                        const SizedBox(height: 8),
                        Text(
                          'أن نكون المنصة الأولى في تقديم الخدمات التمريضية المنزلية في العالم العربي',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600], fontFamily: 'Cairo', height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFEFF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF06b6d4).withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF06b6d4).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.rocket_launch, color: Color(0xFF06b6d4), size: 28),
                        ),
                        const SizedBox(height: 16),
                        const Text('رسالتنا', style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          fontFamily: 'Cairo',
                        )),
                        const SizedBox(height: 8),
                        Text(
                          'توفير رعاية تمريضية منزلية عالية الجودة بأسعار مناسبة من خلال ممرضين معتمدين',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600], fontFamily: 'Cairo', height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhyChooseUsSection(BuildContext context) {
    final features = [
      {'icon': Icons.verified_user, 'title': 'ممرضين موثوقين', 'desc': 'جميع الممرضين معتمدين وموثوقين'},
      {'icon': Icons.attach_money, 'title': 'أسعار منافسة', 'desc': 'أسعار شفافة ومناسبة للجميع'},
      {'icon': Icons.speed, 'title': 'خدمة سريعة', 'desc': 'استجابة فورية لطلباتك'},
      {'icon': Icons.support_agent, 'title': 'دعم متواصل', 'desc': 'فريق دعم متاح 24/7'},
    ];
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('لماذا تختار غيث؟', style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
              fontFamily: 'Cairo',
            )),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: features.length,
              itemBuilder: (_, index) {
                final f = features[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDFA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(f['icon'] as IconData, color: const Color(0xFF0d9488), size: 28),
                      ),
                      const SizedBox(height: 12),
                      Text(f['title'] as String, textAlign: TextAlign.center, style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                        fontFamily: 'Cairo',
                      )),
                      const SizedBox(height: 4),
                      Text(f['desc'] as String, textAlign: TextAlign.center, style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontFamily: 'Cairo',
                      )),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    final steps = [
      {'step': '1', 'title': 'اختر الخدمة', 'desc': 'تصفح خدماتنا واختر ما يناسبك'},
      {'step': '2', 'title': 'حدد موقعك', 'desc': 'أدخل عنوانك واختر المنطقة'},
      {'step': '3', 'title': 'استقبل الممرض', 'desc': 'سيصلك ممرض معتمد في الوقت المحدد'},
    ];
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0d9488), Color(0xFF06b6d4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: [
            const Text('كيف يعمل غيث؟', style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Cairo',
            )),
            const SizedBox(height: 20),
            ...steps.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text(s['step']!, style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Cairo',
                    ))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s['title']!, style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Cairo',
                        )),
                        const SizedBox(height: 2),
                        Text(s['desc']!, style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.8),
                          fontFamily: 'Cairo',
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context, List<ServiceEntity> services) {
    if (services.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('خدماتنا التمريضية', style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
              fontFamily: 'Cairo',
            )),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: services.length,
              itemBuilder: (_, index) {
                final service = services[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                      Text(service.icon, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(service.nameAr, textAlign: TextAlign.center, style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                        fontFamily: 'Cairo',
                      )),
                      const SizedBox(height: 4),
                      Text('${service.price.toStringAsFixed(0)} ر.س', style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0d9488),
                        fontFamily: 'Cairo',
                      )),
                      if (service.perHour)
                        Text('/ساعة', style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                          fontFamily: 'Cairo',
                        )),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0d9488), Color(0xFF0f766e), Color(0xFF06b6d4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: [
            const Text('تواصل معنا', style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Cairo',
            )),
            const SizedBox(height: 8),
            Text('نحن هنا لمساعدتك على مدار الساعة', style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              fontFamily: 'Cairo',
            )),
            const SizedBox(height: 24),
            _buildContactRow(Icons.phone, AppConstants.phone),
            const SizedBox(height: 12),
            _buildContactRow(Icons.email, AppConstants.email),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildContactButton('واتساب', Icons.chat, () {}),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildContactButton('اتصل بنا', Icons.phone_in_talk, () {}),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(
          fontSize: 15,
          color: Colors.white,
          fontFamily: 'Cairo',
        )),
      ],
    );
  }

  Widget _buildContactButton(String text, IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: 'Cairo',
            )),
          ],
        ),
      ),
    );
  }
}
