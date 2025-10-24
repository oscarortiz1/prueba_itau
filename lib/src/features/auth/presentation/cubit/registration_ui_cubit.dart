import 'package:flutter_bloc/flutter_bloc.dart';

class RegistrationUiCubit extends Cubit<bool> {
  RegistrationUiCubit() : super(true);

  void toggle() => emit(!state);
}
