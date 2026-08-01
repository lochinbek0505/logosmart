import 'package:flutter/material.dart';

class TiledBackground extends StatelessWidget {
  final String asset;
  final double height;

  const TiledBackground({super.key, required this.asset, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(asset),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            repeat: ImageRepeat.repeatY,
          ),
        ),
      ),
    );
  }
}
