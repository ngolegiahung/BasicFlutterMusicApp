import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/ui/playing/AudioPlayerManager.dart';

import '../../data/model/Song.dart';
import '../playing/PlayingSong.dart';
import 'HomeViewModel.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  late HomeViewModel viewModel;

  @override
  void initState() {
    viewModel = HomeViewModel();
    viewModel.loadData();

    viewModel.songStreamController.stream.listen((songsList) {
      setState(() {
        songs = songsList;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: getBody());
  }

  @override
  dispose() {
    viewModel.songStreamController.close();
    AudioPlayerManager().dispose();
    super.dispose();
  }

  Widget getBody() {
    if (songs.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return getListSongView();
    }
  }

  ListView getListSongView() {
    return ListView.separated(
      itemBuilder: (context, position) {
        return songItem(position);
      },
      separatorBuilder: (context, position) {
        return Divider(
          color: Colors.grey,
          thickness: 1,
          indent: 24,
          endIndent: 24,
        );
      },
      itemCount: songs.length,
      shrinkWrap: true,
    );
  }

  Widget songItem(int position) {
    return _SongItemSection(song: songs[position], parent: this,);
  }

  void showBottomSheet() {
    showModalBottomSheet(context: context, builder: (context) {
      return ClipRRect(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        child: Container(
          height: 400,
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("data"),
                ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("Close"))
              ],
            ),
          ),
        ),
      );
    });
  }

  void navigateToPlayingSong(Song song) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) => NowPlaying(songs: songs, playingSong: song)));
  }
}

class _SongItemSection extends StatelessWidget {
  const _SongItemSection({
    required this.parent,
    required this.song,
  });

  final _HomeTabPageState parent;
  final Song song;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 24, right: 8),
      title: Text(song.title),
      subtitle: Text(song.artist),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FadeInImage.assetNetwork(
          placeholder: "assets/song_loading.png",
          image: song.image,
          width: 48,
          height: 48,
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset(
              "assets/song_loading.png",
              width: 48,
              height: 48,
            );
          },
        ),
      ),
      trailing: IconButton(icon: Icon(Icons.more_horiz), onPressed: () {
        parent.showBottomSheet();
      }),
      onTap: () {
        parent.navigateToPlayingSong(song);
      },
    );
  }
}
