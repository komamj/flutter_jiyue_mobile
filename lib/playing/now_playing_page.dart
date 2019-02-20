import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jiyue_mobile/data/enities/command.dart';
import 'package:jiyue_mobile/data/enities/play_state.dart';
import 'package:jiyue_mobile/data/enities/store_song.dart';
import 'package:jiyue_mobile/data/source/repository.dart';
import 'package:jiyue_mobile/util/constants.dart';
import 'package:jiyue_mobile/util/log_utlis.dart';
import 'package:web_socket_channel/io.dart';

class NowPlayingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NowPlayingPageState();
  }
}

class NowPlayingPageState extends State<NowPlayingPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  AnimationController _controller;

  CurvedAnimation _curve;

  bool _isPlaying = true;

  String _playState;

  VoidCallback _next, _playOrPause, _stop, _shuffle;

  final List<StoreSong> _storeSongs = List<StoreSong>();

  StoreSong _storeSong;

  IOWebSocketChannel _channel;

  @override
  void initState() {
    super.initState();

    _initCallback();

    JiYueRepository.singleton.getString(Constants.keyUserId).then((userId) {
      return JiYueRepository.singleton.getNowPlayingList(userId);
    }).then((storeSongs) {
      setState(() {
        _storeSongs.clear();
        _storeSongs.addAll(storeSongs);
      });
      _bind();
    }).catchError((error) {
      LogUtils.singleton.d("_onRefresh erorr:${error.toString()}");
    });

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
    _controller.forward();
  }

  void _initCallback() {}

  void _bind() async {
    _channel = IOWebSocketChannel.connect(Constants.aLiWebSocketEndpoint);

    JiYueRepository.singleton.getString(Constants.keyUserId).then((userId) {
      _channel.sink.add(json.encode(Command(userId, Constants.bind, null)));
      _channel.stream.listen((message) {
       // LogUtils.singleton.d("socket data:$message");
        PlayState playState = PlayState.fromJson(json.decode(message));
        _handlePlayState(playState);
      });
    });
  }

  void _handlePlayState(PlayState playState) {
    if (playState.code != 0) {
      return;
    }
    if (playState.action == Constants.status) {
      String playStatus = playState.data;
      if (playStatus == Constants.playing) {
        setState(() {
          _isPlaying = true;

          _next = () {
            JiYueRepository.singleton
                .getString(Constants.keyUserId)
                .then((userId) {
              _sendCommand(Command(userId, Constants.next, null));
            });
          };
          _playOrPause = () {
            JiYueRepository.singleton
                .getString(Constants.keyUserId)
                .then((userId) {
              _sendCommand(Command(
                  userId, _isPlaying ? Constants.pause : Constants.play, null));
            });
          };
          _stop = () {
            JiYueRepository.singleton
                .getString(Constants.keyUserId)
                .then((userId) {
              _sendCommand(Command(userId, Constants.stop, null));
            });
          };
          _shuffle = () {};
        });
        _loadNowPlayingSong(playState.message);
        LogUtils.singleton.d("now playing id:${playState.message}");
      } else if (playStatus == Constants.paused) {
        setState(() {
          _isPlaying = false;

          _next = () {
            JiYueRepository.singleton
                .getString(Constants.keyUserId)
                .then((userId) {
              _sendCommand(Command(userId, Constants.next, null));
            });
          };
          _playOrPause = () {
            JiYueRepository.singleton
                .getString(Constants.keyUserId)
                .then((userId) {
              _sendCommand(Command(
                  userId, _isPlaying ? Constants.pause : Constants.play, null));
            });
          };
          _stop = () {
            JiYueRepository.singleton
                .getString(Constants.keyUserId)
                .then((userId) {
              _sendCommand(Command(userId, Constants.stop, null));
            });
          };
          _shuffle = () {};
        });
      } else if (playStatus == Constants.stopped) {
        setState(() {
          _isPlaying = false;

          _next = null;
          _playOrPause = () {
            JiYueRepository.singleton
                .getString(Constants.keyUserId)
                .then((userId) {
              _sendCommand(Command(
                  userId, _isPlaying ? Constants.pause : Constants.play, null));
            });
          };
          _stop = null;
          _shuffle = null;
        });
      }
    } else if (playState.action == Constants.play) {
      setState(() {
        _isPlaying = true;
      });

      _loadNowPlayingSong(playState.message);
    } else if (playState.action == Constants.start) {
      setState(() {
        _isPlaying = true;
      });
    } else if (playState.action == Constants.pause) {
      setState(() {
        _isPlaying = false;
      });
    } else if (playState.action == Constants.stop) {
      setState(() {
        _isPlaying = false;

        _next = null;
      });
    } else if (playState.action == Constants.playState) {}

    if (_isPlaying) {
      _controller.forward();
    } else {
      _controller.stop(canceled: false);
    }
  }

  void _loadNowPlayingSong(String playId) {
    _storeSongs.forEach((storeSong) {
      if (storeSong.contentId == playId) {
        setState(() {
          _storeSong = storeSong;

         // LogUtils.singleton.d("_loadNowPlayingSong $_storeSong");
        });
        return;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        LogUtils.singleton.d("inactive");
        break;
      case AppLifecycleState.paused:
        LogUtils.singleton.d("paused");

        _channel.sink.close();
        break;
      case AppLifecycleState.resumed:
        LogUtils.singleton.d("resume");

        _bind();

        _onRefresh();
        break;
      case AppLifecycleState.suspending:
        LogUtils.singleton.d("suspending");
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
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
                    RotationTransition(
                      turns: _curve,
                      child: CircleAvatar(
                        backgroundImage: _storeSong == null
                            ? AssetImage("images/ic_launcher.png")
                            : NetworkImage(
                                "${Constants.aLiEndpoint}api/v1/openmusic/album/${_storeSong.albumId}/pic"),
                        radius: 72,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text("当前门店正在播放：",
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 16.0),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.start),
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(_storeSong == null ? "海阔天空" : _storeSong.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12.0),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.start),
                    ),
                    Text(_storeSong == null ? "黄家驹" : _storeSong.artistName,
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 10.0),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.start),
                    Container(
                      margin: EdgeInsets.only(top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.stop),
                            onPressed: _stop,
                          ),
                          IconButton(
                            icon: Icon(Icons.shuffle),
                            onPressed: _shuffle,
                          ),
                          IconButton(
                            icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow),
                            onPressed: _playOrPause,
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_next),
                            onPressed: _next,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            child: ListView.separated(
              separatorBuilder: (BuildContext context, int index) => Divider(),
              itemBuilder: (BuildContext context, int position) {
                return ListTile(
                  leading: FadeInImage(
                    fit: BoxFit.cover,
                    width: 55,
                    height: 55,
                    placeholder: AssetImage("images/ic_launcher.png"),
                    image: NetworkImage(
                      "${Constants.aLiEndpoint}api/v1/openmusic/album/${_storeSongs[position].albumId}/pic",
                    ),
                  ),
                  title: Text(_storeSongs[position].name),
                  subtitle: Text(_storeSongs[position].artistName),
                );
              },
              itemCount: _storeSongs.length <= 0 ? 0 : _storeSongs.length,
            ),
            onRefresh: _onRefresh,
          ),
        )
      ],
    );
  }

  Future<Null> _onRefresh() async {
    JiYueRepository.singleton.getString(Constants.keyUserId).then((userId) {
      return JiYueRepository.singleton.getNowPlayingList(userId);
    }).then((storeSongs) {
      setState(() {
        _storeSongs.clear();
        _storeSongs.addAll(storeSongs);
      });
    }).catchError((error) {
      LogUtils.singleton.d("_onRefresh erorr:${error.toString()}");
    });
  }

  void _sendCommand(Command command) {
    _channel.sink.add(json.encode(command));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _channel.sink.close();

    super.dispose();
  }
}
