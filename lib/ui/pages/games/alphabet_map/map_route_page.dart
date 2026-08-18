import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/cv_model/camera_page.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/widgets/interactive_lottie.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/widgets/level_button.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/widgets/tiled_background.dart';
import 'package:logosmart/ui/pages/games/path_games/item_and_finish_path_game_page.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

// Video page importi qo'shildi
import 'package:logosmart/ui/pages/video_page/game_video_page.dart';

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
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Tugma o'lchami (LevelButton va decor uchun offset -40 ishlatilgani uchun 80px deb olamiz)
  static const double _buttonHalfHeight = 40.0;
  static const double _headerContentHeight = 150.0; // header balandligi (top:50 + ichki row balandligi)
  static const double _headerGap = 20.0; // header va birinchi level orasidagi bo'shliq
  // Eng pastki tugmaning PASTKI CHEKKASIDAN keyin qoladigan bo'shliq — aniq 20px.
  // Muhim: SizedBox(height: mapHeight) ichidagi LayoutBuilder'ning constraints.maxHeight
  // har doim mapHeight ga TENG (chunki SizedBox uni majburlaydi), shuning uchun
  // dy = pikselQiymat / mapHeight => keyin size.height (== mapHeight) ga qaytadan
  // ko'paytirilganda floating-point xatosiz, bit-aniq holda pikselQiymat ga qaytadi.
  // Ya'ni fraction orqali hisoblash ham piksel darajasida aniq natija beradi.
  static const double _bottomSafeMargin = 20.0;

  // ===== KESH: faqat levelStates o'zgarsa qayta hisoblanadi =====
  List<Level>? _cachedLevels;
  List<Offset>? _cachedPositions;
  List<DecorationItem>? _cachedDecorations;
  double? _cachedMapHeight;
  int? _cachedLevelsSignature; // levelStates ro'yxatining "imzosi" (id+locked+stars kombinatsiyasi)

  // LEVEL TUGMALARI JOYLASHUVI
  List<Offset> generatePositions(int count, {required double startY, required double endY}) {
    if (count <= 1) {
      return [Offset(0.5, startY)];
    }

    final stepY = (endY - startY) / (count - 1);

    const amplitude = 0.35;
    const frequency = 0.8;
    const phaseOffset = 4.0;

    return List.generate(count, (i) {
      final dy = startY + (stepY * i);
      final dx = 0.5 + (amplitude * math.sin((i * frequency) + phaseOffset));
      return Offset(dx.clamp(0.15, 0.85), dy);
    });
  }

  List<Level> _buildLevelsFromState(List<LevelState> states, List<Offset> positions) {
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
  void initState() {
    super.initState();
    initPage();
  }

  // LOTTIE ANIMATSIYALARI
  List<DecorationItem> generateDecorations(List<Offset> levelPositions, math.Random rnd) {
    final List<DecorationItem> decorations = [];
    final List<String> lottieAssets = [
      'assets/animation/map/box.json',
      'assets/animation/map/cute.json',
      'assets/animation/map/brchest.json',
      'assets/animation/map/rabbit.json',
      'assets/animation/map/chest.json',
    ];

    for (int i = 0; i < levelPositions.length - 1; i += 2) {
      final pos1 = levelPositions[i];
      final pos2 = levelPositions[i + 1];

      double decorDy = (pos1.dy + pos2.dy) / 2;
      double avgDx = (pos1.dx + pos2.dx) / 2;
      double decorDx;

      if (avgDx < 0.5) {
        decorDx = 0.75 + (rnd.nextDouble() * 0.15);
      } else {
        decorDx = 0.1 + (rnd.nextDouble() * 0.15);
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

  int _signatureOf(List<LevelState> states) {
    // Oddiy "imzo": ro'yxat uzunligi + har bir elementning id/locked/stars kombinatsiyasi
    int sig = states.length;
    for (final s in states) {
      sig = sig ^ (s.id.hashCode) ^ (s.locked.hashCode << 1) ^ (s.stars.hashCode << 2);
    }
    return sig;
  }

  void _rebuildCacheIfNeeded(List<LevelState> levelStates, double screenHeight) {
    final signature = _signatureOf(levelStates);
    if (_cachedLevelsSignature == signature && _cachedMapHeight != null) {
      // Hech narsa o'zgarmagan — random qayta chaqirilmaydi, Lottie qayta yuklanmaydi
      return;
    }

    final double mapHeight = math.max(
      screenHeight,
      levelStates.length * 125.0 + _headerContentHeight + _bottomSafeMargin,
    );

    final double startYPx = _headerContentHeight + _headerGap;
    final double endYPx = mapHeight - _buttonHalfHeight - _bottomSafeMargin;

    final double startY = (startYPx / mapHeight).clamp(0.0, 1.0);
    final double endY = (endYPx / mapHeight).clamp(startY, 1.0);

    final positions = generatePositions(levelStates.length, startY: startY, endY: endY);
    final levels = _buildLevelsFromState(levelStates, positions);
    // Bitta doimiy seed bilan random — shu tufayli decor joylashuvi har build da o'zgarmaydi
    final decorations = generateDecorations(positions, math.Random(42));

    _cachedLevelsSignature = signature;
    _cachedMapHeight = mapHeight;
    _cachedPositions = positions;
    _cachedLevels = levels;
    _cachedDecorations = decorations;
  }

  @override
  Widget build(BuildContext context) {
    final levelStates = context.watch<LevelProvider>().levels;
    final screenHeight = MediaQuery.of(context).size.height;

    _rebuildCacheIfNeeded(levelStates, screenHeight);

    final mapHeight = _cachedMapHeight!;
    final levels = _cachedLevels!;
    final decorations = _cachedDecorations!;

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
                clipBehavior: Clip.none, // pastki tugma tasodifan kesilmasligi uchun qo'shimcha kafolat
                children: [
                  Positioned.fill(
                    child: TiledBackground(
                      asset: 'assets/backround/map_background.png',
                      height: mapHeight,
                    ),
                  ),

                  ...decorations.map((decor) {
                    final px = decor.dx * size.width;
                    final py = decor.dy * size.height;
                    return Positioned(
                      key: ValueKey('decor_${decor.assetPath}_${decor.dx}_${decor.dy}'),
                      left: px - 40,
                      top: py - 40,
                      child: RepaintBoundary(
                        child: InteractiveLottie(
                          assetPath: decor.assetPath,
                          size: 80,
                        ),
                      ),
                    );
                  }),

                  // ASOSIY LEVEL TUGMALARI (Header dan OLDIN qo'yildi)
                  ...levels.map((l) {
                    final px = l.dx * size.width;
                    final py = l.dy * size.height;

                    final isCurrent = l.id == currentLevelId;

                    return Positioned(
                      key: ValueKey('level_${l.id}'),
                      left: px - 40,
                      top: py - _buttonHalfHeight,
                      child: LevelButton(
                        level: l,
                        isCurrent: isCurrent,
                        onTap: () async {
                          if (l.locked) return;

                          final lv = levelStates.firstWhere(
                                (e) => e.id == l.id,
                          );

                          context.read<LevelProvider>().openLevel(lv);

                          bool hasAbout = false;
                          if (lv.exercise != null &&
                              lv.exercise!.steps.isNotEmpty) {
                            hasAbout =
                                lv.exercise!.steps.first.action == "about";
                          }

                          // Diqqat: dispose() o'rniga pause() yozildi.
                          // Orqaga qaytishda kresh bo'lishini oldini oladi.
                          await _audioPlayer.pause();

                          // YANGILIK: mode = "video" tekshiruvini qo'shdik
                          if (hasAbout ) {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (b) => StartTextPage(data: lv),
                              ),
                            );
                          } else if (lv.mode == 'video') {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GameVideoPage(),
                              ),
                            );
                          } else if (lv.game != null) {
                            navigationTo(lv.game!.type);
                          } else if (lv.exercise != null) {
                            await Navigator.push(
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

                  // YUQORI QISM - SCORE VA AVATAR (Header)
                  // Eng oxirida — shuning uchun har doim levellar ustida ko'rinadi
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
        ).push(MaterialPageRoute(builder: (_) => ItemAndFinishPathGamePage()));
        break;
      case "puzzle_game":
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => PuzzleGameWidget()));
    }
  }

  Future<void> initPage() async {
    await _playLoopingAudio("sound/map/map_music.mp3");
  }

  Future<void> _playLoopingAudio(String path) async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource(path));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}