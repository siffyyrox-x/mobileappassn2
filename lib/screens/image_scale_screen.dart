import 'package:flutter/material.dart';

class ImageScaleScreen extends StatelessWidget {
  const ImageScaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const imageUrl = 'https://raw.githubusercontent.com/bumptech/glide/master/static/glide_logo.png';

    return Container(
      color: Colors.black,
      child: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20.0),
          minScale: 0.1,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Text(
                  'Failed to load image',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
