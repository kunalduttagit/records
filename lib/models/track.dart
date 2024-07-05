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