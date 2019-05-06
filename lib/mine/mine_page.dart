import 'package:flutter/material.dart';
import 'package:jiyue_mobile/data/source/repository.dart';
import 'package:jiyue_mobile/login/login_page.dart';
import 'package:jiyue_mobile/util/constants.dart';

class MinePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MineViewModel();
  }
}

class MineViewModel extends State<MinePage> {
  String nickName = "---";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        Row(
          children: <Widget>[
            Image(
              width: 75.0,
              height: 75.0,
              image: AssetImage("images/ic_avatar.png"),
            ),
            Text(nickName),
          ],
        ),
        FlatButton(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text("取消登录"),
          color: Theme.of(context).accentColor,
          textColor: Colors.white,
          onPressed: () {
            JiYueRepository.singleton.setBool(Constants.keyIsLogin, false);
            JiYueRepository.singleton.setString(Constants.keyUserName, "");
            JiYueRepository.singleton.setString(Constants.keyPassword, "");
            Navigator.of(context).pushNamedAndRemoveUntil(
                LoginPage.routeName, ModalRoute.withName('/'));
          },
        ),
      ],
    ));
  }
}
