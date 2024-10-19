

import 'package:flutter_bloc/flutter_bloc.dart';

class PasskeyCubit extends Cubit<String> {
  PasskeyCubit() : super('');

  void updatePassKey(String newValue) {
    emit(state + newValue);
  }

  void clearPassKey() {
    emit('');
  }
}
