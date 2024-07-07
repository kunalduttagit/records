import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:record/models/album.dart';
import 'package:record/models/artist.dart';
import 'package:record/models/track.dart';
import '../auth/secrets.dart';

class SpotifyService {
  final String _baseUrl = 'https://api.spotify.com/v1';
  String _accessToken = ''; 


  Future<void> getAccessToken() async {
    final _tokenUrl = Uri.parse('https://accounts.spotify.com/api/token');
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final body = 'grant_type=client_credentials&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET';
    
    var response = await http.post(_tokenUrl, headers: headers, body: body);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      _accessToken = jsonData['access_token'];
    } 
    print(_accessToken);
  }

  Future<Artist> getArtist(String artistId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/artists/$artistId'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final Artist artist = Artist.fromJson(jsonData);

      return artist;
    } else {
      throw Exception('Failed to fetch artist');
    }
  }

  Future<List<Artist>> getMultipleArtist(List<String> artistIds) async {
    final ids = artistIds.join(',');
    final response = await http.get(
      Uri.parse("$_baseUrl/artists/?ids=$ids"),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final artistsData = jsonData['artists'] as List<dynamic>;

      final artists = artistsData.map((artistData) {
        return Artist.fromJson(artistData as Map<String, dynamic>);
      }).toList();

      return artists;
    } else {
      throw Exception('Failed to fetch artists');
    }
  }

  Future<Map<String, dynamic>> getAlbum(String albumId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/albums/$albumId'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );
    return json.decode(response.body);
  }

  //Get indivitual song details
  Future<Map<String, dynamic>> getTrack(String trackId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/tracks/$trackId'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );
   // print(response.body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch track data$response');
    }
  }

  //Searching
  Future<Map<String, List<dynamic>>> search(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search?q=$query&type=album%2Ctrack%2Cartist&limit=5'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List<dynamic> trackItems = data['tracks']['items'];
      List<Track> tracks = trackItems.map((track) => Track.fromJson(track)).toList();

      List<dynamic> artistsItems = data['artists']['items'];
      List<Artist> artists = artistsItems.map((artist) => Artist.fromJson(artist)).toList();
      
      List<dynamic> albumItems = data['albums']['items'];
      List<Album> albums = albumItems.map((album) => Album.fromJson(album)).toList();
      
      return {'tracks': tracks, 'artists': artists, 'albums': albums};
    } else {
      throw Exception('Failed to fetch data: ${response.statusCode}');
    }
  }

  //Artist Top songs
  Future<List<Track>> getTopSongs(String artistId, int topNSongs) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/artists/$artistId/top-tracks'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> tracks = data['tracks'];
      List<Track> songs = tracks.map((song) => Track.fromJson(song)).toList(); 

      return songs.take(topNSongs).toList();
    } else {
      throw Exception("Failed to fetch top songs of artist: $response.statusCode");
    }
  }

  Future<List<Album>> getTopArtistAlbums(String artistId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/artists/$artistId/albums?include_groups=album&limit=10'),
       headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if(response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> albums = data['items'];
      List<Album> album = albums.map((album) => Album.fromJson(album)).toList();

      return album;

    } else {

      throw Exception("Failed to fetch artist top albums $response.statusCode");
    }
  }

  Future<List<Album>> getTopArtistSingles(String artistId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/artists/$artistId/albums?include_groups=single&limit=10'),
       headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if(response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> singles = data['items'];
      List<Album> single = singles.map((single) => Album.fromJson(single)).toList();

      return single;

    } else {

      throw Exception("Failed to fetch artist top albums $response.statusCode");
    }
  }

  Future<List<AlbumTrack>> getAlbumTracks(String albumId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/albums/$albumId/tracks'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> trackList = data['items'];
      List<AlbumTrack> tracks = trackList.map((track) => AlbumTrack.fromJson(track)).toList(); 

      return tracks;
    } else {
      throw Exception("Failed to fetch tracks for given album: ${response.statusCode}");
    }
  }

    Future<String> getCopyrights(String albumId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/albums/$albumId'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String copyrights = data['copyrights'][0]['text'];
    
    return copyrights;
    } else {
      throw Exception('Failed to load album copyrights: ${response.statusCode}');
    }
  }

  Future<List<MusicPlayerTrackList>> getMusicPlayerTrackRecommendations(artistId, trackId) async{
      final response = await http.get(
        Uri.parse('$_baseUrl/recommendations?seed_artists=$artistId&seed_tracks=$trackId'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if(response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['tracks'];
        final List<MusicPlayerTrackList> tracks = data.map((track) => MusicPlayerTrackList.fromJson(track)).toList();
        return tracks;
      } else {
        throw Exception('Failed to load recommended songs for music player ${response.statusCode}');
      }
  }

}