import 'package:flutter/material.dart';
import 'package:spine_flutter/spine_flutter.dart';

class SpineTestPage extends StatefulWidget {
  const SpineTestPage({super.key});

  @override
  State<SpineTestPage> createState() => _SpineTestPageState();
}

class _SpineTestPageState extends State<SpineTestPage> {
  // 1. Controller va Drawable ob'ektlarini e'lon qilamiz
  late SpineWidgetController _controller;
  Future<SkeletonDrawableFlutter>? _spineLoader;

  @override
  void initState() {
    super.initState();

    // 2. Sizning kodingizdagi controller mantiqini shu yerga ko'chiramiz
    _controller = SpineWidgetController(
      onInitialized: (controller) {
        // Animatsiyalar orasidagi o'tish vaqti
        controller.animationState.data.defaultMix = 0.2;

        // Diqqat: "Tongue-cyrcle" sizning faylingizdagi animatsiya nomi
        // Agar faylingizda "portal" bo'lsa, uni yozing
        try {
          controller.animationState.setAnimation(0, "Tongue-cyrcle", true);
        } catch (e) {
          print("Animatsiya topilmadi: $e");
        }
      },
    );

    // 3. Fayllarni integratsiya usulida yuklashni boshlaymiz
    _spineLoader = SkeletonDrawableFlutter.fromAsset(
      "assets/hero.json",
      "assets/hero.atlas",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spine Integration')),
      body: FutureBuilder<SkeletonDrawableFlutter>(
        future: _spineLoader,
        builder: (context, snapshot) {
          // Yuklanish jarayoni
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Integratsiya xatosi: ${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          // Muvaffaqiyatli yuklansa, SpineWidget'ni chiqaramiz
          if (snapshot.hasData) {
            return Center(
              child: SpineWidget.fromDrawable(
                snapshot.data!, // Yuklangan drawable
                _controller, // Sizning controlleringiz
                fit: BoxFit.contain,
                alignment: Alignment.center,
                sizedByBounds: true,
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
