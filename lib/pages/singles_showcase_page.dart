import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:record/models/album.dart';
import 'package:record/models/track.dart';
import 'package:record/pages/music_player.dart';
import 'package:record/pages/search_page.dart';
import 'package:record/services/spotify_services.dart';
import 'package:record/utils/map_index.dart';
import 'package:record/utils/format_time.dart';

class SingleShowcasePage extends StatefulWidget {
  final Album album;
  final SpotifyService spotifyService;
  const SingleShowcasePage({
    super.key,
    required this.album,
    required this.spotifyService
  });

  @override
  State<SingleShowcasePage> createState() => _SingleShowcasePageState();
}

class _SingleShowcasePageState extends State<SingleShowcasePage> {
  List<AlbumTrack> _tracks = [];
  bool _isLoading = true;
  late String copyrights = "";

  final ScrollController _scrollController = ScrollController();
  double _scrollPosition = 0.0;

  _scrollListener() {
    setState(() {
      _scrollPosition = _scrollController.position.pixels;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAlbumTracks();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _fetchAlbumTracks() async {
    final tracks = await widget.spotifyService.getAlbumTracks(widget.album.id);
    final copy = await widget.spotifyService.getCopyrights(widget.album.id);
    setState(() {
      _tracks = tracks;
      _isLoading = false;
      copyrights = copy;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _scrollPosition <= 309.0
     ? AppBar(
        title: Text('', style: Theme.of(context).textTheme.titleMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(),
        actions: [
          IconButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage(spotifyService: widget.spotifyService)));
            },
            icon: const Icon(CupertinoIcons.search))
        ],
      )
      : PreferredSize(
        preferredSize: const Size(
          double.infinity,
          56.0,
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: AppBar(
              title: Text(widget.album.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade800)),
              leading: const BackButton(),
              elevation: 0.0,
              backgroundColor: Colors.white.withAlpha(20),
              actions: [
                IconButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage(spotifyService: widget.spotifyService)));
                  },
                  icon: const Icon(CupertinoIcons.search))
              ],
            ),
          ), 
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(1),
                        Colors.white.withOpacity(0.9),
                        Colors.transparent,
                      ],
                      stops: const [0.6, 0.7, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: ClipRRect(
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaY:35,sigmaX:35),
                      child: Image.network(widget.album.albumImageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    ),
                  ),
                ),

                Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 124.0, right: 124.0, top: 124.0, bottom: 18),
                          child: Image.network(widget.album.albumImageUrl),
                        ),
                        Text(
                          widget.album.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(fontWeight: FontWeight.bold, fontSize: 27),
                          textAlign: TextAlign.center,
                        ),
                        Text("Single by ${widget.album.albumArtistName} • ${widget.album.releaseDate.substring(0,4)}", style: TextStyle(color: Colors.grey[800]))
                      ],
                    )
                  ),
              ],
            ),

            const SizedBox(height: 20,),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text("Song",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold, fontSize: 21)),
            ),

            const SizedBox(height: 13,),

            _tracks.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                  children: _tracks.mapIndexed((track, index) => 
                    InkWell(
                      onTap: () async {
                        final trackFromAlbum = await widget.spotifyService.getTrack(track.id);
                        final tempTrack = Track.fromJson(trackFromAlbum);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MusicPlayer(track: tempTrack)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          children: [
                            Container(
                              width: 30, // Adjust this value as needed
                              alignment: Alignment.centerRight,
                              child: Text(
                                (index + 1).toString(),
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 21),
                              ),
                            ),
                            const SizedBox(width: 15,),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(track.name,
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500,color: Colors.grey[800],letterSpacing: -0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(track.artistNames.length < 2
                                    ? "${track.artistNames[0]} • ${formatDuration(track.duration)}"
                                    : "${track.artistNames[0]}, ${track.artistNames[1]} • ${formatDuration(track.duration)}",
                                    style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color: Colors.grey.shade600,letterSpacing: -0.6,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ).toList(),
                ),
            ),

            const SizedBox(height: 20,),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text("${widget.album.albumTotalTracks} song • ${getTotalDuration(_tracks)}",
                  style: Theme.of(context).textTheme.titleMedium)
                )
              ),

            const SizedBox(height: 10,),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 18, right: 18, bottom: 24),
                child: Text(copyrights, textAlign: TextAlign.center)
              ),
            )
          ],
        ),
      ),
    );
  }
}