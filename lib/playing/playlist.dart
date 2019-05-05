import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jiyue_mobile/playing/now_playing_view_model.dart';
import 'package:jiyue_mobile/util/constants.dart';
import 'package:jiyue_mobile/util/log_utlis.dart';
import 'package:provide/provide.dart';

class Playlist extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PlaylistState();
  }
}

class _PlaylistState extends State<Playlist> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provide.value<NowPlayingViewModel>(context);
    viewModel.loadPlaylist();

    return RefreshIndicator(
      child: Provide<NowPlayingViewModel>(
        builder: (context, child, viewModel) {
          return ListView.separated(
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, position) {
              return ListTile(
                leading: FadeInImage(
                  fit: BoxFit.cover,
                  width: 55,
                  height: 55,
                  placeholder: AssetImage("images/ic_launcher.png"),
                  image: NetworkImage(
                    "${Constants.baseUrl}openmusic/album/${viewModel.playlist[position].albumId}/pic",
                  ),
                ),
                title: Text(
                  viewModel.playlist[position].name,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  viewModel.playlist[position].artistName,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
            itemCount:
                viewModel.playlist.length <= 0 ? 0 : viewModel.playlist.length,
          );
        },
      ),
      onRefresh: () async {
        NowPlayingViewModel viewModel =
            Provide.value<NowPlayingViewModel>(context);
        viewModel.loadPlaylist();
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        LogUtils.singleton.d("Playlist inactive");
        break;
      case AppLifecycleState.paused:
        LogUtils.singleton.d("Playlist paused");
        break;
      case AppLifecycleState.resumed:
        LogUtils.singleton.d("Playlist resume");
        //更新播放列表
        Provide.value<NowPlayingViewModel>(context).loadPlaylist();
        break;
      case AppLifecycleState.suspending:
        LogUtils.singleton.d("Playlist suspending");
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }
}
