class Artist {
  final String id;
  final String name;
  final int popularity;
  final List<String> genres;
  final int totalFollowers;
  final String imageUrl;

  Artist({
    required this.id,
    required this.name,
    required this.popularity,
    required this.genres,
    required this.totalFollowers,
    required this.imageUrl,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'],
      name: json['name'],
      popularity: json['popularity'],
      genres: List<String>.from(json['genres']),
      totalFollowers: json['followers']['total'],
      imageUrl: json['images'][0]['url']
    );
  }
}

// class ArtistImage {
//   final int height;
//   final int width;
//   final String url;

//   ArtistImage({
//     required this.height,
//     required this.width,
//     required this.url,
//   });

//   factory ArtistImage.fromJson(Map<String, dynamic> json) {
//     return ArtistImage(
//       height: json['height'],
//       width: json['width'],
//       url: json['url'],
//     );
//   }
// }