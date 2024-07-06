class Album {
  final String id;
  final String name;
  final String albumArtistName;
  final String albumArtistId;
  final String albumUrl;
  final String albumImageUrl;
  final int albumTotalTracks;
  final String releaseDate;
  //final String copyrights;

  Album({
    required this.id, 
    required this.name, 
    required this.releaseDate, 
    required this.albumArtistName,
    required this.albumArtistId,
    required this.albumUrl,
    required this.albumImageUrl,
    required this.albumTotalTracks,
    //required this.copyrights
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      name: json['name'],
      releaseDate: json['release_date'],
      albumArtistName: json['artists'][0]['name'],
      albumArtistId: json['artists'][0]['id'],
      albumUrl: json['external_urls']['spotify'],
      albumImageUrl: json['images'][0]['url'],
      albumTotalTracks: json['total_tracks'],
      //copyrights: json['copyrights']??json['copyrights'][0]['text']
    );
  }
}