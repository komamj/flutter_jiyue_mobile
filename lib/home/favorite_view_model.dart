import 'package:flutter/material.dart';
import 'package:jiyue_mobile/data/enities/favorite.dart';
import 'package:jiyue_mobile/data/source/repository.dart';

class FavoriteViewModel with ChangeNotifier {
  final JiYueRepository _repository;

  List _favoriteList = List<Favorite>();

  List get favoriteList => _favoriteList;

  FavoriteViewModel(this._repository);

  void loadFavoriteList() {
    _repository;
  }
}
