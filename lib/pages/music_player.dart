import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:record/models/album.dart';
import 'package:record/models/track.dart';
import 'package:record/pages/artist_showcase_page.dart';
import 'package:record/services/spotify_services.dart';
import 'package:record/utils/screen_size.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// ignore: must_be_immutable
class MusicPlayer extends StatefulWidget {
  final Track track;
  int currSongIndex;
  final bool isAlbum;
  final SpotifyService spotifyService;
  final List<AlbumTrack>? albumTrackList;
  final Album? album;

  MusicPlayer({
    super.key, 
    required this.track, 
    required this.currSongIndex,
    required this.isAlbum,
    required this.spotifyService,
    this.albumTrackList,
    this.album
  });

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  final player = AudioPlayer();
  Duration? duration;
  bool isPlaying = false;
  bool _isPageMounted = false;
  List<MusicPlayerTrackList> _tracks = [];

  @override
  void initState() {
    _isPageMounted = true;
    super.initState();
    widget.isAlbum ? fetchAlbumList() : fetchRecommendedList();
    fetchAudioDataFromYoutube(widget.track.name, widget.track.artistName);

    //Play next song when curernt song completes
    player.onPlayerComplete.listen((event) {
      playNextTrack();
    });
  }

  @override
  void dispose() {
    _isPageMounted = false;
    player.dispose();
    super.dispose();
  }

  Future<void> fetchAudioDataFromYoutube(String trackName, String artistName) async {
    if(!_isPageMounted) return; //Constant Checks to see if the player has closed to cancel assynchronous function calls
    try {
      final yt = YoutubeExplode();
      var results = await yt.search.search("$trackName $artistName audio");
      final videoYtId = results.first.id;
      if(!_isPageMounted) return;
      var manifest = await yt.videos.streamsClient.getManifest(videoYtId);
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

  void fetchAlbumList() {
    List<MusicPlayerTrackList> tempTracks = [];
    widget.albumTrackList?.forEach((track) {
      MusicPlayerTrackList createdTempTrack = MusicPlayerTrackList(
        id: track.id,
        name: track.name,
        artistId: widget.album!.albumArtistId,
        artistName: track.artistNames.length > 1 ? "${track.artistNames[0]}, ${track.artistNames[1]}" : track.artistNames[0],
        duration: track.duration,
        imageUrl: widget.album!.albumImageUrl
      );
      tempTracks.add(createdTempTrack);
    });
    setState(() {
      _tracks = tempTracks;
    });
  }

  Future<void> fetchRecommendedList() async {
    final List<MusicPlayerTrackList> tracks = [];
    final tempFirstTrack = MusicPlayerTrackList(
      id: widget.track.id,
      name: widget.track.name,
      artistId: widget.track.artistId,
      artistName: widget.track.artistName,
      duration: widget.track.duration,
      imageUrl: widget.track.trackImageUrl
    );
    tracks.add(tempFirstTrack);
    setState(() {
      _tracks = tracks;
    });

    final trackResponse = await widget.spotifyService.getMusicPlayerTrackRecommendations(widget.track.artistId, widget.track.id);
    tracks.addAll(trackResponse);

    setState(() {
      _tracks = tracks;
    });
  }

  void playNextTrack() async {
    if(widget.currSongIndex < _tracks.length - 1) {
      await player.stop();
      widget.currSongIndex++;
      await fetchAudioDataFromYoutube(_tracks[widget.currSongIndex].name, _tracks[widget.currSongIndex].artistName);
    }
  }

  void playPreviousTrack() async {
    final currentPostion = await player.getCurrentPosition();
    const int threshold = 10;

    if(currentPostion != null && currentPostion.inSeconds >= threshold) {
      await player.seek(Duration.zero);
    } else {
      if(widget.isAlbum && widget.albumTrackList?.length == 1) {
        return;
      }
      else if(widget.currSongIndex > 0) {
        await player.stop();
        widget.currSongIndex--;
        await fetchAudioDataFromYoutube(_tracks[widget.currSongIndex].name, _tracks[widget.currSongIndex].artistName);
      }
      else {
        return;
      }
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
                  _tracks[widget.currSongIndex].imageUrl, 
                  fit: BoxFit.cover, width: ScreenUtils.screenWidth(context, 70), height: ScreenUtils.screenWidth(context, 70),
                ),
                SizedBox(height: ScreenUtils.screenHeight(context, 5),),
                Text(_tracks[widget.currSongIndex].name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w300)),
                SizedBox(height: ScreenUtils.screenHeight(context, 1),),
                GestureDetector(
                  onTap: () async {
                    final artist = await widget.spotifyService.getArtist(_tracks[widget.currSongIndex].artistId);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ArtistShowcasePage(artist: artist, spotifyService: widget.spotifyService,)));
                    dispose();
                  },
                  child: Text(_tracks[widget.currSongIndex].artistName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.grey.shade600))
                ),
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
                      onPressed: playPreviousTrack, 
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
                      onPressed: playNextTrack,
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