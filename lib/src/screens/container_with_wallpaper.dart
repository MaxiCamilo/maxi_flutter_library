import 'package:flutter/material.dart';

class ContainerWithWallpaper extends StatelessWidget {
  final String assetImage;
  final Widget child;
  final double? height;
  final double? width;
  final BoxFit? fit;

  const ContainerWithWallpaper({
    super.key,
    required this.assetImage,
    required this.child,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        height: height ?? constraints.maxHeight,
        width: width ?? constraints.maxWidth,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(assetImage), fit: fit),
        ),
        child: child,
      ),
    );
  }
}
