import 'package:flutter/material.dart';
import 'package:jiyue_mobile/data/source/repository.dart';
import 'package:jiyue_mobile/playing/now_playing.dart';
import 'package:jiyue_mobile/playing/now_playing_view_model.dart';
import 'package:jiyue_mobile/playing/playlist.dart';
import 'package:provide/provide.dart';

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
