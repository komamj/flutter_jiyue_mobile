import 'package:flutter/material.dart';
import 'package:jiyue_mobile/data/enities/song.dart';
import 'package:jiyue_mobile/data/source/repository.dart';
import 'package:jiyue_mobile/favorite/my_favorite.dart';
import 'package:jiyue_mobile/util/constants.dart';
import 'package:jiyue_mobile/util/log_utlis.dart';

class ItemSong extends StatefulWidget {
  final Song _song;

  ItemSong(this._song);

  @override
  State<StatefulWidget> createState() {
    return _ItemSongState(_song);
  }
}

class _ItemSongState extends State<ItemSong> {
  static const String playlist = "addToPlaylist";
  static const String favorite = "favorite";

  final Song _song;

  _ItemSongState(this._song);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: FadeInImage(
        fit: BoxFit.cover,
        width: 55,
        height: 55,
        placeholder: AssetImage("images/ic_launcher.png"),
        image: NetworkImage(
          "${Constants.baseUrl}openmusic/album/${_song.albumId}/pic",
        ),
      ),
      title: Text(
        _song.name,
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _song.artistName,
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_vert),
        onSelected: (item) {
          _onPopMenuClick(item, _song);
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: playlist,
                child: const ListTile(
                  leading: Icon(Icons.playlist_add),
                  title: Text('加入播放列表'),
                ),
              ),
              PopupMenuItem<String>(
                value: favorite,
                child: const ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text('收藏'),
                ),
              )
            ],
      ),
    );
  }

  void _onPopMenuClick(String item, Song song) {
    switch (item) {
      case playlist:
        _addToPlaylist(song);
        break;
      case favorite:
        _addToFavorite(song);
        break;
      default:
        break;
    }
  }

  void _addToPlaylist(Song song) {
    JiYueRepository.singleton.addToPlaylist(song).then((result) {
      LogUtils.singleton.d("成功加入播放列表");
    });
  }

  void _addToFavorite(Song song) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MyFavorite(song: song);
    }));
  }
}
