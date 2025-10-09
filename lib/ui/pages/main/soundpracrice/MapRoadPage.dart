import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/main/soundpracrice/CameraPage.dart';
import 'package:logosmart/ui/theme/AppColors.dart';
import 'package:provider/provider.dart';

import '../../../../core/storage/level_state.dart';
import '../../../../models/level_model.dart';
import '../../../../providers/level_provider.dart';
import 'StartButtonPage.dart';

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

  bool _hasLevelProvider(BuildContext context) {
    try {
      Provider.of<LevelProvider>(context, listen: false);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasLevelProvider(context)) {
      // Mavjud provider bilan hozirgi UI
      return const _MapRoadBody();
    }
    // Lokal provider (faqat shu sahifa uchun), arxitekturani o'zgartirmaymiz
    return ChangeNotifierProvider<LevelProvider>(
      create: (_) {
        final p = LevelProvider();
        // Sizdagi LevelProvider bootstrap()ni main.dart da chaqirilmagan bo‘lishi mumkin,
        // shu yerda xavfsiz chaqirib olamiz:
        p.bootstrap();
        return p;
      },
      child: const _MapRoadBody(),
    );
  }
}

class _MapRoadBody extends StatelessWidget {
  const _MapRoadBody();

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

    final levelStates = context.watch<LevelProvider>().levels;
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
                    top: 50,
                    child: SizedBox(
                      width: size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 25.0),
                            child: Row(
                              children: [
                                Image.asset("assets/icons/star.png", scale: 3),
                                const SizedBox(width: 10),
                                Text(
                                  // Masalan: jami yulduzlar summasini ko‘rsatish
                                  levelStates
                                      .fold<int>(0, (p, e) => p + e.stars)
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 35,
                                    color: AppColors.orange_300,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Image.asset(
                            "assets/icons/circle_bad.png",
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25.0,
                            ),
                            child: Image.asset(
                              "assets/icons/close_red.png",
                              width: 50,
                              height: 50,
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

                          // final prov = context.read<LevelProvider>();
                          // final next = (l.stars + 1).clamp(0, 3);
                          // prov.setStars(l.id, next);

                          var lv = levelStates[l.id - 1];

                          var aa = lv.exercise!.steps[0].action == "about";
                          print(levelStates[0].exercise!.steps[0].text);
                          print(lv.exercise!.steps.length);
                          print(
                            "AÀAAAAAAAAAAAAÀAAAAAAAAAAAAAÀAAAAAAAAAAAAAÀAAAAAAAAAAAAAÀAAAAAAAAAAAAAÀAAAAAAAAAAAAAÀAAAAAAAAAAAAAÀAAAAAAAAAAAAA",
                          );
                          print(lv.exercise!.steps[0].action);
                          if (aa) {
                            // lv.exercise!.steps.removeAt(0);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (b) =>
                                    StartTextPage(data: levelStates[l.id - 1]),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (b) =>
                                    CameraPage(data: levelStates[l.id - 1]),
                              ),
                            );
                          }
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
              prov.unlock(locked.id, 0);
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
        final size = i == 1 ? 30.0 : 20.0;
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
              Image.asset(l.skin, width: 70, height: 70, fit: BoxFit.cover),
              Text(
                '${l.id}',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: !l.locked ? Colors.white : AppColors.grey_600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
