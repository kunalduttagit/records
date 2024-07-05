import 'package:flutter/material.dart';
import 'package:record/models/artist.dart';
import 'package:record/services/spotify_services.dart';
import 'package:palette_generator/palette_generator.dart';

class ArtistShowcasePage extends StatefulWidget {
  //data
  final Artist artist;
  final SpotifyService spotifyService;

  //constructor
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
  @override
  void initState() {
    super.initState();
    _updateBackButtonColor();
  }

  Future<void> _updateBackButtonColor() async {
    final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
      NetworkImage(widget.artist.imageUrl),
    );

    final Color dominantColor = paletteGenerator.dominantColor?.color ?? Colors.white;
    setState(() {
      // Choose black or white based on the brightness of the dominant color
      _backButtonColor = dominantColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Artist', style: Theme.of(context).textTheme.titleMedium,),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: _backButtonColor),
      ),
      body: Column(
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
                  child: Flexible(child: Text(widget.artist.name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 36), textAlign: TextAlign.center,)),
                )
              ),
            ],
          )
        ],
      ),
    );
  }
}
