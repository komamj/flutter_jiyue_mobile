import 'dart:core';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:jiyue_mobile/data/enities/User.dart';
import 'package:jiyue_mobile/data/enities/favorite.dart';
import 'package:jiyue_mobile/data/enities/favorite_song.dart';
import 'package:jiyue_mobile/data/enities/ranking_list.dart';
import 'package:jiyue_mobile/data/enities/song.dart';
import 'package:jiyue_mobile/data/enities/store_song.dart';
import 'package:jiyue_mobile/data/enities/token.dart';
import 'package:jiyue_mobile/util/constants.dart';
import 'package:jiyue_mobile/util/log_utlis.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemoteDataSource {
  Dio _client;

  RemoteDataSource() {
    _client = Dio();
    _client.options.baseUrl = Constants.baseUrl;
    _client.options.receiveTimeout = 1000 * 10; //10秒
    _client.options.connectTimeout = 5000; //10秒
    (_client.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };
    _client.interceptors
        .add(InterceptorsWrapper(onError: (DioError error) async {
      if (error.response != null &&
          error.response.statusCode == HttpStatus.unauthorized) {
        Dio dio = Dio();
        dio.interceptors
            .add(LogInterceptor(requestBody: true, responseBody: true));
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (!prefs.getBool(Constants.keyIsLogin)) {
          return;
        }
        _client.lock();
        String userName = prefs.getString(Constants.keyUserName);
        String password = prefs.getString(Constants.keyPassword);

        LogUtils.singleton
            .d("invalid token userName:$userName,password:$password");

        FormData formData = new FormData.from({
          "username": userName,
          "password": password,
          "grant_type": Constants.grantType,
          "client_id": Constants.clientId,
          "client_secret": Constants.clientSecret
        });

        Response response = await dio
            .post("${Constants.aLiEndpoint}oauth/token", data: formData);
        if (response.statusCode == HttpStatus.ok) {
          if (response.data[Constants.keyAccessToken] != null) {
            Token token = Token.fromJson(response.data);
            await prefs.setString(Constants.keyAccessToken, token.accessToken);
          }
        }
        _client.unlock();

        RequestOptions request = error.response.request;
        request.headers = {
          "Authorization": "Bearer ${prefs.getString(Constants.keyAccessToken)}"
        };
        await _client.request(request.path,
            data: request.data,
            queryParameters: request.queryParameters,
            cancelToken: request.cancelToken,
            options: request,
            onReceiveProgress: request.onReceiveProgress);
      }
    }));
    _client.interceptors
        .add(LogInterceptor(requestBody: true, responseBody: true));
    _initHeaders();
  }

  void _initHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString(Constants.keyAccessToken);
    if (accessToken != null && accessToken.isNotEmpty) {
      _client.options.headers = {"Authorization": "Bearer $accessToken"};
    }
  }

  ///获取access_token
  Future<String> getAccessToken(String userName, String password) async {
    FormData formData = new FormData.from({
      "username": userName,
      "password": password,
      "grant_type": Constants.grantType,
      "client_id": Constants.clientId,
      "client_secret": Constants.clientSecret
    });

    Token token;
    Response response = await _client
        .post("${Constants.aLiEndpoint}oauth/token", data: formData);
    if (response.statusCode == HttpStatus.ok) {
      if (response.data[Constants.keyAccessToken] != null) {
        token = Token.fromJson(response.data);
        return token.accessToken;
      }
    }
    return "";
  }

  ///获取当前店主信息
  Future<User> getUserInfo(String accessToken) async {
    //add headers
    _client.options.headers = {"Authorization": "Bearer $accessToken"};
    User user;
    Response response = await _client.get("user/stores");
    if (response.statusCode == HttpStatus.ok) {
      if (response.data['code'] == 0) {
        List<dynamic> result = await response.data['data'];
        user = User.fromJson(result[0]);
      }
    }
    return user;
  }

  ///获取播放列表
  Future<List<StoreSong>> getNowPlayingPlaylist(String userId) async {
    List storeSongs = List<StoreSong>();
    Response response = await _client.get("storeplaylist/$userId");
    if (response.statusCode == HttpStatus.ok) {
      if (response.data['code'] == 0) {
        List<dynamic> result = await response.data['data'];
        result.forEach((f) {
          storeSongs.add(StoreSong.fromJson(f));
        });
      }
    }
    return storeSongs;
  }

  ///点播歌曲
  Future<bool> addToPlaylist(Song song) async {
    bool result = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storeId = prefs.getString(Constants.keyUserId);
    Response response = await _client.post("storeplaylist", data: {
      'storeId': storeId,
      'mediaId': song.songId,
      'mediaName': song.name,
      'mediaInterval': song.duration,
      'artistId': song.artistId,
      'artistName': song.artistName,
      'albumId': song.albumId,
      'albumName': song.albumName
    });
    if (response.statusCode == HttpStatus.ok) {
      if (response.data['code'] == 0) {
        result = true;
      }
    }
    return result;
  }

  ///移出播放列表
  Future<bool> removeFromPlaylist(String id, String reason) async {
    bool result = false;
    FormData formData = new FormData.from({"reason": reason});
    Response response = await _client.post("storeplaylist/$id", data: formData);
    if (response.statusCode == HttpStatus.ok) {
      if (response.data['code'] == 0) {
        result = true;
      }
    }
    return result;
  }

  ///播放歌单
  Future<bool> playFavorite(
      String userId, String favoriteId, bool isRandom) async {
    bool result = false;
    FormData formData =
        new FormData.from({"favoritesId": favoriteId, 'random': isRandom});
    Response response =
        await _client.post("storeplaylist/$userId/playfav", data: formData);
    if (response.statusCode == HttpStatus.ok) {
      if (response.data['code'] == 0) {
        result = true;
      }
    }
    return result;
  }

  ///获取排行榜
  Future<List<RankingList>> getRankingList() async {
    List rankingLists = List<RankingList>();
    Response response = await _client.get("openmusic/toplist");
    if (response.statusCode == HttpStatus.ok) {
      if (response.data['code'] == 0) {
        List<dynamic> result = await response.data['data']['items'];
        result.forEach((f) {
          rankingLists.add(RankingList.fromJson(f));
        });
      }
    }
    return rankingLists;
  }

  ///获取指定排行榜详情
  Future<List<Song>> getRankingListDetail(
      String id, String key, String date, int pageNumber, int pageSize) async {
    List songs = List<Song>();
    Response response = await _client.get("openmusic/toplist/$id",
        queryParameters: {'k': key, 'd': date, 'p': pageNumber, 'n': pageSize});
    if (response.statusCode == HttpStatus.ok) {
      if (response.data['code'] == 0) {
        List<dynamic> result = await response.data['data']['items'];
        result.forEach((f) {
          songs.add(Song.fromJson(f));
        });
      }
    }
    return songs;
  }

  ///搜索单曲
  Future<List<Song>> getSongs(
      String keyword, int pageSize, bool filter, int page) async {
    List songs = List<Song>();
    Response response = await _client.get("openmusic/search",
        queryParameters: {"w": keyword, "n": pageSize, "f": filter, "p": page});
    if (response.statusCode == HttpStatus.ok) {
      if (response.data['code'] == 0) {
        List<dynamic> result = await response.data['data']['items'];
        result.forEach((f) {
          songs.add(Song.fromJson(f));
        });
      }
    }
    return songs;
  }

  ///智能提示
  Future<List<String>> getSmartTips(String keyword) async {
    List smartTips = List<String>();
    Response response = await _client
        .get("openmusic/smartbox", queryParameters: {"k": keyword});
    if (response.statusCode == HttpStatus.ok) {
      if (response.data['code'] == 0) {
        List<dynamic> result = await response.data['data']['song']['itemlist'];
        result.forEach((f) {
          smartTips.add(Song.fromJson(f));
        });
      }
    }
    return smartTips;
  }

  ///新建歌单
  Future<bool> createFavorite(String name) async {
    bool result = false;
    FormData formData = new FormData.from({"name": name});
    Response response = await _client.post("favorites", data: formData);
    if (response.statusCode == HttpStatus.ok) {
      if (response.data['code'] == 0) {
        result = true;
      }
    }
    return result;
  }

  ///获取所有歌单
  Future<List<Favorite>> getFavoriteList(String sortOrder) async {
    List favorites = List<Favorite>();
    Response response =
        await _client.get("favorites/my", queryParameters: {'sort': sortOrder});
    if (response.statusCode == HttpStatus.ok) {
      if (response.data['code'] == 0) {
        List<dynamic> result = await response.data['data'];
        result.forEach((f) {
          favorites.add(Favorite.fromJson(f));
        });
      }
    }
    return favorites;
  }

  ///修改歌单名称
  Future<bool> modifyFavoriteName(String favoriteId, String name) async {
    bool result = false;
    FormData formData = new FormData.from({'id': favoriteId, "name": name});
    Response response = await _client.patch("favorites", data: formData);
    if (response.statusCode == HttpStatus.ok) {
      if (response.data['code'] == 0) {
        result = true;
      }
    }
    return result;
  }

  ///删除歌单
  Future<bool> deleteFavorite(String favoriteId) async {
    bool result = false;
    Response response = await _client.delete("favorites/$favoriteId");
    if (response.statusCode == HttpStatus.ok) {
      if (response.data['code'] == 0) {
        result = true;
      }
    }
    return result;
  }

  ///收藏歌曲
  Future<bool> addToFavorite(String favoriteId, Song song) async {
    bool result = false;
    Response response =
        await _client.post("favorites/$favoriteId/items", data: {
      'favoritesId': favoriteId,
      'mediaId': song.songId,
      'mediaName': song.name,
      'mediaInterval': song.duration,
      'artistId': song.artistId,
      'artistName': song.artistName,
      'albumId': song.albumId,
      'albumName': song.albumName
    });
    if (response.statusCode == HttpStatus.ok) {
      if (response.data['code'] == 0) {
        result = true;
      }
    }
    return result;
  }

  ///收藏歌曲
  Future<List<FavoriteSong>> getFavoriteSongsByFavoriteId(
      String favoriteId) async {
    List favoriteSongs = List<FavoriteSong>();
    Response response = await _client.get("favorites/$favoriteId/items");
    if (response.statusCode == HttpStatus.ok) {
      if (response.data['code'] == 0) {
        List<dynamic> result = await response.data['data'];
        result.forEach((f) {
          favoriteSongs.add(FavoriteSong.fromJson(f));
        });
      }
    }
    return favoriteSongs;
  }

  ///从收藏歌单中删除指定歌曲
  Future<bool> removeFavoriteSong(String id) async {
    bool result = false;
    Response response = await _client.delete("favorites/items/$id");
    if (response.statusCode == HttpStatus.ok) {
      if (response.data['code'] == 0) {
        result = true;
      }
    }
    return result;
  }

  ///反馈
  Future<bool> feedback(String title, String content) async {
    bool result = false;
    Response response = await _client
        .post("feedback", data: {'title': title, 'content': content});
    if (response.statusCode == HttpStatus.ok) {
      if (response.data['code'] == 0) {
        result = true;
      }
    }
    return result;
  }
}
