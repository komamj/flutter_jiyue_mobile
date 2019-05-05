import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jiyue_mobile/playing/now_playing_view_model.dart';
import 'package:jiyue_mobile/util/constants.dart';
import 'package:jiyue_mobile/util/log_utlis.dart';
import 'package:provide/provide.dart';

class NowPlaying extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NowPlayingState();
  }
}

class NowPlayingState extends State<NowPlaying>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  CurvedAnimation _curve;

  AnimationController _controller;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _controller = new AnimationController(
        duration: const Duration(milliseconds: 15000), vsync: this);
    _curve = new CurvedAnimation(parent: _controller, curve: Curves.linear);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.repeat();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 6),
                    shape: BoxShape.circle,
                  ),
                ),
                Provide<NowPlayingViewModel>(
                  builder: (context, child, viewModel) {
                    return RotationTransition(
                      turns: _curve,
                      child: CircleAvatar(
                        backgroundImage: viewModel.nowPlayingSong == null
                            ? AssetImage("images/ic_launcher.png")
                            : NetworkImage(
                                "${Constants.baseUrl}openmusic/album/${viewModel.nowPlayingSong.albumId}/pic"),
                        radius: 72,
                      ),
                    );
                  },
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text("当前门店正在播放：",
                    style: TextStyle(
                        color: Theme.of(context).accentColor, fontSize: 16.0),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.start),
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Provide<NowPlayingViewModel>(
                      builder: (context, child, viewModel) {
                    return Text(
                        viewModel.nowPlayingSong == null
                            ? "海阔天空"
                            : viewModel.nowPlayingSong.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12.0),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.start);
                  }),
                ),
                Provide<NowPlayingViewModel>(
                    builder: (context, child, viewModel) {
                  return Text(
                      viewModel.nowPlayingSong == null
                          ? "黄家驹"
                          : viewModel.nowPlayingSong.artistName,
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 10.0),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.start);
                }),
                Container(
                  margin: EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Provide<NowPlayingViewModel>(
                          builder: (context, child, viewModel) {
                        return IconButton(
                          icon: Icon(Icons.stop),
                          onPressed: () {
                            viewModel.stop();
                          },
                        );
                      }),
                      Provide<NowPlayingViewModel>(
                          builder: (context, child, viewModel) {
                        return IconButton(
                          icon: Icon(Icons.shuffle),
                          onPressed: viewModel.isStopped
                              ? null
                              : () {
                                  viewModel.shuffle();
                                },
                        );
                      }),
                      Provide<NowPlayingViewModel>(
                        builder: (context, child, viewModel) {
                          if (viewModel.isPlaying) {
                            _controller.forward();
                            return IconButton(
                              icon: Icon(Icons.pause),
                              onPressed: () {
                                viewModel.playOrPause();
                              },
                            );
                          } else {
                            _controller.stop(canceled: false);
                            return IconButton(
                                icon: Icon(Icons.play_arrow),
                                onPressed: () {
                                  viewModel.playOrPause();
                                });
                          }
                        },
                      ),
                      Provide<NowPlayingViewModel>(
                          builder: (context, child, viewModel) {
                        return IconButton(
                          icon: Icon(Icons.skip_next),
                          onPressed: viewModel.isStopped
                              ? null
                              : () {
                                  viewModel.next();
                                },
                        );
                      }),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        LogUtils.singleton.d("NowPlaying inactive");
        break;
      case AppLifecycleState.paused:
        LogUtils.singleton.d("NowPlaying paused");
        break;
      case AppLifecycleState.resumed:
        LogUtils.singleton.d("NowPlaying resume");
        break;
      case AppLifecycleState.suspending:
        LogUtils.singleton.d("NowPlaying suspending");
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    _controller.dispose();

    Provide.value<NowPlayingViewModel>(context).unBind();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }
}
