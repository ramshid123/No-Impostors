import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundpool/soundpool.dart';

final serviceLocator = GetIt.instance;

Future initDependencies() async {
  final soundPool = Soundpool.fromOptions(
    options: const SoundpoolOptions(
      streamType: StreamType.music,
    ),
  );

  final sharedPreference = await SharedPreferences.getInstance();

  serviceLocator.registerLazySingleton<Soundpool>(() => soundPool);
  serviceLocator
      .registerLazySingleton<SharedPreferences>(() => sharedPreference);
}
