import 'package:flutter/material.dart';
import 'package:jiyue_mobile/data/enities/song.dart';
import 'package:jiyue_mobile/data/source/repository.dart';
import 'package:jiyue_mobile/util/constants.dart';

class JiYueSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
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
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "Search term must be longer than two letters.",
            ),
          )
        ],
      );
    }

    return FutureBuilder(
        future: JiYueRepository.singleton.getSongs(query, 1),
        builder: (context, AsyncSnapshot<List<Song>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('Press button to start.');
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Text('Awaiting result...');
            case ConnectionState.done:
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              return Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.separated(
                      separatorBuilder: (BuildContext context, int index) =>
                          Divider(),
                      itemBuilder: (BuildContext context, int position) {
                        return ListTile(
                          leading: FadeInImage(
                            fit: BoxFit.cover,
                            width: 55,
                            height: 55,
                            placeholder: AssetImage("images/ic_launcher.png"),
                            image: NetworkImage(
                              "${Constants
                                  .aLiEndpoint}api/v1/openmusic/album/${snapshot
                                  .data[position].albumId}/pic",
                            ),
                          ),
                          title: Text(snapshot.data[position].name),
                          subtitle: Text(snapshot.data[position].artistName),
                        );
                      },
                      itemCount:
                      snapshot.data.length <= 0 ? 0 : snapshot.data.length,
                    ),
                  ),
                ],
              );
          }
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length < 1) {
      return Text("");
    }

    return FutureBuilder(
        future: JiYueRepository.singleton.getSmartTips(query),
        builder: (context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            return Text('Result: ${snapshot.data}');
          }
        });
  }
}
