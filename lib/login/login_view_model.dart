import 'package:flutter/material.dart';
import 'package:jiyue_mobile/data/source/repository.dart';

class LoginViewModel with ChangeNotifier {
  bool _isLoading;

  bool get isLoading => _isLoading;

  login(String userName, String password) {
    _isLoading = true;
    JiYueRepository.singleton
        .login(userName, password)
        .then((loginStatus) {})
        .catchError((e) {
      debugPrint(e.toString());
    }).whenComplete(() {
      _isLoading = false;
    });
  }
}
