import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:music_app/data/model/Song.dart';
import 'package:music_app/data/source/Source.dart';

class LocalDataSource implements DataSource {

  @override
  Future<List<Song>?> loadData() async {
    debugPrint("Load data from local");

    final String response = await rootBundle.loadString('assets/songs.json');
    final jsonBody = jsonDecode(response) as Map;
    final songList = jsonBody['songs'].map<Song>((song) => Song.fromJson(song)).toList();
    return songList;
  }
}
