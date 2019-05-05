class Favorite {
  final String id;
  final String name;
  final bool isDefault;
  final String userId;
  final String coverUrl;
  final int count;
  final String createTime;

  Favorite(
      {this.id,
      this.name,
      this.isDefault,
      this.userId,
      this.coverUrl,
      this.count,
      this.createTime});

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
        id: json['id'] as String,
        name: json['name'] as String,
        isDefault: json['def'] as bool,
        userId: json['userId'] as String,
        coverUrl: json['coverImage'] as String,
        count: json['itemCount'] as int,
        createTime: json['createDate'] as String);
  }
}
