import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeViewModel();
  }
}

class HomeViewModel extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Container(
            child: AspectRatio(
              aspectRatio: 2,
              child: Container(
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
    );
  }
}
