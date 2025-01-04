import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:music_app/data/model/Song.dart';
import 'package:music_app/data/source/Source.dart';
import 'package:http/http.dart' as http;

class RemoteDataSource implements DataSource {
  static const url = "https://thantrieu.com/resources/braniumapis/songs.json";

  @override
  Future<List<Song>?> loadData() async {
    debugPrint('Load data from remote');

    final uri = Uri.parse(url);

    final response = await http.get(uri);

    if(response.statusCode == 200) {
      final bodyContent = utf8.decode(response.bodyBytes);
      var songWrapper = jsonDecode(bodyContent) as Map;

      final List<Song> songs = songWrapper['songs'].map<Song>((song) => Song.fromJson(song)).toList();
      return songs;
    } else {
      debugPrint('Load data from remote - Failed');

      return null;
    }
  }
}
