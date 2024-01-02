import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:demo_music/model/get_music.dart';
import 'package:demo_music/pages/audioplayer.dart';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
// import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  // final audioPlayer = AudioPlayer();
  late AudioPlayer player;
    final playlist = ConcatenatingAudioSource(children: [
    AudioSource.uri(Uri.parse(
        "https://firebasestorage.googleapis.com/v0/b/equalized-audio.appspot.com/o/NewJeans%2FAttention.m4a?alt=media&token=e9119000-9f63-4c39-8661-4b00c579d407")),
    AudioSource.uri(Uri.parse(
        "https://firebasestorage.googleapis.com/v0/b/equalized-audio.appspot.com/o/NewJeans%2FDitto.m4a?alt=media&token=438ef6e6-6509-4505-a92d-a30f70969858")),
    AudioSource.uri(Uri.parse(
        "https://firebasestorage.googleapis.com/v0/b/equalized-audio.appspot.com/o/NewJeans%2FHurt.m4a?alt=media&token=d48989b7-3d7a-4703-b4d7-c0976bd0d2a8")),
  ]);
  bool isPlaying = false;
  List<Music> music = [];
    Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        player.positionStream,
        player.bufferedPositionStream,
        player.durationStream,
        (position, bufferedPosition, duration) => PositionData(
          position,
          bufferedPosition,
          duration ?? Duration.zero,
        ),
      );
  // Future<Map<String, dynamic>> fetchData() async {
  //   final response = await http.get(Uri.parse(
  //       'https://firebasestorage.googleapis.com/v0/b/equalized-audio.appspot.com/o/Json%2Fdata.json?alt=media&token=05529c81-cedc-4b35-9f15-977fad635376'));

  //   if (response.statusCode == 200) {
  //     // แปลง JSON เป็น Map
  //     log("Success");
  //     return jsonDecode(response.body);
  //   } else {
  //     // หากไม่สำเร็จ, สามารถจัดการข้อผิดพลาดได้ตามต้องการ
  //     log("Error");
  //     throw Exception('Failed to load data');
  //   }
  // }

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    init();
  }

  Future<void> init() async {
    await player.setLoopMode(LoopMode.all);
    await player.setAudioSource(playlist);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.rotate(
                angle: isPlaying ? 0.0 : 0.0, // หมุนมุมที่ต้องการ
                child: const CircleAvatar(
                  radius: 150,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 145,
                    backgroundImage: NetworkImage(
                        "https://hips.hearstapps.com/hmg-prod/images/nj-6405bce93a0bb.jpg?crop=0.499xw:0.997xh;0,0.00327xh&resize=1200:*"),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: StreamBuilder<PositionData>(
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
                      onSeek: player.seek,
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .center, // Align icons in the center horizontally
                children: [
                  IconButton(
                    onPressed: player.seekToPrevious,
                    icon: const Icon(
                      Icons.skip_previous,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      iconSize: 50,
                      onPressed: () async {
                        setState(() {
                          isPlaying = !isPlaying;
                        });
                        if (isPlaying) {
                          await player.play();
                        } else {
                          await player.pause();
                        }
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: player.seekToNext,
                    icon: const Icon(
                      Icons.skip_next,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
