import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:record/models/album.dart';
import 'package:record/models/artist.dart';
import 'package:record/models/track.dart';
import 'package:record/pages/album_showcase_page.dart';
import 'package:record/pages/artist_showcase_page.dart';
import 'package:record/pages/music_player.dart';
import 'package:record/services/spotify_services.dart';

//TODO: add tile wide tap support

class SearchPage extends StatefulWidget {
  final SpotifyService spotifyService;
  const SearchPage({super.key, required this.spotifyService});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<Track> _tracks = [];
  List<Artist> _artists = [];
  List<Album> _albums = [];
  List<dynamic> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search", style: Theme.of(context).textTheme.headlineSmall,),
        backgroundColor: Colors.transparent,
      ),
      body:SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                autofocus: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(CupertinoIcons.search),
                  // icon: const Icon(CupertinoIcons.search),
                  hintText: "Songs, artists, or albums",
                  hintStyle: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6)
                  ),
                ),
                
              ),
              const SizedBox(height: 10,),
              //Search Results
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final item = _searchResults[index];
                    if (item is Track) {
                      return _buildTrackItem(context, item);
                    } else if (item is Artist) {
                      return _buildArtistItem(context, item);
                    } else if (item is Album) {
                      return _buildAlbumItem(context, item);
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  Widget _buildTrackItem(BuildContext context, Track track) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => MusicPlayer(track: track)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        height: 50.0,
        child: Row(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(2),child: Image.network(track.trackImageUrl, fit: BoxFit.cover, width: 50, height: 50,)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(track.name, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.grey[800], letterSpacing: -0.5), maxLines: 1, overflow: TextOverflow.ellipsis,),
                  Text("Song • ${track.artistName}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey.shade600, letterSpacing: -0.6), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtistItem(BuildContext context, Artist artist) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ArtistShowcasePage(artist: artist, spotifyService: widget.spotifyService,)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        height: 50.0,
        child: Row(
          children: [
            ClipRRect(borderRadius:BorderRadius.circular(2), child: Image.network(artist.imageUrl, fit: BoxFit.cover, width: 50, height: 50,)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(artist.name, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.grey[800], letterSpacing: -0.5), maxLines: 1, overflow: TextOverflow.ellipsis,),
                  Text(
                    artist.genres.isNotEmpty
                        ? "Artist • ${artist.genres.first}"
                        : "Artist",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey.shade600, letterSpacing: -0.6), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumItem(BuildContext context, Album album) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => AlbumShowcasePage(album: album, spotifyService: widget.spotifyService,)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        height: 50.0,
        child: Row(
          children: [
            ClipRRect(borderRadius:BorderRadius.circular(2), child: Image.network(album.albumImageUrl, fit: BoxFit.cover, width: 50, height: 50,)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(album.name, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.grey[800], letterSpacing: -0.5), maxLines: 1, overflow: TextOverflow.ellipsis,),
                  Text("Album • ${album.albumArtistName}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey.shade600, letterSpacing: -0.6), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
       _fetchSearchResults(query);
    });
}


  Future<void> _fetchSearchResults(String query) async {
    try {
      final results = await widget.spotifyService.search(query);
      setState(() {
        _tracks = (results['tracks'] as List).map((item) => item as Track).toList();
        _artists = (results['artists'] as List).map((item) => item as Artist).toList();
        _albums = (results['albums'] as List).map((item) => item as Album).toList();
        _searchResults = _buildSearchResults();
      });
    } catch (e) {
      print("error fetching: $e");
    }
  }


  List<dynamic> _buildSearchResults() {
    List<dynamic> results = [];
    int trackIndex = 0, artistIndex = 0, albumIndex = 0;

    // Add 4 songs
    results.addAll(_tracks.take(4));
    trackIndex += 4;

    // Add 2 artists
    results.addAll(_artists.take(2));
    artistIndex += 2;

    // Add 2 albums
    results.addAll(_albums.take(2));
    albumIndex += 2;

    // Add 1 song
    if (trackIndex < _tracks.length) {
      results.add(_tracks[trackIndex]);
      trackIndex += 1;
    }

    // Add 3 artists
    results.addAll(_artists.skip(artistIndex).take(3));
    artistIndex += 3;

    // Add 3 albums
    results.addAll(_albums.skip(albumIndex).take(3));
    albumIndex += 3;

    return results;
  }

}