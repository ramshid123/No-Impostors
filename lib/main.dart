import 'package:amongus_lock/core/states/passkey_state.dart';
import 'package:amongus_lock/features/presentation/home%20page/cubit/passkey_cubit.dart';
import 'package:amongus_lock/features/presentation/splash%20screen/view.dart';
import 'package:amongus_lock/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [],
  );
  await initDependencies();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PasskeyCubit>(create: (_) => PasskeyCubit()),
        BlocProvider<CorrectPasskeyCubit>(create: (_) => CorrectPasskeyCubit()),
      ],
      child: const ScreenUtilInit(
        designSize: Size(392.72727272727275, 803.6363636363636),
        child: MaterialApp(
          title: 'No Impostors',
          home: SplashScreen(),
        ),
      ),
    );
  }
}
