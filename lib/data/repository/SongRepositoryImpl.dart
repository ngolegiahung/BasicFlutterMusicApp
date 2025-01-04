import 'package:music_app/data/repository/SongRepository.dart';
import 'package:music_app/data/source/LocalDataSource.dart';

import '../model/Song.dart';
import '../source/RemoteDataSource.dart';

class SongRepositoryImpl implements SongRepository {
  final localDataSource = LocalDataSource();
  final remoteDataSource = RemoteDataSource();

  @override
  Future<List<Song>?> loadData() async {
    List<Song> songs = [];
    await remoteDataSource.loadData().then((remoteSongs) async {
      if (remoteSongs == null) {
        await localDataSource.loadData().then((localSongs) {
          if (localSongs != null) {
            songs = localSongs;
          }
        });
      } else {
        songs = remoteSongs;
      }
    });
    return songs;
  }
}
