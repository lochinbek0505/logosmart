import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/cv_model/camera_page.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/widgets/interactive_lottie.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/widgets/level_button.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/widgets/tiled_background.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../../../../core/storage/level_state.dart';
import '../../../../models/decoration_item.dart';
import '../../../../models/level_model.dart';
import '../arrow_game/arrow_game_page.dart';
import '../breath_game/breath_game.dart';
import '../cloud_game/cloud_game_page.dart';
import '../cooking/cooking_page.dart';
import '../drag_drop/drag_drop_game_page.dart';
import '../find_image_game/find_image_game_page.dart';
import '../hand_game/hand_game_page.dart';
import '../puzzle_game/puzzle_game_widget.dart';
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

class _MapRoadBody extends StatefulWidget {
  const _MapRoadBody();

  @override
  State<_MapRoadBody> createState() => _MapRoadBodyState();
}

class _MapRoadBodyState extends State<_MapRoadBody> {
  // LEVEL TUGMALARI JOYLASHUVI
  List<Offset> generatePositions(int count) {
    if (count <= 1) {
      return [const Offset(0.5, 0.023)];
    }

    const startY = 0.023; // Tepadagi boshlanish qismi 2.3%

    // O'ZGARISH SHU YERDA: 0.95 ni 0.99 ga o'zgartirdik
    // Bu oxirgi level eng pastga yaqinroq (99% pastda) bo'lishini ta'minlaydi
    final stepY = (0.99 - startY) / (count - 1);

    const amplitude = 0.35;
    const frequency = 0.8;
    const phaseOffset = 4.0;

    return List.generate(count, (i) {
      final dy = startY + (stepY * i);

      final dx = 0.5 + (amplitude * math.sin((i * frequency) + phaseOffset));

      return Offset(dx.clamp(0.15, 0.85), dy);
    });
  }

  // LOTTIE ANIMATSIYALARI (Tugmalarga umuman tegmaydigan qilib sozlandi)
  List<DecorationItem> generateDecorations(List<Offset> levelPositions) {
    final List<DecorationItem> decorations = [];
    final List<String> lottieAssets = [
      'assets/animation/map/box.json',
      'assets/animation/map/cute.json',
      'assets/animation/map/brchest.json',
      'assets/animation/map/rabbit.json',
      'assets/animation/map/chest.json',
    ];

    // Animatsiyalarni har 2 ta levelning o'rtasidagi bo'shliqqa qo'yamiz
    for (int i = 0; i < levelPositions.length - 1; i += 2) {
      final pos1 = levelPositions[i];
      final pos2 = levelPositions[i + 1];

      // Y o'qida: Ikkita levelning qoq o'rtasidagi bo'shliqni topamiz
      double decorDy = (pos1.dy + pos2.dy) / 2;

      // X o'qida: Shu oraliqdagi levellar asosan qaysi tomonda ekanini topamiz
      double avgDx = (pos1.dx + pos2.dx) / 2;
      double decorDx;

      // Agar levellar chapda bo'lsa, animatsiyani chekka o'ngga suramiz
      if (avgDx < 0.5) {
        decorDx = 0.75 + (math.Random().nextDouble() * 0.15); // O'ng tomon
      } else {
        // Agar levellar o'ngda bo'lsa, animatsiyani chekka chapga suramiz
        decorDx = 0.1 + (math.Random().nextDouble() * 0.15); // Chap tomon
      }

      decorations.add(
        DecorationItem(
          dx: decorDx.clamp(0.05, 0.95),
          dy: decorDy,
          assetPath: lottieAssets[(i ~/ 2) % lottieAssets.length],
        ),
      );
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
    final levelStates = context.watch<LevelProvider>().levels;
    final screenHeight = MediaQuery.of(context).size.height;

    final double mapHeight = math.max(screenHeight, levelStates.length * 125.0);

    final levels = _buildLevelsFromState(levelStates);
    final positions = generatePositions(levelStates.length);
    final decorations = generateDecorations(positions);

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

                  // LOTTIE ANIMATSIYALARI (Eng tagda turishi uchun LevelButtonlardan oldin yoziladi)
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

                  // YUQORI QISM - SCORE VA AVATAR (Header)
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

                  // ASOSIY LEVEL TUGMALARI
                  ...levels.map((l) {
                    final px = l.dx * size.width;
                    final py = l.dy * size.height;

                    final isCurrent = l.id == currentLevelId;

                    return Positioned(
                      left: px - 40,
                      top: py - 40,
                      child: LevelButton(
                        level: l,
                        isCurrent: isCurrent,
                        onTap: () {
                          if (l.locked) return;

                          var lv = levelStates[l.id - 1];
                          var hasAbout = false;
                          if (lv.exercise != null &&
                              lv.exercise!.steps.isNotEmpty) {
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
                          } else if (lv.game != null) {
                            navigationTo(lv.game!.type);
                          } else if (lv.exercise != null) {
                            context.read<LevelProvider>().setCurrentLevel(
                              l.id - 1,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CameraPage(),
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
    );
  }

  void navigationTo(String type) {
    switch (type) {
      case "breath":
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => BreathPage()));
        break;
      case "arrow":
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => ArrowGamePage()));
        break;
      case "cloud":
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => CloudGamePage()));
        break;
      case "cooking":
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => CookingPage()));
        break;
      case "drag_drop":
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => DragDropGamePage()));
        break;
      case "find_image_page":
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => FindImageGamePage()));
        break;
      case "hand_game":
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => HandGamePage()));
        break;
      case "path_game":
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => MapRoadPage()));
        break;
      case "puzzle_game":
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => PuzzleGameWidget()));
    }
  }
}
