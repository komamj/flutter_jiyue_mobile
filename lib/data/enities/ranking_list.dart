import 'dart:core';

///排行榜
class RankingList {
  final String id;
  final String key;
  final String name;
  final String date;
  final String title;
  final String coverUrl;

  final List<PreItem> preItems;

  RankingList(
      {this.id,
      this.key,
      this.name,
      this.date,
      this.title,
      this.coverUrl,
      this.preItems});

  factory RankingList.fromJson(Map<String, dynamic> json) {
    List<PreItem> preItems = (json['preItems'] as List)
        .map((preItem) => PreItem.fromJson(preItem))
        .toList();
    return RankingList(
        id: json['id'],
        key: json['key'],
        name: json['name'],
        date: json['date'],
        title: json['title'],
        preItems: preItems);
  }
}

class PreItem {
  final String title;
  final String artistName;

  PreItem({this.title, this.artistName});

  factory PreItem.fromJson(Map<String, dynamic> json) {
    return PreItem(title: json['mediaName'], artistName: json['artistName']);
  }
}
