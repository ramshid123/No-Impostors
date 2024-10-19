import 'package:flutter_bloc/flutter_bloc.dart';

class CorrectPasskeyCubit extends Cubit<String> {
  CorrectPasskeyCubit() : super('');

  void updatePassKey(String key) {
    emit(key);
  }

  void clearPassKey() {
    emit('');
  }
}
