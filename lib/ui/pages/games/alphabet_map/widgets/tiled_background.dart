import 'package:flutter/material.dart';
class TiledBackground extends StatelessWidget {
  final String asset;
  final double height;

  const TiledBackground({super.key, required this.asset, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height, // Biz tepadagi level soniga qarab bergan balandlik
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(asset),
            fit: BoxFit.fitWidth, // Ekran kengligiga moslashadi, qolgani pastga cho'ziladi
            alignment: Alignment.topCenter, // Rasmni tepadan boshlab ko'rsatadi
            repeat: ImageRepeat.repeatY, // Agar rasm qisqa bo'lsa, sifatini buzmay ulab ketaveradi
          ),
        ),
      ),
    );
  }
}
