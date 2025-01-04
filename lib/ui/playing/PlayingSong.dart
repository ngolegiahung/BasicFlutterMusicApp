import 'dart:math';

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
  bool _isShuffle = false;
  late LoopMode _loopMode = LoopMode.off;

  @override
  void initState() {
    super.initState();

    _currentSong = widget.playingSong;
    _imageAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 12000));
    _audioPlayerManager = AudioPlayerManager();

    if(_audioPlayerManager.songUrl.compareTo(_currentSong.source) != 0) {
      _audioPlayerManager.updateSong(_currentSong.source);
      _audioPlayerManager.prepare(isNewSong: true);
    } else {
      _audioPlayerManager.prepare(isNewSong: false);
    }

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
              _pauseRotationAnimation();
              return Container(
                margin: EdgeInsets.all(8),
                width: 48,
                height: 48,
                child: CircularProgressIndicator(),
              );
            case ProcessingState.completed:
              _stopRotationAnimation();
              _resetRotationAnimation();

              return MediaButtonControl(
                function: () {
                  _audioPlayerManager.player.seek(Duration.zero);
                  _resetRotationAnimation();
                },
                icon: Icons.replay,
                color: null,
                size: 48,
              );
            default:
              if (playing != true) {
                return MediaButtonControl(
                  function: _audioPlayerManager.player.play,
                  icon: Icons.play_arrow,
                  color: null,
                  size: 48,
                );
              } else {
                _playRotationAnimation();
                return MediaButtonControl(
                  function: () {
                    _audioPlayerManager.player.pause();
                    _pauseRotationAnimation();
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
    if(_isShuffle) {
      _currentSongIndex = Random().nextInt(widget.songs.length);
    } else if(_currentSongIndex < widget.songs.length -1) {
      _currentSongIndex++;
    } else if(_loopMode == LoopMode.all && _currentSongIndex == widget.songs.length -1) {
      _currentSongIndex = 0;
    }

    if (_currentSongIndex >= widget.songs.length) {
      _currentSongIndex = _currentSongIndex % widget.songs.length;
    }

    final nextSong = widget.songs[_currentSongIndex];
    _audioPlayerManager.updateSong(nextSong.source);
    setState(() {
      _currentSong = nextSong;
    });

    _resetRotationAnimation();
  }

  void _setPreviousSong() {
    if(_isShuffle) {
      _currentSongIndex = Random().nextInt(widget.songs.length);
    } else if(_currentSongIndex > 0) {
      _currentSongIndex--;
    } else if(_loopMode == LoopMode.all && _currentSongIndex == 0) {
      _currentSongIndex = widget.songs.length - 1;
    }

    if (_currentSongIndex < 0) {
      _currentSongIndex = (_currentSongIndex % widget.songs.length).abs();
    }

    final nextSong = widget.songs[_currentSongIndex];
    _audioPlayerManager.updateSong(nextSong.source);
    setState(() {
      _currentSong = nextSong;
    });

    _resetRotationAnimation();
  }

  void _playRotationAnimation() {
    _imageAnimController.forward(from: _currentAnimationPosition);
    _imageAnimController.repeat();
  }

  void _pauseRotationAnimation() {
    _currentAnimationPosition = _imageAnimController.value;
    _stopRotationAnimation();
  }

  void _stopRotationAnimation() {
    _imageAnimController.stop();
  }

  void _resetRotationAnimation() {
    _currentAnimationPosition = 0.0;
    _imageAnimController.value = _currentAnimationPosition;
  }

  void _setShuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
    });
  }

  Color? _getShuffleColor() {
    return _isShuffle ? Theme.of(context).colorScheme.primary : Colors.grey;
  }

  IconData _repeatingIcon() {
    return switch(_loopMode) {
      LoopMode.off => Icons.repeat,
      LoopMode.one => Icons.repeat_one,
      LoopMode.all => Icons.repeat_on,
    };
  }

  Color? _getRepeatingIconColor() {
    return _loopMode != LoopMode.off ? Theme.of(context).colorScheme.primary : Colors.grey;
  }

  void _setRepeatOption() {
    switch(_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        _loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode = LoopMode.off;
        break;
    }

    setState(() {
      _audioPlayerManager.player.setLoopMode(_loopMode);
    });
  }

  Widget _mediaButtons() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(function: _setShuffle, icon: Icons.shuffle, color: _getShuffleColor(), size: 24),
          MediaButtonControl(function: _setPreviousSong, icon: Icons.skip_previous, color: Theme.of(context).colorScheme.primary, size: 36),
          _playButton(),
          MediaButtonControl(function: _setNextSong, icon: Icons.skip_next, color: Theme.of(context).colorScheme.primary, size: 36),
          MediaButtonControl(function: _setRepeatOption, icon: _repeatingIcon(), color: _getRepeatingIconColor(), size: 24),
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
