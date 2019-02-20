import 'package:flutter/material.dart';
import 'package:jiyue_mobile/util/constants.dart';
import 'package:jiyue_mobile/util/log_utlis.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashPageState();
  }
}

class SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  CurvedAnimation _curve;

  bool _isLogin = false;

  void initLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool loginStatus = prefs.getBool(Constants.keyIsLogin);
    if (loginStatus != null) {
      _isLogin = loginStatus;
    }
    LogUtils.singleton.d("login status:$_isLogin");
  }

  @override
  void initState() {
    super.initState();

    _controller = new AnimationController(
        duration: const Duration(seconds: 2), vsync: this);
    _curve = new CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    initLoginStatus();

    Future.delayed(Duration(seconds: 3)).then((onValue) {
      Navigator.pushReplacementNamed(context, _isLogin ? "/main" : "/login");
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage("images/bg_splash.png"))),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FadeTransition(
                    opacity: _curve,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Image(
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        image: AssetImage("images/ic_launcher.png"),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "CopyRight",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                      Icon(
                        Icons.copyright,
                        color: Colors.white,
                      ),
                      Text(
                        "2018",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                  Text(
                    "成都心尚信息技术有限公司",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
