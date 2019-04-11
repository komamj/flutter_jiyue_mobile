import 'dart:core';

import 'package:jiyue_mobile/data/enities/favorite.dart';
import 'package:jiyue_mobile/data/enities/favorite_song.dart';
import 'package:jiyue_mobile/data/enities/ranking_list.dart';
import 'package:jiyue_mobile/data/enities/song.dart';
import 'package:jiyue_mobile/data/enities/store_song.dart';
import 'package:jiyue_mobile/data/source/local/local_data_source.dart';
import 'package:jiyue_mobile/data/source/remote/remote_data_source.dart';
import 'package:jiyue_mobile/util/constants.dart';
import 'package:jiyue_mobile/util/log_utlis.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JiYueRepository {
  static final JiYueRepository singleton = JiYueRepository.internal();

  static const int _pageSize = 20;
  static const bool _filter = true;

  LocalDataSource _localDataSource;
  RemoteDataSource _remoteDataSource;

  factory JiYueRepository() {
    return singleton;
  }

  JiYueRepository.internal() {
    if (_localDataSource == null) {
      _localDataSource = LocalDataSource();
    }
    if (_remoteDataSource == null) {
      _remoteDataSource = RemoteDataSource();
    }
  }

  ///登录
  Future<bool> login(String userName, String password) {
    return _remoteDataSource
        .getAccessToken(userName, password)
        .then((accessToken) {
      _localDataSource.setString(Constants.keyAccessToken, accessToken);
      return _remoteDataSource.getUserInfo(accessToken);
    }).then((user) {
      LogUtils.singleton
          .d("login userName:$userName,password:$password,userId:${user.id}");
      _localDataSource.setBool(Constants.keyIsLogin, true);
      _localDataSource.setString(Constants.keyUserName, userName);
      _localDataSource.setString(Constants.keyPassword, password);
      _localDataSource.setString(Constants.keyUserId, user.id);
      return user.id.isNotEmpty;
    });
  }

  ///获取正在播放列表
  Future<List<StoreSong>> getNowPlayingList(String userId) {
    return _remoteDataSource.getNowPlayingPlaylist(userId);
  }

  ///获取用户信息
  Future<String> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.keyUserId);
  }

  ///点播歌曲
  Future<bool> addToPlaylist(Song song) async {
    return _remoteDataSource.addToPlaylist(song);
  }

  ///移出播放列表
  Future<bool> removeFromPlaylist(String id, String reason) async {
    return _remoteDataSource.removeFromPlaylist(id, reason);
  }

  ///播放歌单
  Future<bool> playFavorite(
      String userId, String favoriteId, bool isRandom) async {
    return _remoteDataSource.playFavorite(userId, favoriteId, isRandom);
  }

  ///获取排行榜
  Future<List<RankingList>> getRankingList() async {
    return _remoteDataSource.getRankingList();
  }

  ///获取指定排行榜详情
  Future<List<Song>> getRankingListDetail(
      String id, String key, String date, int page) async {
    return _remoteDataSource.getRankingListDetail(
        id, key, date, page, _pageSize);
  }

  ///搜索歌曲
  Future<List<Song>> getSongs(String keyword, int page) async {
    return _remoteDataSource.getSongs(keyword, _pageSize, _filter, page);
  }

  ///获取智能提示
  Future<List<String>> getSmartTips(String keyword) {
    return _remoteDataSource.getSmartTips(keyword);
  }

  ///新建歌单
  Future<bool> createFavorite(String name) async {
    return _remoteDataSource.createFavorite(name);
  }

  ///获取所有歌单
  Future<List<Favorite>> getFavoriteList(String sortOrder) async {
    return _remoteDataSource.getFavoriteList(sortOrder);
  }

  ///修改歌单名称
  Future<bool> modifyFavoriteName(String favoriteId, String name) async {
    return _remoteDataSource.modifyFavoriteName(favoriteId, name);
  }

  ///删除歌单
  Future<bool> deleteFavorite(String favoriteId) async {
    return _remoteDataSource.deleteFavorite(favoriteId);
  }

  ///收藏歌曲
  Future<bool> addToFavorite(String favoriteId, Song song) async {
    return _remoteDataSource.addToFavorite(favoriteId, song);
  }

  ///收藏歌曲
  Future<List<FavoriteSong>> getFavoriteSongsByFavoriteId(
      String favoriteId) async {
    return _remoteDataSource.getFavoriteSongsByFavoriteId(favoriteId);
  }

  ///从收藏歌单中删除指定歌曲
  Future<bool> removeFavoriteSong(String id) async {
    return _remoteDataSource.removeFavoriteSong(id);
  }

  Future<String> getString(String key) async {
    return _localDataSource.getString(key);
  }

  setString(String key, String value) async {
    await _localDataSource.setString(key, value);
  }

  Future<bool> getBool(String key) async {
    return _localDataSource.getBool(key);
  }

  setBool(String key, bool value) async {
    _localDataSource.setBool(key, value);
  }
}
