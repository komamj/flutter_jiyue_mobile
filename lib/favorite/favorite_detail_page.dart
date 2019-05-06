import 'package:flutter/material.dart';
import 'package:jiyue_mobile/data/enities/favorite.dart';
import 'package:jiyue_mobile/data/enities/song.dart';
import 'package:jiyue_mobile/data/source/repository.dart';
import 'package:jiyue_mobile/widget/item_song.dart';

class FavoriteDetail extends StatefulWidget {
  final Favorite favorite;

  FavoriteDetail({Key key, this.favorite}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FavoriteDetailState(favorite: favorite);
  }
}

class _FavoriteDetailState extends State<FavoriteDetail> {
  final Favorite favorite;

  final List<Song> _songs = List<Song>();

  _FavoriteDetailState({this.favorite});

  @override
  void initState() {
    super.initState();

    _loadSongs();
  }

  _loadSongs() {
    JiYueRepository.singleton
        .getFavoriteSongsByFavoriteId(favorite.id)
        .then((songs) {
      setState(() {
        this._songs.clear();
        this._songs.addAll(songs);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(favorite.name),
      ),
      body: Scrollbar(
        child: ListView.separated(
          itemBuilder: (context, position) {
            return ItemSong(_songs[position]);
          },
          separatorBuilder: (context, position) {
            return Divider();
          },
          itemCount: _songs.length,
        ),
      ),
    );
  }
}
