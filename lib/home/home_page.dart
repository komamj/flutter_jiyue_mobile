import 'package:flutter/material.dart';
import 'package:jiyue_mobile/data/enities/favorite.dart';
import 'package:jiyue_mobile/data/enities/ranking_list.dart';
import 'package:jiyue_mobile/data/source/repository.dart';
import 'package:jiyue_mobile/favorite/favorite_detail_page.dart';
import 'package:jiyue_mobile/rankinglist/ranking_list_detail_page.dart';
import 'package:jiyue_mobile/util/log_utlis.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<HomePage> {
  final List<Favorite> _favoriteList = List<Favorite>();

  final List<Item> _rankingLists = List<Item>();

  @override
  void initState() {
    super.initState();

    _loadFavoriteList();

    _loadRankingList();
  }

  void _loadFavoriteList() {
    JiYueRepository.singleton
        .getFavoriteList("createDate,desc")
        .then((favoriteList) {
      setState(() {
        _favoriteList.clear();
        _favoriteList.addAll(favoriteList);
      });
    }).catchError((error) {
      LogUtils.singleton.d("loadFavoriteList erorr:${error.toString()}");
    });
  }

  void _loadRankingList() {
    JiYueRepository.singleton.getRankingList().then((rankingList) {
      setState(() {
        _rankingLists.clear();
        rankingList.forEach((f) {
          _rankingLists.addAll(f.items);
        });

        LogUtils.singleton.d("_loadRankingList----${_rankingLists.length}");
      });
    }).catchError((error) {
      LogUtils.singleton.d("loadRankingList erorr:${error.toString()}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text("我的收藏"),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {},
                )
              ],
            ),
          ),
          Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, position) {
                final Favorite favorite = _favoriteList[position];
                return InkWell(
                  onTap: () {
                    Navigator.push(context,
                        new MaterialPageRoute(builder: (context) {
                      return FavoriteDetail(favorite);
                    }));
                  },
                  child: Container(
                    width: 128,
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: <Widget>[
                          Image.network(
                            "${_favoriteList[position].coverUrl}",
                            width: 128,
                            height: 72,
                            fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 8, bottom: 8, left: 2, right: 2),
                            child: Text(
                              _favoriteList[position].name,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              itemCount: _favoriteList.length <= 0 ? 0 : _favoriteList.length,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 12, right: 16, top: 8, bottom: 8),
            child: Row(
              children: <Widget>[
                Text("排行榜"),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
                itemBuilder: (context, position) {
                  final Item rankingList = _rankingLists[position];
                  return InkWell(
                    onTap: () {
                      Navigator.push(context,
                          new MaterialPageRoute(builder: (context) {
                        return RankingListDetail(rankingList);
                      }));
                    },
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 8, right: 16),
                          child: FadeInImage(
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                            placeholder: AssetImage("images/ic_launcher.png"),
                            image: NetworkImage(
                              "${rankingList.coverUrl}",
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                "${rankingList.preItems[0].title.trim()} - ${rankingList.preItems[0].artistName}",
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "${rankingList.preItems[1].title.trim()} - ${rankingList.preItems[1].artistName}",
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "${rankingList.preItems[2].title.trim()} - ${rankingList.preItems[2].artistName}",
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider();
                },
                itemCount:
                    _rankingLists.length <= 0 ? 0 : _rankingLists.length),
          ),
        ],
      ),
    );
  }
}
