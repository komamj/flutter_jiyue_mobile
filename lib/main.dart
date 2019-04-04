import 'package:flutter/material.dart';
import 'package:jiyue_mobile/login/login_page.dart';
import 'package:jiyue_mobile/main/jiyue.dart';
import 'package:jiyue_mobile/splash/splash_page.dart';
import 'package:jiyue_mobile/util/constants.dart';

void main() => runApp(JiYue());

class JiYue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: Constants.appTitle,
      theme: ThemeData(primarySwatch: Colors.orange),
      routes: <String, WidgetBuilder>{
        "/login": (context) => LoginPage(),
        "/main": (context) => MainPage()
      },
      home: SplashPage(),
    );
  }
}
