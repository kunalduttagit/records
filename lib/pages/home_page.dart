import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:record/models/artist.dart';
import 'package:record/pages/artist_showcase_page.dart';
import 'package:record/pages/music_player.dart';
import 'package:record/pages/search_page.dart';
import 'package:record/services/spotify_services.dart';
import 'package:record/utils/string_methods.dart';

import '../models/track.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpotifyService _spotifyService = SpotifyService();
  late String greeting;

  @override
  void initState() {
    super.initState();
    _spotifyService.getAccessToken().then((_) {
      _fetchTracks();
      _fetchArtists();
    });
    getGreetingMessage();
  }

  final List<String> initSongList = [
    '1Vk4yRsz0iBzDiZEoFMQyv',
    '3qhlB30KknSejmIvZZLjOD',
    '6M4nkEPZMj58acftDRTuKL',
    '0tgVpDi06FyKpA1z0VMD4v',
    '0So2sgVa8aJiARPl2P29u2'
  ];
  List<Track> _tracks = [];

  Future<void> _fetchTracks() async {
    List<Track> tracks = [];
    for (String trackId in initSongList) {
      final trackData = await _spotifyService.getTrack(trackId);
      tracks.add(Track.fromJson(trackData));
    }
    setState(() {
      _tracks = tracks;
    });
  }

  final List<String> initArtistList = [
    '06HL4z0CvFAxyc27GXpf02', //Taylor Swift
    '6eUKZXaKkcviH0Ku9w2n3V', //Ed Sheeren
    '4YRxDV8wJFPHPTeXepOstw', //Arijit Singh
    '6VuMaDnrHyPL1p4EHjYLi7', //Charlie Puth
    '69GGBxA162lTqCwzJG5jLp', //The Chainsmokers
    '0oOet2f43PA68X5RxKobEy', //Shreya Ghoshal
  ];
  List<Artist> _artists = [];

  Future<void> _fetchArtists() async {
    _artists = await _spotifyService.getMultipleArtist(initArtistList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: Colors.transparent,
        title: Text(greeting, style: Theme.of(context).textTheme.headlineSmall,),
        // title: Icon(CupertinoIcons.waveform),
        actions: [
          IconButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage(spotifyService: _spotifyService)));
            },
            icon: const Icon(CupertinoIcons.search))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      
            //Top Songs headings
            Text("Discover", style: Theme.of(context).textTheme.headlineLarge,),
            Text("Popular songs around you", style: Theme.of(context).textTheme.headlineSmall,),
            
            //Top songs showcase
             _tracks.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  margin: const EdgeInsets.symmetric(vertical: 20.0),
                  height: 250.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tracks.length,
                    itemBuilder: (context, index) {
                      final track = _tracks[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => MusicPlayer(track: track)));
                        },
                        child: Container(
                          width: 160.0,
                          margin: const EdgeInsets.only(right: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(track.trackImageUrl, fit: BoxFit.cover, width:155, height: 155,),
                              const SizedBox(height: 8.0),
                              Text(track.name, style: Theme.of(context).textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis,),
                              Text(track.artistName, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      
            //Top Albums
            Text("Top Artists", style: Theme.of(context).textTheme.headlineLarge,),
            Text("Popular artists from around the world", style: Theme.of(context).textTheme.headlineSmall,), 
      
            //Top artists showcase
            _artists.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  margin: const EdgeInsets.symmetric(vertical: 20.0),
                  height: 300.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _artists.length,
                    itemBuilder: (context, index) {
                      final artist = _artists[index];
                      return GestureDetector(
                        onTap: () {
                           Navigator.push(context, MaterialPageRoute(builder: (context) => ArtistShowcasePage(artist: artist, spotifyService: _spotifyService,)));
                        },
                        child: Container(
                          width: 160.0,
                          margin: const EdgeInsets.only(right: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(artist.imageUrl, fit: BoxFit.cover, width:155, height: 155,),
                              const SizedBox(height: 8.0),
                              Text(artist.name, style: Theme.of(context).textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis,),
                              Text(artist.genres[0].toTitleCase(), style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      )
    );
  }
  void getGreetingMessage() {
    // Get the current time
    DateTime now = DateTime.now();
    int hour = now.hour;

    // Determine the time of day and generate the greeting message
    if (hour >= 5 && hour < 12) {
      greeting = 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      greeting = 'Good Evening';
    } else {
      greeting = 'Good Night';
    }
  }
}

