import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:record/models/track.dart';
import 'package:record/utils/screen_size.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MusicPlayer extends StatefulWidget {
  final Track track;
  const MusicPlayer({super.key, required this.track});

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  final player = AudioPlayer();
  Duration? duration;
  bool isPlaying = false;
  bool _isPageMounted = false;

  @override
  void initState() {
    _isPageMounted = true;
    super.initState();
    fetchAudioDataFromYoutube();
  }

  @override
  void dispose() {
    _isPageMounted = false;
    player.dispose();
    super.dispose();
  }

  Future<void> fetchAudioDataFromYoutube() async {
    if(!_isPageMounted) return; //Constant Checks to see if the player has closed to cancel assynchronous function calls
    try {
      final yt = YoutubeExplode();
      var results = await yt.search.search("${widget.track.name} ${widget.track.artistName} audio");
      final videoYtId = results.first.id;
      if(!_isPageMounted) return;
      var manifest = await yt.videos.streamsClient.getManifest(videoYtId);
      // await player.play(UrlSource(manifest.audio.withHighestBitrate().url.toString()));
      if(!_isPageMounted) return;
      await player.play(UrlSource(manifest.muxed.first.url.toString()));
      if(!_isPageMounted) return;
      setState(() {
        duration = results.first.duration;
        isPlaying = true;
      });
    } catch (e) {
      log("Error fetching audio data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Now Playing", style: Theme.of(context).textTheme.titleMedium,),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: ScreenUtils.screenHeight(context, 5),),
                Image.network(
                  widget.track.trackImageUrl, 
                  fit: BoxFit.cover, width: ScreenUtils.screenWidth(context, 70), height: ScreenUtils.screenWidth(context, 70),
                ),
                SizedBox(height: ScreenUtils.screenHeight(context, 5),),
                Text(widget.track.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w300)),
                SizedBox(height: ScreenUtils.screenHeight(context, 1),),
                Text(widget.track.artistName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.grey.shade600)),
                SizedBox(height: ScreenUtils.screenHeight(context, 8),),

                //progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                   child: StreamBuilder(
                      stream: player.onPositionChanged,
                      builder: (context, data) {
                        return ProgressBar(
                          progress: data.data ?? const Duration(seconds: 0),
                          total: duration ?? const Duration(minutes: 0),
                          onSeek: (duration) {
                            player.seek(duration);
                          },
                        );
                      }
                   ),
                ),

                SizedBox(height: ScreenUtils.screenHeight(context, 2),),

                //Button Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () async {
                          final currentPosition = await player.getCurrentPosition();
                          final newPosition = currentPosition! - const Duration(seconds: 10);
                          await player.seek(newPosition);
                        }, 
                      icon: const Icon(CupertinoIcons.gobackward_10)
                    ),
                    IconButton(
                      onPressed: (){}, 
                      icon: const Icon(Icons.skip_previous_rounded)
                    ),
                    IconButton(
                      onPressed: () async {
                        if (isPlaying) {
                          await player.pause();
                        } else {
                          await player.resume();
                        }
                        setState(() {
                          isPlaying = !isPlaying;
                        });
                      }, 
                      iconSize: 64,
                      icon: Icon(isPlaying ? CupertinoIcons.pause_circle_fill : CupertinoIcons.play_circle_fill),
                    ),
                    IconButton(
                      onPressed: (){}, 
                      icon: const Icon(Icons.skip_next_rounded)
                    ),
                    IconButton(
                        onPressed: () async {
                          final currentPosition = await player.getCurrentPosition();
                          final newPosition = currentPosition! + const Duration(seconds: 10);
                          await player.seek(newPosition);
                        }, 
                        icon: const Icon(CupertinoIcons.goforward_10)
                      ),
                    
                  ],
                )
              ],
            ),
          )
        ),
      )
    );
  }
}