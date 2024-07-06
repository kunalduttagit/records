import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:record/models/album.dart';
import 'package:record/models/artist.dart';
import 'package:record/models/track.dart';
import 'package:record/pages/album_showcase_page.dart';
import 'package:record/pages/music_player.dart';
import 'package:record/pages/search_page.dart';
import 'package:record/pages/singles_showcase_page.dart';
import 'package:record/services/spotify_services.dart';
import 'package:palette_generator/palette_generator.dart';

class ArtistShowcasePage extends StatefulWidget {
  final Artist artist;
  final SpotifyService spotifyService;

  const ArtistShowcasePage({
    super.key,
    required this.artist,
    required this.spotifyService,
  });

  @override
  State<ArtistShowcasePage> createState() => _ArtistShowcasePageState();
}

class _ArtistShowcasePageState extends State<ArtistShowcasePage> {
  Color _backButtonColor = Colors.white;
  List<Track> _topSongs = [];
  List<Album> _topAlbums = [];
  List<Album> _topSingles = [];
  bool _isSongsLoading = true;
  bool _isAlbumsLoading = true;
  bool _isSinglesLoading = true;

  final ScrollController _mainPageScrollControllerForAppbar = ScrollController();
  double _scrollPosition = 0.0;

  _scrollListener() {
    setState(() {
      _scrollPosition = _mainPageScrollControllerForAppbar.position.pixels;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchTopSongs();
    _fetchTopAlbums();
    _fetchTopSingles();
    _updateBackButtonColor();
    _mainPageScrollControllerForAppbar.addListener(_scrollListener);
  }

  Future<void> _fetchTopSongs() async {
    final songs = await widget.spotifyService.getTopSongs(widget.artist.id, 6);
    setState(() {
      _topSongs = songs;
      _isSongsLoading = false;
    });
  }

  Future<void> _fetchTopAlbums() async {
    final albums = await widget.spotifyService.getTopArtistAlbums(widget.artist.id);
    setState(() {
      _topAlbums = albums;
      _isAlbumsLoading = false;
    });
  }

  Future<void> _fetchTopSingles() async {
    final albums = await widget.spotifyService.getTopArtistSingles(widget.artist.id);
    setState(() {
      _topSingles = albums;
      _isSinglesLoading = false;
    });
  }

  Future<void> _updateBackButtonColor() async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
      NetworkImage(widget.artist.imageUrl),
    );

    final Color dominantColor =
        paletteGenerator.dominantColor?.color ?? Colors.white;
    setState(() {
      _backButtonColor =
          dominantColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
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
        leading: BackButton(color: _backButtonColor),
        actions: [
          IconButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage(spotifyService: widget.spotifyService)));
            },
            icon: const Icon(CupertinoIcons.search), color: _backButtonColor,)
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
              title: Text(widget.artist.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade800)),
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
        controller: _mainPageScrollControllerForAppbar,
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
                        Colors.transparent,
                      ],
                      stops: const [0.6, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Image.network(
                    widget.artist.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      widget.artist.name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 36),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text("Top Songs",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold, fontSize: 23)),
            ),
            const SizedBox(height: 12),
            _isSongsLoading
                ? const Center(child: CircularProgressIndicator())
                : _topSongs.isEmpty
                    ? const Center(child: Text("No top songs available"))
                    : Column(
                        children: _topSongs
                            .map((song) => _buildTrackItem(context, song))
                            .toList(),
                      ),

            const SizedBox(
              height: 27,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text("Albums",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold, fontSize: 23)),
            ),
            
            _isAlbumsLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 13),
                    height: 250.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _topAlbums.length,
                      itemBuilder: (context, index) {
                        final album = _topAlbums[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AlbumShowcasePage(album: album, spotifyService: widget.spotifyService,)));
                          },
                          child: Container(
                            width: 160.0,
                            margin: const EdgeInsets.only(right: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(album.albumImageUrl),
                                const SizedBox(height: 8.0),
                                Text(album.name,  style: Theme.of(context).textTheme.titleLarge, maxLines: 2, overflow: TextOverflow.ellipsis,),
                                Text('${album.releaseDate.substring(0,4)} • ${album.albumTotalTracks} songs', style: Theme.of(context).textTheme.titleMedium,)
                              ]
                            )
                          )
                          
                        );
                      }),
              ),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text("Singles",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold, fontSize: 23)),
            ),
            
            _isSinglesLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 13),
                    height: 300.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _topSingles.length,
                      itemBuilder: (context, index) {
                        final single = _topSingles[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SingleShowcasePage(album: single, spotifyService: widget.spotifyService,)));
                          },
                          child: Container(
                            width: 160.0,
                            margin: const EdgeInsets.only(right: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(single.albumImageUrl),
                                const SizedBox(height: 8.0),
                                Text(single.name,  style: Theme.of(context).textTheme.titleLarge, maxLines: 2, overflow: TextOverflow.ellipsis,),
                                Text(single.releaseDate.substring(0,4), style: Theme.of(context).textTheme.titleMedium,)
                              ]
                            )
                          )
                          
                        );
                      }),
              )
                       
          ],
        ),
      ),
    );
  }

  Widget _buildTrackItem(BuildContext context, Track track) {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => MusicPlayer(track: track)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        height: 50.0,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Image.network(track.trackImageUrl,fit: BoxFit.cover,width: 50,height: 50,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(track.name,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500,color: Colors.grey[800],letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    track.albumName,
                    style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color: Colors.grey.shade600,letterSpacing: -0.6,
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
    );
  }
}
