import 'package:flutter_bloc/flutter_bloc.dart';

class LoginUiCubit extends Cubit<bool> {
  LoginUiCubit() : super(true);

  void toggle() => emit(!state);
}
