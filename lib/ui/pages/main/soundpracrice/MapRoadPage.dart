import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:logosmart/ui/theme/AppColors.dart';

// -------------------- MODELLAR --------------------

class LevelSkin {
  final String badge; // lock PNG (ixtiyoriy)

  const LevelSkin({required this.badge});
}

class Level {
  final int id;
  final double dx;
  final double dy;
  final int stars;
  final bool locked;
  final String skin;

  const Level({
    required this.id,
    required this.dx,
    required this.dy,
    required this.stars,
    required this.locked,
    required this.skin,
  });
}

List<Offset> generatePositions(int count) {
  return List.generate(count, (i) {
    final t = i / (count - 1);

    final dx = 0.5 + 0.3 * math.sin(t * math.pi * 2);
    final dy = 0.05 + 0.9 * (t * t);

    return Offset(dx.clamp(0.05, 0.95), dy.clamp(0.05, 0.95));
  });
}

// Level, LevelSkin, LevelButton, TiledBackground sizning loyihangizda mavjud bo'lsin.

class MapRoadPage extends StatelessWidget {
  MapRoadPage({super.key});

  // --- Skinlar (asset yo'llarini o'zingiznikiga moslang)
  static const skinGold = 'assets/icons/gold.png';
  static const skinSilver = 'assets/icons/silver.png';

  /// --- Level metadata (joylashuvdan tashqari barcha ma'lumotlar)
  final List<Map<String, dynamic>> levelData = const [
    {"id": 1, "stars": 3, "locked": false, "skin": skinGold},
    {"id": 2, "stars": 3, "locked": false, "skin": skinGold},
    {"id": 3, "stars": 2, "locked": false, "skin": skinGold},
    {"id": 4, "stars": 3, "locked": false, "skin": skinGold},
    {"id": 5, "stars": 2, "locked": false, "skin": skinGold},
    {"id": 6, "stars": 1, "locked": false, "skin": skinGold},
    {"id": 7, "stars": 3, "locked": false, "skin": skinGold},
    {"id": 8, "stars": 0, "locked": false, "skin": skinSilver},
    {"id": 9, "stars": 0, "locked": true, "skin": skinSilver},
    {"id": 10, "stars": 0, "locked": true, "skin": skinSilver},
    {"id": 11, "stars": 0, "locked": true, "skin": skinSilver},
    {"id": 12, "stars": 0, "locked": true, "skin": skinSilver},
    {"id": 13, "stars": 0, "locked": true, "skin": skinSilver},
    {"id": 14, "stars": 0, "locked": true, "skin": skinSilver},
    {"id": 15, "stars": 0, "locked": true, "skin": skinSilver},
    {"id": 16, "stars": 0, "locked": true, "skin": skinSilver},
    {"id": 17, "stars": 0, "locked": true, "skin": skinSilver},
    {"id": 18, "stars": 0, "locked": true, "skin": skinSilver},
  ];

  /// --- Joylashuvlarni egri chiziq bo'yicha generatsiya qiladi (0..1 oralig'ida).
  /// dx -> sinus orqali chap-o'ngga tebranish, dy -> yuqoridan pastga kvadratik
  List<Offset> generatePositions(int count) {
    if (count <= 1) {
      return [const Offset(0.5, 0.1)];
    }

    final stepY = 0.9 / (count - 1); // vertikal bosqich
    double dx = 0.1; // boshlang‘ich x (chap tomonda)
    double dir = 1; // 1 = o‘ngga, -1 = chapga
    final stepX = 0.30; // gorizontal bosqich

    return List.generate(count, (i) {
      final dy = 0.05 + stepY * i;

      // Natijaviy nuqta
      final point = Offset(dx.clamp(0.05, 0.95), dy.clamp(0.05, 0.95));

      // Keyingi bosqich uchun tayyorlash
      dx += dir * stepX;
      if (dx >= 0.9 || dx <= 0.1) {
        // chegaraga yetganda yo‘nalishni o‘zgartiramiz
        dir *= -1;
      }

      return point;
    });
  }

  /// --- Joylashuv + metadata ni birlashtirib yakuniy Level ro'yxatini qaytaradi
  List<Level> buildLevels() {
    final positions = generatePositions(levelData.length);
    return List.generate(levelData.length, (i) {
      final d = levelData[i];
      final pos = positions[i];
      return Level(
        id: d["id"] as int,
        dx: pos.dx,
        dy: pos.dy,
        stars: d["stars"] as int,
        locked: d["locked"] as bool,
        skin: d["skin"],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // scrollable zona balandligi (xaritani uzun qilish uchun)
    final mapHeight = MediaQuery.of(context).size.height * 2.4;

    // Yakuniy level ro'yxati
    final levels = buildLevels();

    return Scaffold(
      extendBodyBehindAppBar: true, // status bar ortiga ham cho‘zadi
      body: SingleChildScrollView(
        child: SizedBox(
          height: mapHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);

              return Stack(
                children: [
                  Positioned.fill(
                    child: TiledBackground(
                      asset: 'assets/backround/map_background.png',
                      height: mapHeight,
                    ),
                  ),

                  Positioned(
                    top: 60,
                    child: SizedBox(
                      width: size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 25.0,
                            ),
                            child: Row(
                              children: [
                                Image.asset("assets/icons/star.png", scale: 2.5),
                                SizedBox(width: 10,),
                                Text(
                                  "18",
                                  style: TextStyle(
                                    fontSize: 40,
                                    color: AppColors.orange_300,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Image.asset(
                            "assets/icons/circle_bad.png",
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25.0,
                            ),
                            child: Image.asset(
                              "assets/icons/close_red.png",
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  ...levels.map((l) {
                    final px = l.dx * size.width * 0.85;
                    final py = l.dy * size.height + 60;
                    return Positioned(
                      left: px - 28,
                      top: py - 28,
                      child: LevelButton(
                        level: l,
                        onTap: () {
                          if (l.locked) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Level ${l.id} ochildi')),
                          );
                        },
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// -------------------- VIDJETLAR --------------------

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
            repeat: ImageRepeat.repeatY, // MUHIM: vertikal tile
          ),
        ),
      ),
    );
  }
}

/// 0..max oralig‘idagi yulduz metr
class StarMeter extends StatelessWidget {
  final int value; // nechta to‘liq yulduz (0..max)
  final int max; // jami yulduzlar soni (default: 3)
  final Color filledColor; // to‘liq yulduz rangi
  final Color emptyColor; // bo‘sh yulduz rangi
  final EdgeInsets spacing;

  const StarMeter({
    super.key,
    required this.value,
    this.max = 3,
    this.filledColor = Colors.amber,
    this.emptyColor = Colors.black26,
    this.spacing = const EdgeInsets.symmetric(horizontal: 2),
  });

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0, max);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (i) {
        final filled = i < v;
        double size = i == 1 ? 35 : 25;
        return Padding(
          padding: spacing,
          child: Image.asset(
            filled ? "assets/icons/star.png" : "assets/icons/star_grey.png",
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        );
      }),
    );
  }
}

class LevelButton extends StatelessWidget {
  final Level level;
  final VoidCallback? onTap;

  const LevelButton({super.key, required this.level, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = level;
    final starFilled = l.locked ? Colors.grey : Colors.amber;
    final starEmpty = l.locked ? Colors.black26 : Colors.black26;

    return GestureDetector(
      onTap: l.locked ? null : onTap,
      child: Column(
        children: [
          !l.locked
              ? SizedBox(
                  height: 35,
                  child: StarMeter(
                    value: l.stars,
                    max: 3,
                    filledColor: starFilled,
                    emptyColor: starEmpty,
                  ),
                )
              : SizedBox(),
          const SizedBox(height: 5),
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(l.skin, width: 80, height: 80, fit: BoxFit.cover),
              Text(
                '${l.id}',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: l.stars != 0 ? Colors.white : AppColors.grey_600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
