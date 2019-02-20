import 'package:jiyue_mobile/data/enities/song.dart';

class StoreSong extends Song {
  //点播标识 ID（非点播项为 null)
  final String demandId;

  //内容项标识 ID
  final String contentId;

  //操作用户标识 ID（加入的用户）
  final String userId;

  StoreSong(
      String songId,
      String name,
      String title,
      int duration,
      String albumId,
      String albumName,
      String artistId,
      String artistName,
      this.demandId,
      this.contentId,
      this.userId)
      : super(songId, name, title, duration, albumId, albumName, artistId,
            artistName);

  StoreSong.fromJson(Map<String, dynamic> json)
      : demandId = json['demandId'],
        contentId = json['id'],
        userId = json['userId'],
        super.fromJson(json);

  @override
  String toString() {
    return "${super.toString()},demandId:$demandId,contentId:$contentId,userId:$userId";
  }
}
