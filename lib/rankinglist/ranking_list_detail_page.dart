import 'package:flutter/material.dart';
import 'package:jiyue_mobile/data/enities/ranking_list.dart';
import 'package:jiyue_mobile/data/enities/song.dart';
import 'package:jiyue_mobile/data/source/repository.dart';
import 'package:jiyue_mobile/widget/item_song.dart';

class RankingListDetail extends StatefulWidget {
  final Item _rankingList;

  RankingListDetail(this._rankingList);

  @override
  State<StatefulWidget> createState() {
    return _RankingListDetailState(_rankingList);
  }
}

class _RankingListDetailState extends State<RankingListDetail> {
  final Item _rankingList;

  final List<Song> songs = List<Song>();

  _RankingListDetailState(this._rankingList);

  @override
  void initState() {
    super.initState();

    _loadSongs();
  }

  _loadSongs() {
    JiYueRepository.singleton
        .getRankingListDetail(
            _rankingList.id, _rankingList.key, _rankingList.date, 1)
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
        title: Text("${_rankingList.title}"),
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
