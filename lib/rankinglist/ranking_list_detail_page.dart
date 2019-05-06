import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:jiyue_mobile/data/enities/ranking_list.dart';
import 'package:jiyue_mobile/data/enities/song.dart';
import 'package:jiyue_mobile/data/source/repository.dart';
import 'package:jiyue_mobile/util/log_utlis.dart';
import 'package:jiyue_mobile/widget/item_song.dart';

class RankingListDetail extends StatefulWidget {
  final Item rankingList;

  RankingListDetail({Key key, this.rankingList}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RankingListDetailState(rankingList: rankingList);
  }
}

class _RankingListDetailState extends State<RankingListDetail> {
  final Item rankingList;

  final List<Song> _songs = List<Song>();

  final ScrollController _controller = new ScrollController();

  int _currentPage = 0;

  _RankingListDetailState({this.rankingList});

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        // _loadNextPageSongs();
      }
    });

    _loadSongs();
  }

  _loadSongs() {
    _currentPage = 0;

    JiYueRepository.singleton
        .getRankingListDetail(
            rankingList.id, rankingList.key, rankingList.date, _currentPage)
        .then((songs) {
      setState(() {
        this._songs.clear();
        this._songs.addAll(songs);
      });
    }).catchError((error) {
      LogUtils.singleton.d("加载排行榜详情失败");
    });
  }

  /*_loadNextPageSongs() {
    JiYueRepository.singleton
        .getRankingListDetail(
            rankingList.id, rankingList.key, rankingList.date, _currentPage + 1)
        .then((songs) {
      _currentPage += 1;
      setState(() {
        this._songs.addAll(songs);
      });
    }).catchError((error) {
      LogUtils.singleton.d("加载排行榜详情下一页失败");
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            floating: false,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(rankingList.title),
              background: Stack(
                fit: StackFit.expand,
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  FadeInImage(
                    fit: BoxFit.cover,
                    placeholder: AssetImage("images/ic_launcher.png"),
                    image: NetworkImage(
                      "${rankingList.coverUrl}",
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
                _songs.map<Widget>((Song song) => ItemSong(song)).toList()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.play_arrow),
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    super.dispose();

    _controller.dispose();
  }
}
