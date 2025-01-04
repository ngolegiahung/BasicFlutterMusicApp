import '../model/Song.dart';

abstract interface class SongRepository {
  Future<List<Song>?> loadData();
}
