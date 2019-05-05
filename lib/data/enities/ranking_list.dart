import 'dart:core';

///排行榜
class RankingList {
  final int groupId;
  final String groupName;
  final String groupTitle;

  final List<Item> items;

  RankingList({this.groupId, this.groupName, this.groupTitle, this.items});

  factory RankingList.fromJson(Map<String, dynamic> json) {
    List<Item> items =
        (json['items'] as List).map((item) => Item.fromJson(item)).toList();
    return RankingList(
        groupId: json['id'] as int,
        groupName: json['name'] as String,
        groupTitle: json['title'] as String,
        items: items);
  }
}

class Item {
  final int id;
  final String key;
  final String name;
  final String date;
  final String title;
  final String coverUrl;

  final List<PreItem> preItems;

  Item(
      {this.id,
      this.key,
      this.name,
      this.date,
      this.title,
      this.coverUrl,
      this.preItems});

  factory Item.fromJson(Map<String, dynamic> json) {
    List<PreItem> preItems = (json['preItems'] as List)
        .map((preItem) => PreItem.fromJson(preItem))
        .toList();
    return Item(
        id: json['id'] as int,
        key: json['key'] as String,
        name: json['name'] as String,
        date: json['date'] as String,
        title: json['title'] as String,
        coverUrl: json['coverImage'] as String,
        preItems: preItems);
  }
}

class PreItem {
  final String title;
  final String artistName;

  PreItem({this.title, this.artistName});

  factory PreItem.fromJson(Map<String, dynamic> json) {
    return PreItem(
        title: json['mediaName'] as String,
        artistName: json['artistName'] as String);
  }
}
