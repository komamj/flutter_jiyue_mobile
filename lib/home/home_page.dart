import 'package:flutter/material.dart';
import 'package:jiyue_mobile/data/enities/favorite.dart';
import 'package:jiyue_mobile/data/enities/ranking_list.dart';
import 'package:jiyue_mobile/data/source/repository.dart';
import 'package:jiyue_mobile/favorite/favorite_detail_page.dart';
import 'package:jiyue_mobile/rankinglist/ranking_list_detail_page.dart';
import 'package:jiyue_mobile/util/log_utlis.dart';
import 'package:jiyue_mobile/widget/loading.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<HomePage> {
  static const String modifyName = "modifyName";
  static const String delete = "delete";

  final List<Favorite> _favoriteList = List<Favorite>();

  final List<Item> _rankingLists = List<Item>();

  bool _isLoading = true;

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
    }).whenComplete(() {
      _isLoading = false;
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
    }).whenComplete(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _getWidget(),
    );
  }

  _createFavorite() {
    showDialog<String>(
        context: context,
        builder: (context) {
          String favoriteName;
          return AlertDialog(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            title: Text("新建"),
            content: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: '请输入歌单名字...',
                labelText: '名称',
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  favoriteName = value;
                }
              },
            ),
            actions: <Widget>[
              FlatButton(
                child: const Text('取消'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: const Text('确定'),
                onPressed: () {
                  Navigator.pop(context, favoriteName);
                },
              ),
            ],
          );
        }).then((name) {
      if (name.isNotEmpty) {
        JiYueRepository.singleton.createFavorite(name).then((result) {
          if (result) {
            _loadFavoriteList();
          }
          LogUtils.singleton.d("创建歌单成功。");
        });
      }
    });
  }

  _getWidget() {
    if (_isLoading) {
      return Loading();
    } else {
      return Column(
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
                  onPressed: () {
                    _createFavorite();
                  },
                )
              ],
            ),
          ),
          Container(
            height: 128,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, position) {
                final Favorite favorite = _favoriteList[position];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      new MaterialPageRoute(builder: (context) {
                        return FavoriteDetail(favorite: favorite);
                      }),
                    );
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
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: Text(
                                    _favoriteList[position].name,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.more_vert,
                                ),
                                onSelected: (item) {
                                  _onPopMenuClick(item, favorite);
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                      PopupMenuItem<String>(
                                        value: modifyName,
                                        child: const Text('重命名'),
                                      ),
                                      PopupMenuItem<String>(
                                        value: delete,
                                        child: const Text('删除'),
                                      ),
                                    ],
                              ),
                            ],
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
            child: Scrollbar(
              child: ListView.separated(
                itemBuilder: (context, position) {
                  final Item rankingList = _rankingLists[position];
                  return InkWell(
                    onTap: () {
                      Navigator.push(context,
                          new MaterialPageRoute(builder: (context) {
                        return RankingListDetail(rankingList: rankingList);
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
                itemCount: _rankingLists.length <= 0 ? 0 : _rankingLists.length,
              ),
            ),
          ),
        ],
      );
    }
  }

  void _onPopMenuClick(String item, Favorite favorite) {
    switch (item) {
      case modifyName:
        break;
      case delete:
        _deleteFavorite(favorite);
        break;
      default:
        break;
    }
  }

  _deleteFavorite(Favorite favorite) {
    JiYueRepository.singleton.deleteFavorite(favorite.id).then((result) {
      if (result) {
        setState(() {
          _favoriteList.remove(favorite);
        });

        LogUtils.singleton.d("删除歌单成功。");
      }
    });
  }
}
