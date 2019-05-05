import 'package:flutter/material.dart';
import 'package:jiyue_mobile/data/enities/favorite.dart';
import 'package:jiyue_mobile/data/enities/song.dart';
import 'package:jiyue_mobile/data/source/repository.dart';
import 'package:jiyue_mobile/util/constants.dart';
import 'package:jiyue_mobile/widget/item_song.dart';

class FavoriteDetail extends StatefulWidget {
  final Favorite _favorite;

  FavoriteDetail(this._favorite);

  @override
  State<StatefulWidget> createState() {
    return _FavoriteDetailState(_favorite);
  }
}

class _FavoriteDetailState extends State<FavoriteDetail> {
  final Favorite _favorite;

  final List<Song> songs = List<Song>();

  _FavoriteDetailState(this._favorite);

  @override
  void initState() {
    super.initState();

    _loadSongs();
  }

  _loadSongs() {
    JiYueRepository.singleton
        .getFavoriteSongsByFavoriteId(_favorite.id)
        .then((songs) {
      setState(() {
        this.songs.clear();
        this.songs.addAll(songs);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_favorite.name),
      ),
      body: ListView.separated(
          itemBuilder: (context, position) {
            return ItemSong(songs[position]);
          },
          separatorBuilder: (context, position) {
            return Divider();
          },
          itemCount: songs.length),
    );
  }
}
