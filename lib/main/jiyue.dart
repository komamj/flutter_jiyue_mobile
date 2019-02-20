import 'package:flutter/material.dart';
import 'package:jiyue_mobile/home/home_page.dart';
import 'package:jiyue_mobile/mine/mine_page.dart';
import 'package:jiyue_mobile/playing/now_playing_page.dart';
import 'package:jiyue_mobile/search/search_delegate.dart';
import 'package:jiyue_mobile/util/constants.dart';

void main() => runApp(MainPage());

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MainPageState();
  }
}

class MainPageState extends State<MainPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final JiYueSearchDelegate _delegate = JiYueSearchDelegate();

  final List<Widget> pages = [HomePage(), NowPlayingPage(), MinePage()];

  int _currentIndex = 1;

  DateTime _lastPressedTime;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            centerTitle: true,
            title: const Text(Constants.appTitle),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () async {
                  await showSearch(context: context, delegate: _delegate);
                },
              )
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  title: Text(Constants.home), icon: Icon(Icons.home)),
              BottomNavigationBarItem(
                  title: Text(Constants.nowPlaying),
                  icon: Icon(Icons.queue_music)),
              BottomNavigationBarItem(
                  title: Text(Constants.mine), icon: Icon(Icons.person))
            ],
            onTap: _onTap,
            currentIndex: this._currentIndex,
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
        ),
        onWillPop: () async {
          if (_lastPressedTime == null ||
              DateTime.now().difference(_lastPressedTime) >
                  Duration(seconds: 1)) {
            _lastPressedTime = DateTime.now();
            _scaffoldKey.currentState
                .showSnackBar(SnackBar(content: Text("再按一次退出应用")));
            return false;
          }
          return true;
        });
  }

  _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
