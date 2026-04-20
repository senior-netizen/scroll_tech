import 'package:flutter/material.dart';

class LazyNetworkImage extends StatelessWidget {
  const LazyNetworkImage({super.key, required this.url, this.height = 120});

  final String url;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      height: height,
      cacheWidth: 320,
      filterQuality: FilterQuality.low,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          height: height,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
        );
      },
      errorBuilder: (_, __, ___) => SizedBox(
        height: height,
        child: const Center(child: Icon(Icons.broken_image_outlined)),
      ),
    );
  }
}
