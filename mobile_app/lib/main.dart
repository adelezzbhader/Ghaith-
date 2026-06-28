import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mongez/core/theme/app_theme.dart';
import 'package:mongez/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mongez/features/auth/presentation/bloc/auth_event.dart';
import 'package:mongez/features/home/presentation/bloc/home_bloc.dart';
import 'package:mongez/features/nurse/presentation/bloc/nurse_bloc.dart';
import 'package:mongez/features/patient/presentation/bloc/patient_bloc.dart';
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
    authBloc.add(const CheckAuthEvent());
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
            BlocProvider(create: (_) => di.sl<AuthBloc>()),
            BlocProvider(create: (_) => di.sl<HomeBloc>()),
            BlocProvider(create: (_) => di.sl<PatientBloc>()),
            BlocProvider(create: (_) => di.sl<NurseBloc>()),
          ],
          child: MaterialApp.router(
            title: 'غيث',
            debugShowCheckedModeBanner: false,
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar')],
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
    );
  }
}
