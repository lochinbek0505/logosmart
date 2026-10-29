import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/cv_model/camera_page.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/widgets/interactive_lottie.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/widgets/level_button.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/widgets/sliced_map_background.dart';
import 'package:logosmart/ui/pages/games/path_games/item_and_finish_path_game_page.dart';
// Video page importi qo'shildi
import 'package:logosmart/ui/pages/video_page/game_video_page.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../../../../core/service/app_settings.dart';
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
import '../sound_game/sound_game_page.dart';
import '../train_game/train_game_page.dart';
import '../wolf_game/wolf_game_page.dart';
import 'provider/level_provider.dart';
import 'start_text_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/subscription_offer_dialog.dart';

List<Offset> generatePositionsSin(int count) {
  return List.generate(count, (i) {
    final t = i / (count - 1);
    final dx = 0.5 + 0.3 * math.sin(t * math.pi * 2);
    final dy = 0.05 + 0.9 * (t * t);
    return Offset(dx.clamp(0.05, 0.95), dy.clamp(0.05, 0.95));
  });
}

class MapRoadPage extends StatelessWidget {
  MapRoadPage({
    super.key,
    this.sound = LevelProvider.defaultSound,
    this.embedded = false,
    this.scrollToCurrent = false,
  });

  /// Qaysi tovush xaritasi ochiladi ([LevelProvider.soundLevelFiles] kaliti)
  final String sound;

  /// Pastki menyu ichida (tab sifatida) ko'rsatilganda true:
  /// yopish tugmasi yashiriladi, pastda menyu uchun joy qoldiriladi.
  final bool embedded;

  /// true bo'lsa xarita ochilganda bola kelib qolgan levelga avtomatik suriladi
  final bool scrollToCurrent;

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
      return _MapRoadBody(
        sound: sound,
        embedded: embedded,
        scrollToCurrent: scrollToCurrent,
      );
    }
    return ChangeNotifierProvider<LevelProvider>(
      create: (_) => LevelProvider(autoBootstrap: false),
      child: _MapRoadBody(
        sound: sound,
        embedded: embedded,
        scrollToCurrent: scrollToCurrent,
      ),
    );
  }
}

class _MapRoadBody extends StatefulWidget {
  const _MapRoadBody({
    required this.sound,
    required this.embedded,
    required this.scrollToCurrent,
  });

  final String sound;
  final bool embedded;
  final bool scrollToCurrent;

  @override
  State<_MapRoadBody> createState() => _MapRoadBodyState();
}

class _MapRoadBodyState extends State<_MapRoadBody> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScrollController _scrollController = ScrollController();
  bool _didAutoScroll = false;

  // Tugma o'lchami (LevelButton va decor uchun offset -40 ishlatilgani uchun 80px deb olamiz)
  static const double _buttonHalfHeight = 40.0;
  static const double _headerContentHeight =
      150.0; // header balandligi (top:50 + ichki row balandligi)
  static const double _headerGap =
      20.0; // header va birinchi level orasidagi bo'shliq
  // Eng pastki tugmaning PASTKI CHEKKASIDAN keyin qoladigan bo'shliq — aniq 20px.
  // Muhim: SizedBox(height: mapHeight) ichidagi LayoutBuilder'ning constraints.maxHeight
  // har doim mapHeight ga TENG (chunki SizedBox uni majburlaydi), shuning uchun
  // dy = pikselQiymat / mapHeight => keyin size.height (== mapHeight) ga qaytadan
  // ko'paytirilganda floating-point xatosiz, bit-aniq holda pikselQiymat ga qaytadi.
  // Ya'ni fraction orqali hisoblash ham piksel darajasida aniq natija beradi.
  static const double _bottomSafeMargin = 20.0;
  // Tab ichida pastki menyu (84.h) xarita ustiga tushadi
  double get _bottomMargin =>
      widget.embedded ? _bottomSafeMargin + 100.0 : _bottomSafeMargin;

  // ===== KESH: faqat levelStates o'zgarsa qayta hisoblanadi =====
  List<Level>? _cachedLevels;
  List<DecorationItem>? _cachedDecorations;
  double? _cachedMapHeight;
  int?
  _cachedLevelsSignature; // levelStates ro'yxatining "imzosi" (id+locked+stars kombinatsiyasi)

  // LEVEL TUGMALARI JOYLASHUVI
  List<Offset> generatePositions(
    int count, {
    required double startY,
    required double endY,
  }) {
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

  List<Level> _buildLevelsFromState(
    List<LevelState> states,
    List<Offset> positions,
  ) {
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
    context.read<LevelProvider>().selectSound(widget.sound);
    initPage();
  }

  // LOTTIE ANIMATSIYALARI
  List<DecorationItem> generateDecorations(
    List<Offset> levelPositions,
    math.Random rnd,
  ) {
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
      sig =
          sig ^
          (s.id.hashCode) ^
          (s.locked.hashCode << 1) ^
          (s.stars.hashCode << 2);
    }
    return sig;
  }

  void _rebuildCacheIfNeeded(
    List<LevelState> levelStates,
    double screenHeight,
  ) {
    final signature = _signatureOf(levelStates);
    if (_cachedLevelsSignature == signature && _cachedMapHeight != null) {
      // Hech narsa o'zgarmagan — random qayta chaqirilmaydi, Lottie qayta yuklanmaydi
      return;
    }

    final double mapHeight = math.max(
      screenHeight,
      levelStates.length * 125.0 + _headerContentHeight + _bottomMargin,
    );

    final double startYPx = _headerContentHeight + _headerGap;
    final double endYPx = mapHeight - _buttonHalfHeight - _bottomMargin;

    final double startY = (startYPx / mapHeight).clamp(0.0, 1.0);
    final double endY = (endYPx / mapHeight).clamp(startY, 1.0);

    final positions = generatePositions(
      levelStates.length,
      startY: startY,
      endY: endY,
    );
    final levels = _buildLevelsFromState(levelStates, positions);
    // Bitta doimiy seed bilan random — shu tufayli decor joylashuvi har build da o'zgarmaydi
    final decorations = generateDecorations(positions, math.Random(42));

    _cachedLevelsSignature = signature;
    _cachedMapHeight = mapHeight;
    _cachedLevels = levels;
    _cachedDecorations = decorations;
  }

  Widget _buildEmptyState(BuildContext context) {
    final provider = context.watch<LevelProvider>();
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Mashg'ulotlar topilmadi. Internetni tekshiring yoki "
              "obunangiz faolligini ko'ring.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.refreshSound(widget.sound),
              child: const Text("Qayta urinish"),
            ),
          ],
        ),
      ),
    );
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

    _autoScrollToCurrentIfNeeded(
      levels,
      currentLevelId,
      mapHeight,
      screenHeight,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Fon alohida ListView da — faqat ko'rinib turgan bo'laklar yuklanadi
          Positioned.fill(
            child: SlicedMapBackground(
              controller: _scrollController,
              height: mapHeight,
            ),
          ),
          // Tovush mashqi levellari serverdan kelguncha / kelmasa
          if (levelStates.isEmpty && LevelProvider.isServerSound(widget.sound))
            Positioned.fill(child: _buildEmptyState(context)),
          SingleChildScrollView(
            controller: _scrollController,
            child: SizedBox(
              height: mapHeight,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );

                  return Stack(
                    clipBehavior: Clip.none,
                    // pastki tugma tasodifan kesilmasligi uchun qo'shimcha kafolat
                    children: [
                      ...decorations.map((decor) {
                        final px = decor.dx * size.width;
                        final py = decor.dy * size.height;
                        return Positioned(
                          key: ValueKey(
                            'decor_${decor.assetPath}_${decor.dx}_${decor.dy}',
                          ),
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
                              final lv = levelStates.firstWhere(
                                (e) => e.id == l.id,
                              );
                              // Pullik level, obuna yo'q — obunaga taklif
                              if (!lv.available) {
                                final provider = context.read<LevelProvider>();
                                if (await showSubscriptionOffer(context)) {
                                  await provider.refreshPractices();
                                  await provider.refreshSound(widget.sound);
                                }
                                return;
                              }
                              if (l.locked) return;

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

                              if (!context.mounted) return;

                              // YANGILIK: mode = "video" tekshiruvini qo'shdik
                              if (hasAbout) {
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
                                        "assets/icons/star.webp",
                                        scale: 3,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      levelStates
                                          .fold<int>(0, (p, e) => p + e.stars)
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: 35.sp,
                                        color: AppColors.orange_300,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Image.asset(
                                "assets/icons/circle_bad.webp",
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 25.0,
                                ),
                                child: widget.embedded
                                    ? const SizedBox(width: 50, height: 50)
                                    : GestureDetector(
                                        onTap: () =>
                                            Navigator.of(context).maybePop(),
                                        child: Image.asset(
                                          "assets/icons/close_red.webp",
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
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
        ],
      ),
    );
  }

  // Joriy level ekran o'rtasiga kelguncha xaritani suradi (faqat bir marta)
  void _autoScrollToCurrentIfNeeded(
    List<Level> levels,
    int currentLevelId,
    double mapHeight,
    double screenHeight,
  ) {
    if (!widget.scrollToCurrent || _didAutoScroll || levels.isEmpty) return;
    // Provider hali boshqa tovush levellarini ko'rsatayotgan bo'lishi mumkin
    if (context.read<LevelProvider>().currentSound != widget.sound) return;
    _didAutoScroll = true;

    final current = levels.firstWhere(
      (l) => l.id == currentLevelId,
      orElse: () => levels.first,
    );
    final targetCenter = current.dy * mapHeight;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final position = _scrollController.position;
      final offset = (targetCenter - screenHeight / 2).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOutCubic,
      );
    });
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
        break;
      case "train_game":
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const TrainGamePage()));
        break;
      case "sound_game":
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const SoundGamePage()));
        break;
      case "wolf_game":
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const WolfGamePage()));
        break;
    }
  }

  Future<void> initPage() async {
    AppSettings().addListener(_onSettingsChanged);
    if (!AppSettings().gameMusic) return;
    await _playLoopingAudio("sound/map/map_music.mp3");
  }

  // Sozlamalarda fon ovozi o'chirilsa darhol to'xtatamiz
  void _onSettingsChanged() {
    if (!AppSettings().gameMusic) _audioPlayer.stop();
  }

  Future<void> _playLoopingAudio(String path) async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource(path));
  }

  @override
  void dispose() {
    AppSettings().removeListener(_onSettingsChanged);
    _scrollController.dispose();
    super.dispose();
    _audioPlayer.dispose();
  }
}
