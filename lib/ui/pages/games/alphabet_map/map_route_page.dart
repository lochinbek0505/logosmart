import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/cv_model/camera_page.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/widgets/interactive_lottie.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/widgets/level_button.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/widgets/tiled_background.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../../core/storage/level_state.dart';
import '../../../../models/decoration_item.dart';
import '../../../../models/level_model.dart';
import 'provider/level_provider.dart';
import 'start_text_page.dart';

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
      return const _MapRoadBody();
    }
    return ChangeNotifierProvider<LevelProvider>(
      create: (_) {
        final p = LevelProvider();
        p.bootstrap();
        return p;
      },
      child: const _MapRoadBody(),
    );
  }
}

class _MapRoadBody extends StatelessWidget {
  const _MapRoadBody();

  // SIZNING ASL ZIK-ZAK JOYLASUVINGIZ
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

  // BO'SH JOYLAR UCHUN ANIMATSIYALAR
  List<DecorationItem> generateDecorations(List<Offset> levelPositions) {
    final List<DecorationItem> decorations = [];
    final List<String> lottieAssets = [
      'assets/animation/map/box.json',
      'assets/animation/map/cute.json',
      'assets/animation/map/brchest.json',
      'assets/animation/map/rabbit.json',
      'assets/animation/map/chest.json',
    ];

    for (int i = 0; i < levelPositions.length - 1; i += 2) {
      final pos = levelPositions[i];
      double decorDx = pos.dx < 0.5
          ? 0.75 + (math.Random().nextDouble() * 0.1)
          : 0.15 + (math.Random().nextDouble() * 0.1);

      double decorDy = pos.dy + ((levelPositions[i + 1].dy - pos.dy) / 2);

      if(i!=0) {
        decorations.add(
          DecorationItem(
            dx: decorDx,
            dy: decorDy,
            assetPath: lottieAssets[i % lottieAssets.length],
          ),
        );
      }
    }
    return decorations;
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

    final positions = generatePositions(levelStates.length);
    final decorations = generateDecorations(positions);

    // Qaysi level eng oxirgi ochiq level ekanligini topamiz (puls animatsiyasi uchun)
    int currentLevelId = 1;
    for (var l in levels) {
      if (!l.locked) {
        currentLevelId = l.id;
      }
    }

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

                  // LOTTIE ANIMATSIYALARI
                  ...decorations.map((decor) {
                    final px = decor.dx * size.width;
                    final py = decor.dy * size.height;
                    return Positioned(
                      left: px - 40,
                      top: py - 40,
                      child: InteractiveLottie(
                        assetPath: decor.assetPath,
                        size: 80,
                      ),
                    );
                  }),

                  // YUQORI QISM (Sizning asl dizayningiz)
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
                                GestureDetector(
                                  onTap: () {},
                                  child: Image.asset(
                                    "assets/icons/star.png",
                                    scale: 3,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
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

                  // ASOSIY LEVEL TUGMALARI (Sizning asl kordinatalaringiz bilan)
                  ...levels.map((l) {
                    final px = l.dx * size.width * 0.85;
                    final py = l.dy * size.height + 60;

                    // Agar bu foydalanuvchi to'xtagan eng oxirgi bosqich bo'lsa
                    final isCurrent = l.id == currentLevelId;

                    return Positioned(
                      left: px - 28,
                      top: py - 28,
                      child: LevelButton(
                        level: l,
                        isCurrent: isCurrent, // Animatsiya holatini beramiz
                        onTap: () {
                          if (l.locked) return;

                          var lv = levelStates[l.id - 1];
                          var hasAbout = false;
                          if (lv.exercise != null && lv.exercise!.steps.isNotEmpty) {
                            hasAbout = lv.exercise!.steps[0].action == "about";
                          }

                          if (hasAbout) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (b) =>
                                    StartTextPage(data: levelStates[l.id - 1]),
                              ),
                            );
                          } else {
                            context.read<LevelProvider>().setCurrentLevel(l.id - 1);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CameraPage()),
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
    );
  }
}




