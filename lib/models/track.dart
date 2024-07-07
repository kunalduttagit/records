import 'package:record/utils/format_time.dart';

class Track {
  final String id;
  final String name;
  final int duration;
  final String albumName;
  final String albumId;
  final String artistName;
  final String artistId;
  final String trackImageUrl;

  Track({
    required this.id,
    required this.name,
    required this.duration,
    required this.albumName,
    required this.albumId,
    required this.artistName,
    required this.artistId,
    required this.trackImageUrl,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      name: json['name'],
      duration: json['duration_ms'],
      albumName: json['album']['name'],
      albumId: json['album']['id'],
      artistName: json['artists'][0]['name'],
      artistId: json['artists'][0]['id'],
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

class MusicPlayerTrackList {
  final String id;
  final String name;
  final String artistId;
  final String artistName;
  final int duration;
  final String imageUrl;

  MusicPlayerTrackList({
    required this.id,
    required this.name,
    required this.artistId,
    required this.artistName,
    required this.duration,
    required this.imageUrl,
  });

  factory MusicPlayerTrackList.fromJson(Map<String, dynamic> json) {
    return MusicPlayerTrackList(
      id: json['id'],
      name: json['name'],
      duration: json['duration_ms'],
      artistName: json['artists'][0]['name'],
      artistId: json['artists'][0]['id'],
      imageUrl: json['album']['images'][0]['url'],
    );
  }
}