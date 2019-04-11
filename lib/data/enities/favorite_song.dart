import 'package:jiyue_mobile/data/enities/song.dart';

class FavoriteSong extends Song {
  ///收藏项标识 ID
  final String id;

  FavoriteSong({
    this.id,
    String songId,
    String name,
    int duration,
    String albumId,
    String albumName,
    String artistId,
    String artistName,
  }) : super(
            songId: songId,
            name: name,
            duration: duration,
            albumId: albumId,
            albumName: albumName,
            artistId: artistId,
            artistName: artistName);

  factory FavoriteSong.fromJson(Map<String, dynamic> json) {
    return FavoriteSong(
        id: json['id'],
        songId: json['mediaId'],
        name: json['mediaName'],
        duration: json['mediaInterval'],
        albumId: json['albumId'],
        albumName: json['albumName'],
        artistId: json['artistId'],
        artistName: json['artistName']);
  }
}
