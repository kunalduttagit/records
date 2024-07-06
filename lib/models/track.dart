import 'package:record/utils/format_time.dart';

class Track {
  final String id;
  final String name;
  final int duration;
  final String albumName;
  final String albumUrl;
  final String artistName;
  final String artistUrl;
  final String trackImageUrl;

  Track({
    required this.id,
    required this.name,
    required this.duration,
    required this.albumName,
    required this.albumUrl,
    required this.artistName,
    required this.artistUrl,
    required this.trackImageUrl,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      name: json['name'],
      duration: json['duration_ms'],
      albumName: json['album']['name'],
      albumUrl: json['album']['external_urls']['spotify'],
      artistName: json['artists'][0]['name'],
      artistUrl: json['artists'][0]['external_urls']['spotify'],
      trackImageUrl: json['album']['images'][0]['url'],
    );
  }
}

class AlbumTrack {
  final String id;
  final String name;
  final int duration;
  final List<String> artistNames;

  AlbumTrack({
    required this.id,
    required this.name,
    required this.duration,
    required this.artistNames,
  });

  factory AlbumTrack.fromJson(Map<String, dynamic> json) {
    return AlbumTrack(id: json['id'],
      name: json['name'],
      duration: json['duration_ms'],
      artistNames: (json['artists'] as List<dynamic>)
        .map((artist) => artist['name'] as String)
        .toList(),
    );
  }
}

String getTotalDuration(List<AlbumTrack> tracks) {
  int duration = tracks.fold(0, (sum, track) => sum + track.duration);
  return formatDurationHours(duration);
}