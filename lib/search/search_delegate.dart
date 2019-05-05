import 'package:flutter/material.dart';
import 'package:jiyue_mobile/data/enities/song.dart';
import 'package:jiyue_mobile/data/source/repository.dart';
import 'package:jiyue_mobile/util/constants.dart';

class JiYueSearchDelegate extends SearchDelegate<String> {
  final List<String> singers = ["黄家驹", "谭咏麟", "张国荣", "邓紫棋", "周杰伦"];

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';

          showSuggestions(context);
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 1) {
      return Center(
        child: Text(
          "没有相关音乐。",
        ),
      );
    }

    return FutureBuilder(
        future: JiYueRepository.singleton.getSongs(query, 1),
        builder: (context, AsyncSnapshot<List<Song>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(
                child: const CircularProgressIndicator(),
              );
            case ConnectionState.done:
              if (snapshot.hasError) {
                return const Text('没有相关音乐。');
              } else {
                return Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView.separated(
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(),
                        itemBuilder: (BuildContext context, int position) {
                          final Song song = snapshot.data[position];
                          return ListTile(
                            leading: FadeInImage(
                              fit: BoxFit.cover,
                              width: 55,
                              height: 55,
                              placeholder: AssetImage("images/ic_launcher.png"),
                              image: NetworkImage(
                                "${Constants.baseUrl}openmusic/album/${song.albumId}/pic",
                              ),
                            ),
                            title: Text(
                              song.name,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              song.artistName,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.more_vert),
                              onSelected: (item) {
                                _onPopMenuClick(item, song);
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                    PopupMenuItem<String>(
                                      value: '',
                                      child: const ListTile(
                                        leading: Icon(Icons.playlist_add),
                                        title: Text('点播'),
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: '',
                                      child: const ListTile(
                                        leading: Icon(Icons.favorite),
                                        title: Text('收藏'),
                                      ),
                                    )
                                  ],
                            ),
                          );
                        },
                        itemCount: snapshot.data.length <= 0
                            ? 0
                            : snapshot.data.length,
                      ),
                    ),
                  ],
                );
              }
          }
        });
  }

  void _onPopMenuClick(String item, Song song) {}

  @override
  Widget buildSuggestions(BuildContext context) {
    return Text("");
    /*if (query.length < 1) {
      return ListView.separated(
          separatorBuilder: (BuildContext context, int index) => Divider(),
          itemBuilder: (BuildContext context, int position) {
            final String singer = singers[position];
            return ListTile(
              title: Text(singer),
              onTap: () {
                query = singer;
                showResults(context);
              },
            );
          },
          itemCount: singers.length);
    } else {
      return FutureBuilder(
          future: JiYueRepository.singleton.getSmartTips(query),
          builder: (context, AsyncSnapshot<List<String>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              return Text('Result: ${snapshot.data}');
            }
          });
    }*/
  }
}
