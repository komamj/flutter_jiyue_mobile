import 'dart:core';

import 'package:flutter/material.dart';
import 'package:jiyue_mobile/data/source/repository.dart';

class LoginViewModel with ChangeNotifier {
  final JiYueRepository _repository;

  bool _isValid = false;
  bool _isValidName = false;
  bool _isValidPassword = false;

  bool get isValid => _isValid;

  LoginViewModel(this._repository);

  Future<bool> login(String userName, String password) {
    return _repository.login(userName, password);
  }

  void checkName(String userName) {
    if (userName.trim().isNotEmpty && userName.trim().length > 0) {
      _isValidName = true;
    } else {
      _isValidName = false;
    }

    _checkValid();
  }

  void checkPassword(String password) {
    if (password.isNotEmpty && password.length > 5) {
      _isValidPassword = true;
    } else {
      _isValidPassword = false;
    }

    _checkValid();
  }

  void _checkValid() {
    if (_isValidName && _isValidPassword) {
      _isValid = true;
    } else {
      _isValid = false;
    }
    notifyListeners();
  }
}
