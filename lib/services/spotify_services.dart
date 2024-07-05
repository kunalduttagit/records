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

  Future<Map<String, dynamic>> getArtist(String artistId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/artists/$artistId'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );
    return json.decode(response.body);
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

}