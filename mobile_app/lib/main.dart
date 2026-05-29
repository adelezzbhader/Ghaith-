import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mongez/core/localization/localization_cubit.dart';
import 'package:mongez/core/theme/app_theme.dart';
import 'package:mongez/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mongez/injection_container.dart' as di;
import 'package:mongez/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initDependencies();
  runApp(const GhaithApp());
}

class GhaithApp extends StatefulWidget {
  const GhaithApp({super.key});

  @override
  State<GhaithApp> createState() => _GhaithAppState();
}

class _GhaithAppState extends State<GhaithApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    final authBloc = di.sl<AuthBloc>();
    _appRouter = AppRouter(authBloc: authBloc);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => di.sl<LocalizationCubit>()),
            BlocProvider(create: (_) => di.sl<AuthBloc>()),
          ],
          child: BlocBuilder<LocalizationCubit, Locale>(
            builder: (context, locale) {
              final isRtl = locale.languageCode == 'ar';
              return Directionality(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                child: MaterialApp.router(
                  title: 'غيث',
                  debugShowCheckedModeBanner: false,
                  locale: locale,
                  supportedLocales: const [Locale('ar'), Locale('en')],
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  theme: AppTheme.lightTheme,
                  routerConfig: _appRouter.router,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
