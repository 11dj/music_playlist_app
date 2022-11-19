import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:just_audio/just_audio.dart';
// import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:flutter/services.dart';
import 'package:music_playlist_app/models/song_model.dart';

enum StreamStatus { play, pause }

class MyPlayiistPage extends StatefulWidget {
  const MyPlayiistPage({super.key});

  @override
  State<MyPlayiistPage> createState() => _MyPlayiistPageState();
}

class _MyPlayiistPageState extends State<MyPlayiistPage> {
  final player = AudioPlayer();
  List<SongModel> playlist = [];
  SongModel selectSong = SongModel();
  Duration? durationSelectedSong;
  Duration? currentDuration;
  StreamStatus status = StreamStatus.pause;

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  _initialize() async {
    await readJson();
    listen1();
  }

  listen1() {
    player.playerStateStream.listen((PlayerState state) {
      if (state.playing) {
        player.positionStream.listen((Duration? duration) {
          setState(() {
            currentDuration = duration;
          });
          if (currentDuration == durationSelectedSong) nextSong();
        });
        setState(() => status = StreamStatus.play);
      } else {
        setState(() => status = StreamStatus.pause);
      }
    });
  }

  nextSong() {
    final idx = playlist.indexWhere((SongModel el) => el == selectSong);
    if (idx < playlist.length - 1) {
      SongModel next = playlist[idx + 1];
      play(next);
    } else {
      SongModel next = playlist.first;
      play(next);
    }
  }

  readJson() async {
    final String response = await rootBundle.loadString('assets/data.json');
    List data = await json.decode(response);
    final d = data.map((e) => SongModel.fromMap(e)).toList();
    setState(() {
      playlist = d;
    });
  }

  play(SongModel s) async {
    if (selectSong.filename != s.filename) {
      Duration? d = await player.setAsset('assets/audios/${s.filename}.mp3');
      player.play();
      setState(() {
        durationSelectedSong = d;
        selectSong = s;
      });
    } else {
      player.play();
    }
  }

  stop() {
    player.pause();
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  String _printDiffDuration(Duration d, Duration curr) {
    final aa = d.inSeconds - curr.inSeconds;
    Duration dx = Duration(seconds: aa);
    return "-${_printDuration(dx)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 32.0),
                width: double.infinity,
                child: const Text(
                  'My Playlist',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    ListView.builder(
                      itemCount: playlist.length,
                      itemBuilder: (context, index) {
                        SongModel song = playlist[index];
                        return ListTile(
                          leading: Image.asset(
                            'assets/artworks/${song.filename}.png',
                            width: 50,
                          ),
                          title: Text(song.trackname!,
                              style: const TextStyle(
                                fontSize: 20,
                              )),
                          subtitle: Text(song.artist!),
                          trailing: IconButton(
                              onPressed: () => play(song),
                              icon: Icon(
                                Icons.play_circle_outline,
                                size: 28,
                                color: selectSong == song
                                    ? Colors.green
                                    : Colors.grey[400],
                              )),
                        );
                      },
                    ),
                    if (selectSong.filename != null)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  color: Colors.grey[300],
                                  height: 8,
                                  width: MediaQuery.of(context).size.width,
                                ),
                                Container(
                                  color: Colors.orange,
                                  height: 8,
                                  width: MediaQuery.of(context).size.width *
                                      (currentDuration!.inMilliseconds /
                                          durationSelectedSong!.inMilliseconds),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_printDuration(currentDuration!)),
                                  Text(_printDiffDuration(
                                      durationSelectedSong!, currentDuration!)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 4),
                              height: 100,
                              width: double.infinity,
                              child: ListTile(
                                leading: Image.asset(
                                  'assets/artworks/${selectSong.filename}.png',
                                  width: 50,
                                ),
                                title: Text(selectSong.trackname!,
                                    style: const TextStyle(
                                      fontSize: 20,
                                    )),
                                subtitle: Text(selectSong.artist!),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        onPressed: () =>
                                            status == StreamStatus.pause
                                                ? play(selectSong)
                                                : stop(),
                                        icon: Icon(
                                          status == StreamStatus.pause
                                              ? Icons.play_arrow
                                              : Icons.pause,
                                          size: 40,
                                        )),
                                    IconButton(
                                        onPressed: () => nextSong(),
                                        icon: const Icon(
                                          Icons.skip_next_rounded,
                                          size: 40,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
