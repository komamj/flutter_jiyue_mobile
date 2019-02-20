import 'package:flutter/material.dart';
import 'package:jiyue_mobile/data/source/repository.dart';
import 'package:jiyue_mobile/util/constants.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _userNameValid = false;
  bool _passwordValid = false;

  VoidCallback _onLoginPressed;

  TextEditingController _userNameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _userNameController.addListener(() {
      String userName = _userNameController.text;
      if (userName.trim().isNotEmpty) {
        _userNameValid = true;
      } else {
        _userNameValid = false;
      }
      updateLoginButtonStatus();
    });
    _passwordController.addListener(() {
      String password = _passwordController.text;
      if (password.isNotEmpty && password.length > 5) {
        _passwordValid = true;
      } else {
        _passwordValid = false;
      }
      updateLoginButtonStatus();
    });
  }

  void updateLoginButtonStatus() {
    debugPrint(
        "userName:${_userNameController.text},password:${_passwordController.text}");
    setState(() {
      if (_userNameValid && _passwordValid) {
        _onLoginPressed = () {
          _login();
        };
      } else {
        _onLoginPressed = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "登录",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
          child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 32.0, bottom: 16.0),
                child: Image(
                    width: 75.0,
                    height: 75.0,
                    image: AssetImage("images/ic_avatar.png")),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      maxLines: 1,
                      autofocus: false,
                      autovalidate: true,
                      cursorColor: Theme.of(context).accentColor,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        hintText: Constants.userNameHint,
                        labelText: Constants.userName,
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        return v.trim().length > 0
                            ? null
                            : Constants.userNameInvalid;
                      },
                      controller: _userNameController,
                    ),
                    TextFormField(
                        maxLines: 1,
                        autovalidate: true,
                        controller: _passwordController,
                        cursorColor: Theme.of(context).accentColor,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.lock),
                          hintText: Constants.passwordHint,
                          labelText: Constants.password,
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        validator: (v) {
                          return v.trim().length > 5
                              ? null
                              : Constants.passwordInvalid;
                        }),
                    Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              color: Theme.of(context).accentColor,
                              textColor: Colors.white,
                              child: Text(Constants.login),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0)),
                              onPressed: _onLoginPressed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      )),
    );
  }

  @override
  void dispose() {
    super.dispose();

    _userNameController.dispose();
    _passwordController.dispose();
  }

  setLoadingIndicator(bool isActive) {
    if (isActive) {
      showDialog(
          context: this.context,
          barrierDismissible: true,
          builder: (context) {
            return SimpleDialog(
              contentPadding: EdgeInsets.only(top: 32.0, bottom: 32.0),
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Text("正在登录中..."),
                    )
                  ],
                )
              ],
            );
          });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _login() {
    setLoadingIndicator(true);

    JiYueRepository.singleton
        .login(_userNameController.text, _passwordController.text)
        .then((loginStatus) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(loginStatus ? "登录成功" : "登录失败，请重试"),
          duration: Duration(seconds: 1)));

      if (loginStatus) {
        Future.delayed(Duration(seconds: 2)).then((onValue) {
          Navigator.pushReplacementNamed(context, "/main");
        });
      }
    }).catchError((e) {
      debugPrint(e.toString());
    }).whenComplete(() {
      setLoadingIndicator(false);
    });
  }
}
