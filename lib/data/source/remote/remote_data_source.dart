import 'dart:io';

import 'package:dio/dio.dart';
import 'package:jiyue_mobile/data/enities/User.dart';
import 'package:jiyue_mobile/data/enities/song.dart';
import 'package:jiyue_mobile/data/enities/store_song.dart';
import 'package:jiyue_mobile/data/enities/token.dart';
import 'package:jiyue_mobile/util/constants.dart';
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
        .add(LogInterceptor(requestBody: true, responseBody: true));
    _client.interceptors
        .add(InterceptorsWrapper(onError: (DioError error) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (error.response != null &&
          error.response.statusCode == HttpStatus.unauthorized &&
          prefs.getBool(Constants.keyIsLogin)) {
        _client.lock();
        String userName = prefs.getString(Constants.userName);
        String password = prefs.getString(Constants.password);

        FormData formData = new FormData.from({
          "username": userName,
          "password": password,
          "grant_type": Constants.grantType,
          "client_id": Constants.clientId,
          "client_secret": Constants.clientSecret
        });

        Response response = await _client
            .post("${Constants.aLiEndpoint}oauth/token", data: formData);
        if (response.statusCode == HttpStatus.ok) {
          if (response.data[Constants.keyAccessToken] != null) {
            Token token = Token.fromJson(response.data);
            await prefs.setString(Constants.keyAccessToken, token.accessToken);
          }
        }
        _initHeaders();
        _client.unlock();

        RequestOptions request = error.response.request; //千万不要调用 err.request
        await _client.request(request.path,
            data: request.data,
            queryParameters: request.queryParameters,
            cancelToken: request.cancelToken,
            options: request,
            onReceiveProgress: request.onReceiveProgress);
      }
    }));
    _initHeaders();
  }

  void _initHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString(Constants.keyAccessToken);
    if (accessToken != null && accessToken.isNotEmpty) {
      _client.options.headers = {"Authorization": "Bearer $accessToken"};
    }
  }

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

  Future<List<String>> getSuggestions(String keyword) async {
    List suggestions = List<String>();
    Response response = await _client
        .get("openmusic/smartbox", queryParameters: {"k": keyword});
    if (response.statusCode == HttpStatus.ok) {
      if (response.data['code'] == 0) {
        List<dynamic> result = await response.data['data']['items'];
        result.forEach((f) {});
      }
    }
    return suggestions;
  }

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

  Future<List<String>> getSmartTips(String keyword) async {
    List smartTips = List<String>();
    Response response = await _client
        .get("openmusic/smartbox", queryParameters: {"w": keyword});
    if (response.statusCode == HttpStatus.ok) {
      if (response.data['code'] == 0) {
        List<dynamic> result = await response.data['data']['items'];
        result.forEach((f) {
          smartTips.add(Song.fromJson(f));
        });
      }
    }
    return smartTips;
  }
}
