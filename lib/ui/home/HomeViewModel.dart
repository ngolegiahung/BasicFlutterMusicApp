import 'dart:async';

import '../../data/model/Song.dart';
import '../../data/repository/SongRepositoryImpl.dart';

class HomeViewModel {
  StreamController<List<Song>> songStreamController = StreamController<List<Song>>();
  final repository = SongRepositoryImpl();

  void loadData() {
    repository.loadData().then((songs) {
      songStreamController.add(songs!);
    });
  }
}
