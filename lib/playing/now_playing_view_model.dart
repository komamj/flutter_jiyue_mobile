import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:jiyue_mobile/data/enities/command.dart';
import 'package:jiyue_mobile/data/enities/play_state.dart';
import 'package:jiyue_mobile/data/enities/store_song.dart';
import 'package:jiyue_mobile/data/source/repository.dart';
import 'package:jiyue_mobile/util/constants.dart';
import 'package:jiyue_mobile/util/log_utlis.dart';
import 'package:web_socket_channel/io.dart';

class NowPlayingViewModel with ChangeNotifier {
  final JiYueRepository _repository;

  IOWebSocketChannel _channel;

  StoreSong _nowPlayingSong;

  StoreSong get nowPlayingSong => _nowPlayingSong;

  //当前的播放列表
  final List _playlist = List<StoreSong>();

  List<StoreSong> get playlist => _playlist;

  //播放状态
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  //停止状态
  bool _isStopped = true;

  bool get isStopped => _isStopped;

  //播放模式
  bool _isShuffle = false;

  bool get isShuffle => _isShuffle;

  NowPlayingViewModel(this._repository);

  bindMusicBox() {
    _channel = IOWebSocketChannel.connect(Constants.aLiWebSocketEndpoint);
    _repository.getString(Constants.keyUserId).then((userId) {
      _channel.sink.add(json
          .encode(Command(userId: userId, action: Constants.bind, data: null)));
      _channel.stream.listen((message) {
        PlayState playState = PlayState.fromJson(json.decode(message));
        _handlePlayState(playState);
      });
    });
  }

  unBind() {
    _channel.sink.close();
  }

  void _handlePlayState(PlayState playState) {
    LogUtils.singleton.d("_handlePlayState playState:${playState.toString()}");
    if (playState.code != 0) {
      return;
    }
    if (playState.action == Constants.status) {
      String playStatus = playState.data;
      if (playStatus == Constants.playing) {
        _isPlaying = true;
        _isStopped = false;
        _loadNowPlayingSong(playState.message);
      } else if (playStatus == Constants.paused) {
        _isPlaying = false;
        _isStopped = false;
      } else if (playStatus == Constants.stopped) {
        _isPlaying = false;
        _isStopped = true;
      }
    } else if (playState.action == Constants.play) {
      _isPlaying = true;
      _isStopped = false;
      _loadNowPlayingSong(playState.message);
    } else if (playState.action == Constants.start) {
      _isPlaying = true;
      _isStopped = false;
    } else if (playState.action == Constants.pause) {
      _isPlaying = false;
      _isStopped = false;
    } else if (playState.action == Constants.stop) {
      _isPlaying = false;
      _isStopped = true;
    } else if (playState.action == Constants.playState) {}

    notifyListeners();
  }

  void loadPlaylist() {
    _repository.getString(Constants.keyUserId).then((userId) {
      return _repository.getNowPlayingList(userId);
    }).then((storeSongs) {
      _playlist.clear();
      _playlist.addAll(storeSongs);
      bindMusicBox();
      notifyListeners();
    }).catchError((error) {
      LogUtils.singleton.d("_loadPlaylist erorr:${error.toString()}");
    });
  }

  void _loadNowPlayingSong(String nowPlayingId) {
    LogUtils.singleton.d("_loadNowPlayingSong nowPlayingId:$nowPlayingId");
    _playlist.forEach((storeSong) {
      if (storeSong.contentId == nowPlayingId) {
        _nowPlayingSong = storeSong;
        LogUtils.singleton.d(
            "_loadNowPlayingSong nowPlayingSong:${_nowPlayingSong.toString()}");
        notifyListeners();
      }
    });
  }

  void _sendCommand(Command command) {
    _channel.sink.add(json.encode(command));
  }

  void next() {
    _repository.getString(Constants.keyUserId).then((userId) {
      _sendCommand(Command(userId: userId, action: Constants.next, data: null));
    });
  }

  void playOrPause() {
    _repository.getString(Constants.keyUserId).then((userId) {
      _sendCommand(Command(
          userId: userId,
          action: _isPlaying ? Constants.pause : Constants.play,
          data: null));
    });
  }

  void shuffle() {
    _repository.getString(Constants.keyUserId).then((userId) {
      _sendCommand(Command(
          userId: userId,
          action: Constants.playMode,
          data: _isShuffle ? Constants.sequence : Constants.random));
    });
  }

  void stop() {
    _repository.getString(Constants.keyUserId).then((userId) {
      _sendCommand(Command(userId: userId, action: Constants.stop, data: null));
    }).whenComplete(() {
      notifyListeners();
    });
  }
}
