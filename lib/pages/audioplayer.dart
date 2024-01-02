import 'package:demo_music/model/get_music.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerPage extends StatefulWidget {
  const AudioPlayerPage({super.key});

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  List<Music> music = [];
  late AudioPlayer _audioPlayer;
  final playlist = ConcatenatingAudioSource(children: [
    AudioSource.uri(Uri.parse(
        "https://firebasestorage.googleapis.com/v0/b/equalized-audio.appspot.com/o/NewJeans%2FAttention.m4a?alt=media&token=e9119000-9f63-4c39-8661-4b00c579d407")),
    AudioSource.uri(Uri.parse(
        "https://firebasestorage.googleapis.com/v0/b/equalized-audio.appspot.com/o/NewJeans%2FDitto.m4a?alt=media&token=438ef6e6-6509-4505-a92d-a30f70969858")),
    AudioSource.uri(Uri.parse(
        "https://firebasestorage.googleapis.com/v0/b/equalized-audio.appspot.com/o/NewJeans%2FHurt.m4a?alt=media&token=d48989b7-3d7a-4703-b4d7-c0976bd0d2a8")),
  ]);
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
        (position, bufferedPosition, duration) => PositionData(
          position,
          bufferedPosition,
          duration ?? Duration.zero,
        ),
      );
  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    init();
  }

  Future<void> init() async {
    await _audioPlayer.setLoopMode(LoopMode.all);
    await _audioPlayer.setAudioSource(playlist);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 150,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 145,
              // backgroundImage: NetworkImage(music.first.image),
            ),
          ),
          StreamBuilder<PositionData>(
            stream: _positionDataStream,
            builder: (context, snapshot) {
              final positionData = snapshot.data;
              return ProgressBar(
                barHeight: 8,
                baseBarColor: Colors.grey[600],
                bufferedBarColor: Colors.grey,
                progressBarColor: Colors.red,
                thumbColor: Colors.red,
                timeLabelTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                progress: positionData?.position ?? Duration.zero,
                buffered: positionData?.bufferedPosition ?? Duration.zero,
                total: positionData?.duration ?? Duration.zero,
                onSeek: _audioPlayer.seek,
              );
            },
          ),
          const SizedBox(height: 20),
          Controls(audioPlayer: _audioPlayer),
        ],
      ),
    ));
  }
}

class PositionData {
  const PositionData(
    this.position,
    this.bufferedPosition,
    this.duration,
  );
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
}

class Controls extends StatelessWidget {
  const Controls({
    super.key,
    required this.audioPlayer,
  });
  final AudioPlayer audioPlayer;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: audioPlayer.seekToPrevious,
          iconSize: 60,
          color: const Color.fromARGB(255, 0, 0, 0),
          icon: const Icon(Icons.skip_previous_rounded),
        ),
        StreamBuilder<PlayerState>(
            stream: audioPlayer.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing;
              if (!(playing ?? false)) {
                return IconButton(
                  onPressed: audioPlayer.play,
                  iconSize: 80,
                  color: const Color.fromARGB(255, 0, 0, 0),
                  icon: const Icon(Icons.play_arrow_rounded),
                );
              } else if (processingState != ProcessingState.completed) {
                return IconButton(
                  onPressed: audioPlayer.pause,
                  iconSize: 80,
                  color: const Color.fromARGB(255, 0, 0, 0),
                  icon: const Icon(Icons.pause_rounded),
                );
              }
              return const Icon(
                Icons.pause_rounded,
                size: 80,
                color: Color.fromARGB(255, 0, 0, 0),
              );
            }),
        IconButton(
          onPressed: audioPlayer.seekToNext,
          iconSize: 60,
          color: const Color.fromARGB(255, 0, 0, 0),
          icon: const Icon(Icons.skip_next_rounded),
        ),
      ],
    );
  }
}
