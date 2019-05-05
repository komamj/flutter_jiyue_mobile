import 'package:flutter/material.dart';
import 'package:jiyue_mobile/data/enities/song.dart';
import 'package:jiyue_mobile/util/constants.dart';

class ItemSong extends StatefulWidget {
  final Song _song;

  ItemSong(this._song);

  @override
  State<StatefulWidget> createState() {
    return _ItemSongState(_song);
  }
}

class _ItemSongState extends State<ItemSong> {
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
                value: 'addToPlaylist',
                child: const ListTile(
                  leading: Icon(Icons.playlist_add),
                  title: Text('加入播放列表'),
                ),
              ),
              PopupMenuItem<String>(
                value: 'favorite',
                child: const ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text('收藏'),
                ),
              )
            ],
      ),
    );
  }

  void _onPopMenuClick(String item, Song song) {}
}
