import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/model/Song.dart';
import 'AudioPlayerManager.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({super.key, required this.playingSong, required this.songs});

  final Song playingSong;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(playingSong: playingSong, songs: songs);
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({super.key, required this.playingSong, required this.songs});

  final Song playingSong;
  final List<Song> songs;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimController;
  late AudioPlayerManager _audioPlayerManager;

  late int _currentSongIndex;
  late Song _currentSong;

  late double _currentAnimationPosition;

  @override
  void initState() {
    super.initState();

    _currentSong = widget.playingSong;
    _imageAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 12000));
    _audioPlayerManager = AudioPlayerManager(songUrl: _currentSong.source);
    _audioPlayerManager.init();
    _currentSongIndex = widget.songs.indexOf(widget.playingSong);
    _currentAnimationPosition = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 48;
    final radius = (screenWidth - delta) / 2;

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Now Playing'),
          trailing: IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz)),
        ),
        child: SafeArea(
            child: Scaffold(
          body: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_currentSong.album),
              SizedBox(height: 8),
              Text("_ ___ _"),
              SizedBox(height: 24),
              RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0).animate(_imageAnimController),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets.song_loading.png',
                    image: _currentSong.image,
                    width: screenWidth - delta,
                    height: screenWidth - delta,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset('assets.song_loading.png',
                          width: screenWidth - delta, height: screenWidth - delta);
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 48, bottom: 16),
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.share_outlined),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Column(
                        children: [
                          Text(
                            _currentSong.title,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          SizedBox(height: 16),
                          Text(
                            _currentSong.artist,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.favorite_outline),
                        color: Theme.of(context).colorScheme.primary,
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 16),
                      child: _progressBar(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 16),
                      child: _mediaButtons(),
                    ),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        )));
  }

  @override
  void dispose() {
    _audioPlayerManager.dispose();
    _imageAnimController.dispose();
    super.dispose();
  }

  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
        stream: _audioPlayerManager.durationState,
        builder: (context, snapshot) {
          final durationState = snapshot.data;
          final progress = durationState?.progress ?? Duration.zero;
          final buffered = durationState?.buffered ?? Duration.zero;
          final total = durationState?.total ?? Duration.zero;

          return ProgressBar(
            progress: progress,
            total: total,
            buffered: buffered,
            onSeek: _audioPlayerManager.player.seek,
            barHeight: 5.0,
            barCapShape: BarCapShape.round,
            baseBarColor: Colors.grey.withOpacity(0.3),
            progressBarColor: Theme.of(context).colorScheme.primary,
            bufferedBarColor: Colors.grey.withOpacity(0.3),
            thumbColor: Theme.of(context).colorScheme.primary,
            thumbGlowColor: Colors.lightBlue.withOpacity(0.3),
            thumbRadius: 10.0,
          );
        });
  }

  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder(
        stream: _audioPlayerManager.player.playerStateStream,
        builder: (context, snapshot) {
          final playState = snapshot.data;
          final processingState = playState?.processingState;
          final playing = playState?.playing;

          switch (processingState) {
            case ProcessingState.loading:
            case ProcessingState.buffering:
              return Container(
                margin: EdgeInsets.all(8),
                width: 48,
                height: 48,
                child: CircularProgressIndicator(),
              );
            case ProcessingState.completed:
              _currentAnimationPosition = 0.0;
              _imageAnimController.stop();

              return MediaButtonControl(
                function: () {
                  _currentAnimationPosition = 0.0;
                  _imageAnimController.forward(from: _currentAnimationPosition);
                  _imageAnimController.repeat();
                  _audioPlayerManager.player.seek(Duration.zero);
                },
                icon: Icons.replay,
                color: null,
                size: 48,
              );
            default:
              if (playing != true) {
                return MediaButtonControl(
                  function: () {
                    _audioPlayerManager.player.play();
                    _imageAnimController.forward(from: _currentAnimationPosition);
                    _imageAnimController.repeat();
                  },
                  icon: Icons.play_arrow,
                  color: null,
                  size: 48,
                );
              } else {
                return MediaButtonControl(
                  function: () {
                    _audioPlayerManager.player.pause();
                    _imageAnimController.stop();
                    _currentAnimationPosition = _imageAnimController.value;
                  },
                  icon: Icons.pause,
                  color: null,
                  size: 48,
                );
              }
          }
        });
  }

  void _setNextSong() {
    if (_currentSongIndex < widget.songs.length - 1) {
      _currentSongIndex++;
    } else {
      _currentSongIndex = 0;
    }
    final nextSong = widget.songs[_currentSongIndex];
    _audioPlayerManager.updateSong(nextSong.source);
    setState(() {
      _currentSong = nextSong;
    });
  }

  void _setPreviousSong() {
    if (_currentSongIndex > 0) {
      _currentSongIndex--;
    } else {
      _currentSongIndex = widget.songs.length - 1;
    }
    final nextSong = widget.songs[_currentSongIndex];
    _audioPlayerManager.updateSong(nextSong.source);
    setState(() {
      _currentSong = nextSong;
    });
  }

  Widget _mediaButtons() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(
              function: null, icon: Icons.shuffle, color: Theme.of(context).colorScheme.primary, size: 24),
          MediaButtonControl(
              function: _setPreviousSong,
              icon: Icons.skip_previous,
              color: Theme.of(context).colorScheme.primary,
              size: 36),
          _playButton(),
          MediaButtonControl(
              function: _setNextSong, icon: Icons.skip_next, color: Theme.of(context).colorScheme.primary, size: 36),
          MediaButtonControl(
              function: null, icon: Icons.repeat, color: Theme.of(context).colorScheme.primary, size: 24),
        ],
      ),
    );
  }
}

class MediaButtonControl extends StatefulWidget {
  const MediaButtonControl(
      {super.key, required this.function, required this.icon, required this.color, required this.size});

  final void Function()? function;
  final IconData icon;
  final Color? color;
  final double? size;

  @override
  State<MediaButtonControl> createState() => _MediaButtonControlState();
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
