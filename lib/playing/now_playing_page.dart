import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jiyue_mobile/data/enities/command.dart';
import 'package:jiyue_mobile/data/enities/play_state.dart';
import 'package:jiyue_mobile/data/enities/store_song.dart';
import 'package:jiyue_mobile/data/source/repository.dart';
import 'package:jiyue_mobile/playing/now_playing.dart';
import 'package:jiyue_mobile/playing/now_playing_view_model.dart';
import 'package:jiyue_mobile/playing/playlist.dart';
import 'package:jiyue_mobile/util/constants.dart';
import 'package:jiyue_mobile/util/log_utlis.dart';
import 'package:provide/provide.dart';
import 'package:web_socket_channel/io.dart';

class NowPlayingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderNode(
      providers: Providers()
        ..provide(Provider.function(
            (context) => NowPlayingViewModel(JiYueRepository.singleton))),
      child: Column(
        children: <Widget>[
          NowPlaying(),
          Expanded(
            child: Playlist(),
          )
        ],
      ),
    );
  }
}
