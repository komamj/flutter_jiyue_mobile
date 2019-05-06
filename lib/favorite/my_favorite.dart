import 'package:flutter/material.dart';
import 'package:jiyue_mobile/data/enities/favorite.dart';
import 'package:jiyue_mobile/data/enities/song.dart';
import 'package:jiyue_mobile/data/source/repository.dart';
import 'package:jiyue_mobile/util/log_utlis.dart';
import 'package:jiyue_mobile/widget/loading.dart';

class MyFavorite extends StatefulWidget {
  final Song song;

  MyFavorite({Key key, this.song}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MyFavoriteState(song: song);
  }
}

class _MyFavoriteState extends State<MyFavorite> {
  final List<Favorite> favorites = List<Favorite>();

  final Song song;

  bool _isLoading = true;

  _MyFavoriteState({this.song});

  @override
  void initState() {
    super.initState();

    _loadFavorites();
  }

  _loadFavorites() {
    JiYueRepository.singleton
        .getFavoriteList("createDate,desc")
        .then((favorites) {
      setState(() {
        this.favorites.clear();
        this.favorites.addAll(favorites);
      });
    }).whenComplete(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("我的收藏"),
      ),
      body: _getBody(),
    );
  }

  _getBody() {
    if (_isLoading) {
      return Loading();
    } else {
      return Scrollbar(
        child: ListView.separated(
          itemBuilder: (context, position) {
            final Favorite favorite = favorites[position];
            return ListTile(
              onTap: () {
                _onItemClick(favorite);
              },
              leading: FadeInImage(
                fit: BoxFit.cover,
                width: 55,
                height: 55,
                placeholder: AssetImage("images/ic_launcher.png"),
                image: NetworkImage(
                  "${favorite.coverUrl}",
                ),
              ),
              title: Text(favorite.name),
              subtitle: Text("创建于${favorite.createTime}"),
            );
          },
          separatorBuilder: (context, position) {
            return Divider();
          },
          itemCount: favorites.length <= 0 ? 0 : favorites.length,
        ),
      );
    }
  }

  _onItemClick(Favorite favorite) {
    JiYueRepository.singleton.addToFavorite(favorite.id, song).then((result) {
      LogUtils.singleton.d("收藏成功。");
    }).whenComplete(() {
      Navigator.of(context).pop();
    });
  }
}
