class Song {
  final String songId;
  final String name;
  final int duration;
  final String albumId;
  final String albumName;
  final String artistId;
  final String artistName;

  Song(
      {this.songId,
      this.name,
      this.duration,
      this.albumId,
      this.albumName,
      this.artistId,
      this.artistName});

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
        songId: json['mediaId'],
        name: json['mediaName'],
        duration: json['mediaInterval'],
        albumId: json['albumId'],
        albumName: json['albumName'],
        artistId: json['artistId'],
        artistName: json['artistName']);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'mediaId': songId,
        'mediaName': name,
        'mediaInterval': duration,
        'albumId': albumId,
        'albumName': albumName,
        'artistId': artistId,
        'artistName': artistName
      };

  @override
  String toString() {
    return "song has songId:$songId,name:$name,duration:$duration,albumId:$albumId,albumName:$albumName,artistId:$artistId,artistName:$artistName";
  }
}
