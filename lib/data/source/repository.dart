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

  Future<List<StoreSong>> getNowPlayingList(String userId) {
    return _remoteDataSource.getNowPlayingPlaylist(userId);
  }

  Future<String> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.keyUserId);
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

  Future<List<Song>> getSongs(String keyword, int page) async {
    return _remoteDataSource.getSongs(keyword, _pageSize, _filter, page);
  }

  Future<List<String>> getSmartTips(String keyword) {
    return _remoteDataSource.getSmartTips(keyword);
  }
}
