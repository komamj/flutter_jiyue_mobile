import 'package:flutter/material.dart';
import 'package:jiyue_mobile/data/source/repository.dart';
import 'package:jiyue_mobile/login/login_view_model.dart';
import 'package:jiyue_mobile/util/constants.dart';
import 'package:provide/provide.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = "/login";

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final LoginViewModel _viewModel = LoginViewModel(JiYueRepository.singleton);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _userNameController.addListener(() {
      _viewModel.checkName(_userNameController.text);
    });
    _passwordController.addListener(() {
      _viewModel.checkPassword(_passwordController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProviderNode(
      providers: Providers()
        ..provide(Provider.function((context) => _viewModel)),
      child: Scaffold(
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
          child: Column(
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
                            child: Provide<LoginViewModel>(
                              builder: (context, child, viewModel) {
                                return RaisedButton(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  color: Theme.of(context).accentColor,
                                  textColor: Colors.white,
                                  child: Text(Constants.login),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0)),
                                  onPressed: viewModel.isValid
                                      ? () {
                                          _login();
                                        }
                                      : null,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _setLoadingIndicator(bool isActive) {
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
    _setLoadingIndicator(true);

    _viewModel
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
      _setLoadingIndicator(false);
    });
  }
}
