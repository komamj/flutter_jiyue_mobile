class Favorite {
  final String id;
  final String name;
  final bool isDefault;
  final String userId;
  final String coverUrl;
  final int count;
  final String createTime;
  final String modifyTime;

  Favorite(
      {this.id,
      this.name,
      this.isDefault,
      this.userId,
      this.coverUrl,
      this.count,
      this.createTime,
      this.modifyTime});

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
        id: json['id'],
        name: json['name'],
        isDefault: json['def'],
        userId: json['userId'],
        coverUrl: json['coverImage'],
        count: json['itemCount'],
        createTime: json['createDate'],
        modifyTime: json['modifyDate']);
  }
}
