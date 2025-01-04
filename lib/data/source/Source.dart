import '../model/Song.dart';

abstract interface class DataSource {
  Future<List<Song>?> loadData();
}