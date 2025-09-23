import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logosmart/ui/theme/AppColors.dart';

import '../../../../core/storage/level_state.dart';
import '../../../../providers/level_provider.dart';

class LevelSkin {
  final String badge;

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

// Istasangiz bu sinusiy funksiya ham turaversin
List<Offset> generatePositionsSin(int count) {
  return List.generate(count, (i) {
    final t = i / (count - 1);
    final dx = 0.5 + 0.3 * math.sin(t * math.pi * 2);
    final dy = 0.05 + 0.9 * (t * t);
    return Offset(dx.clamp(0.05, 0.95), dy.clamp(0.05, 0.95));
  });
}

class MapRoadPage extends StatelessWidget {
  MapRoadPage({super.key});

  /// Zigzag joylashuv (siz so‘ragan tartib)
  List<Offset> generatePositions(int count) {
    if (count <= 1) {
      return [const Offset(0.5, 0.1)];
    }
    final stepY = 0.9 / (count - 1);
    double dx = 0.1;
    double dir = 1;
    final stepX = 0.30;

    return List.generate(count, (i) {
      final dy = 0.05 + stepY * i;
      final point = Offset(dx.clamp(0.05, 0.95), dy.clamp(0.05, 0.95));
      dx += dir * stepX;
      if (dx >= 0.9 || dx <= 0.1) dir *= -1;
      return point;
    });
  }

  /// Provider’dan olingan LevelState + pozitsiyani birlashtirib UI uchun Level tuzamiz
  List<Level> _buildLevelsFromState(List<LevelState> states) {
    final positions = generatePositions(states.length);
    return List.generate(states.length, (i) {
      final s = states[i];
      final pos = positions[i];
      return Level(
        id: s.id,
        dx: pos.dx,
        dy: pos.dy,
        stars: s.stars,
        locked: s.locked,
        skin: s.skin,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapHeight = MediaQuery.of(context).size.height * 2.4;

    // Provider’dan holatni olamiz
    final levelStates = context.watch<LevelProvider>().levels;
    print(levelStates.length);
    print(levelStates);
    final levels = _buildLevelsFromState(levelStates);

    return Scaffold(
      extendBodyBehindAppBar: true,
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
                            padding: const EdgeInsets.only(left: 25.0),
                            child: Row(
                              children: [
                                Image.asset("assets/icons/star.png", scale: 2.5),
                                const SizedBox(width: 10),
                                Text(
                                  // Masalan: jami yulduzlar summasini ko‘rsatish
                                  levelStates.fold<int>(0, (p, e) => p + e.stars).toString(),
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
                            width: 80, height: 80, fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Image.asset(
                              "assets/icons/close_red.png",
                              width: 55, height: 55, fit: BoxFit.cover,
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

                          // Misol uchun: bosganda yulduz +1 qilib ko‘rsatamiz
                          final prov = context.read<LevelProvider>();
                          final next = (l.stars + 1).clamp(0, 3);
                          prov.setStars(l.id, next);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Level ${l.id} → stars: $next')),
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
      // Test uchun pastga quick-action tugmalar (ixtiyoriy)
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'unlockNext',
            onPressed: () {
              final prov = context.read<LevelProvider>();
              final locked = prov.levels.firstWhere(
                    (e) => e.locked,
                orElse: () => prov.levels.last,
              );
              prov.unlock(locked.id);
            },
            label: const Text('Unlock next'),
            icon: const Icon(Icons.lock_open),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'resetAll',
            onPressed: () => context.read<LevelProvider>().resetAll(),
            label: const Text('Reset all'),
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
    );
  }
}

// -------------------- VIDJETLAR (o‘zingizdagi kabi) --------------------

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

class StarMeter extends StatelessWidget {
  final int value;
  final int max;
  final Color filledColor;
  final Color emptyColor;
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
        final size = i == 1 ? 35.0 : 25.0;
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
          if (!l.locked)
            SizedBox(
              height: 35,
              child: StarMeter(
                value: l.stars,
                max: 3,
                filledColor: starFilled,
                emptyColor: starEmpty,
              ),
            ),
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
                  color: !l.locked  ? Colors.white : AppColors.grey_600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
