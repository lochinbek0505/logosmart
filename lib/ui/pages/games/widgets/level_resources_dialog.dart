import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/core/network/network_status.dart';
import 'package:logosmart/core/resources/level_resources.dart';
import 'package:logosmart/core/resources/resource_manager.dart';
import 'package:logosmart/core/storage/level_state.dart';
import 'package:logosmart/ui/pages/games/widgets/kid_widgets.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:logosmart/ui/theme/app_theme.dart';

/// Level ochishdan oldin: uning fayllari qurilmada bo'lmasa (birinchi yuklash o'tkazib
/// yuborilgan, video hali orqa fonda yuklanmagan va h.k.) — shu yerda yuklab olinadi.
/// Hammasi tayyor bo'lsa true; yuklab bo'lmasa (internet yo'q) false.
Future<bool> prepareLevelResources(
  BuildContext context,
  LevelState level,
) async {
  final manager = ResourceManager.instance;
  final paths = resourcePathsOfLevel(level);
  if (paths.isEmpty) return true;
  if (manager.hasManifest && manager.missingOf(paths).isEmpty) return true;

  final ok = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'level_resources',
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 550),
    pageBuilder: (_, _, _) => _LevelResourcesDialog(paths: paths),
    transitionBuilder: (_, anim, _, child) => FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
        child: ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
          child: child,
        ),
      ),
    ),
  );
  return ok == true;
}

enum _Phase { loading, done, failed }

/// Yuklanayotgan fayl turi — sahna va matnlarda ko'rsatiladi
enum _Kind { video, sound, image, other }

_Kind _kindOf(String path) {
  final p = path.toLowerCase();
  if (p.endsWith('.mp4') || p.endsWith('.mov') || p.endsWith('.webm')) {
    return _Kind.video;
  }
  if (p.endsWith('.mp3') || p.endsWith('.wav') || p.endsWith('.m4a')) {
    return _Kind.sound;
  }
  if (p.endsWith('.webp') || p.endsWith('.png') || p.endsWith('.jpg')) {
    return _Kind.image;
  }
  return _Kind.other;
}

const _kindIcons = {
  _Kind.video: Icons.movie_rounded,
  _Kind.sound: Icons.music_note_rounded,
  _Kind.image: Icons.image_rounded,
  _Kind.other: Icons.auto_awesome_rounded,
};

const _kindColors = {
  _Kind.video: Color(0xFFFF7043),
  _Kind.sound: Color(0xFFAB47BC),
  _Kind.image: Color(0xFF43A047),
  _Kind.other: Color(0xFF0096B5),
};

const _kindPhrases = {
  _Kind.video: "Video tayyorlanmoqda...",
  _Kind.sound: "Ovozlar yig'ilmoqda...",
  _Kind.image: "Rasmlar bo'yalmoqda...",
  _Kind.other: "Sehrli narsalar tayyorlanmoqda...",
};

class _LevelResourcesDialog extends StatefulWidget {
  const _LevelResourcesDialog({required this.paths});

  final Set<String> paths;

  @override
  State<_LevelResourcesDialog> createState() => _LevelResourcesDialogState();
}

class _LevelResourcesDialogState extends State<_LevelResourcesDialog> {
  int _done = 0;
  int _total = 0;
  _Phase _phase = _Phase.loading;

  /// Yuklanadigan fayllar turi bo'yicha soni (chiplar va almashuvchi matnlar)
  late final Map<_Kind, int> _counts;
  late final List<_Kind> _kinds;

  /// Sahnada aylanib turadigan joriy tur va matn
  int _tick = 0;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    final manager = ResourceManager.instance;
    final pending = manager.hasManifest
        ? manager.missingOf(widget.paths)
        : widget.paths;
    _counts = {};
    for (final p in pending) {
      final k = _kindOf(p);
      _counts[k] = (_counts[k] ?? 0) + 1;
    }
    _kinds = [
      for (final k in [_Kind.video, _Kind.sound, _Kind.image, _Kind.other])
        if ((_counts[k] ?? 0) > 0) k,
    ];
    if (_kinds.isEmpty) _kinds.add(_Kind.other);
    _ticker = Timer.periodic(const Duration(milliseconds: 2200), (_) {
      if (mounted && _phase == _Phase.loading) setState(() => _tick++);
    });
    NetworkStatus.instance.addListener(_onNetwork);
    _run();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    NetworkStatus.instance.removeListener(_onNetwork);
    super.dispose();
  }

  /// Internet qaytsa bola tugma bosishini kutmasdan qayta uriniladi
  void _onNetwork() {
    if (_phase == _Phase.failed && NetworkStatus.instance.isOnline) _run();
  }

  Future<void> _run() async {
    setState(() {
      _phase = _Phase.loading;
      _done = 0;
      _total = 0;
    });
    final ok = await ResourceManager.instance.ensureAll(
      widget.paths,
      onProgress: (done, total) {
        if (!mounted) return;
        setState(() {
          _done = done;
          _total = total;
        });
      },
    );
    if (!mounted) return;
    if (!ok) {
      setState(() => _phase = _Phase.failed);
      return;
    }
    // Qisqa "Tayyor!" bayrami, keyin o'yin ochiladi
    setState(() => _phase = _Phase.done);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) Navigator.of(context).pop(true);
  }

  _Kind get _currentKind => _kinds[_tick % _kinds.length];

  String get _title => switch (_phase) {
    _Phase.done => "Hammasi tayyor!",
    _Phase.failed => "Voy! Internet charchab qoldi",
    _Phase.loading =>
      _total > 0 && _done / _total >= 0.8
          ? "Deyarli yetib keldik!"
          : "Mashg'ulot yo'lda!",
  };

  String get _subtitle => switch (_phase) {
    _Phase.done => "Qani, o'ynaymiz!",
    _Phase.failed =>
      "Internetni tekshirib, yana bir bor urinib ko'ramiz. "
          "Internet qaytsa o'zim davom ettiraman!",
    _Phase.loading => _kindPhrases[_currentKind]!,
  };

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final double? progress = _phase == _Phase.done
        ? 1
        : (_total == 0 ? null : _done / _total);
    final percent = ((progress ?? 0) * 100).round();

    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34.r),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: dark ? 0.1 : 1),
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(34.r),
                ),
                child: KidSkyBackground(
                  dark: dark,
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: KidTwinkleStars(
                          positions: [
                            Alignment(-0.85, -0.85),
                            Alignment(0.8, -0.7),
                            Alignment(-0.9, 0.1),
                            Alignment(0.9, 0.25),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 20.h),
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 170.h,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 450),
                                  transitionBuilder: (c, a) => ScaleTransition(
                                    scale: CurvedAnimation(
                                      parent: a,
                                      curve: Curves.elasticOut,
                                    ),
                                    child: FadeTransition(opacity: a, child: c),
                                  ),
                                  child: switch (_phase) {
                                    _Phase.loading => _DeliveryScene(
                                      key: const ValueKey('load'),
                                      kind: _currentKind,
                                    ),
                                    _Phase.done => const _DoneScene(
                                      key: ValueKey('done'),
                                    ),
                                    _Phase.failed => const KidRainCloud(
                                      key: ValueKey('fail'),
                                    ),
                                  },
                                ),
                              ),
                              SizedBox(height: 6.h),
                              _SwitchText(
                                text: _title,
                                style: GoogleFonts.nunito(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w900,
                                  color: context.palette.textStrong,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              _SwitchText(
                                text: _subtitle,
                                style: GoogleFonts.nunito(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: context.palette.textPrimary,
                                ),
                              ),
                              SizedBox(height: 14.h),
                              if (_phase != _Phase.failed) ...[
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 6.w,
                                  runSpacing: 6.h,
                                  children: [
                                    for (final k in _kinds)
                                      if ((_counts[k] ?? 0) > 0 &&
                                          k != _Kind.other)
                                        KidInfoChip(
                                          icon: _kindIcons[k]!,
                                          color: _kindColors[k]!,
                                          text: switch (k) {
                                            _Kind.video =>
                                              "${_counts[k]} video",
                                            _Kind.sound => "${_counts[k]} ovoz",
                                            _ => "${_counts[k]} rasm",
                                          },
                                        ),
                                  ],
                                ),
                                SizedBox(height: 14.h),
                                KidProgressBar(value: progress),
                                SizedBox(height: 10.h),
                                _PercentBubble(
                                  text: _phase == _Phase.done
                                      ? "100%"
                                      : (_total == 0 ? "..." : "$percent%"),
                                ),
                              ] else ...[
                                SizedBox(
                                  width: double.infinity,
                                  child: KidBounceButton(
                                    label: "Qayta urinish",
                                    leading: Icon(
                                      Icons.refresh_rounded,
                                      color: Colors.white,
                                      size: 22.sp,
                                    ),
                                    onPressed: _run,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(
                                    "Keyinroq",
                                    style: GoogleFonts.nunito(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w800,
                                      color: context.palette.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Matn almashganda yumshoq sakrab almashadi
class _SwitchText extends StatelessWidget {
  const _SwitchText({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (c, a) => FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.4),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)),
          child: c,
        ),
      ),
      child: Text(
        text,
        key: ValueKey(text),
        textAlign: TextAlign.center,
        style: style,
      ),
    );
  }
}

/// Foiz — oq pufak ichida, har o'zgarganda "pop" qiladi
class _PercentBubble extends StatelessWidget {
  const _PercentBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.main_blue_700.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (c, a) => ScaleTransition(
          scale: CurvedAnimation(parent: a, curve: Curves.elasticOut),
          child: c,
        ),
        child: Text(
          text,
          key: ValueKey(text),
          style: GoogleFonts.nunito(
            fontSize: 22.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.main_blue_700,
          ),
        ),
      ),
    );
  }
}

/// Yuklanish sahnasi: vertolyot arqonda sovg'a qutisini olib kelyapti, qutidan
/// joriy fayl turining belgilari (nota, kino, rasm) uchib chiqadi.
class _DeliveryScene extends StatefulWidget {
  const _DeliveryScene({super.key, required this.kind});

  final _Kind kind;

  @override
  State<_DeliveryScene> createState() => _DeliverySceneState();
}

class _DeliverySceneState extends State<_DeliveryScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _kindColors[widget.kind]!;
    final icon = _kindIcons[widget.kind]!;
    final double heli = 116.w;
    final double box = 54.w;
    final double rope = 34.h;

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final a = _c.value * 2 * math.pi;
        final bob = math.sin(a) * 6; // vertolyot suzishi
        final swing = math.sin(a * 1.0 + 0.8) * 0.18; // qutining tebranishi

        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Qutidan uchib chiqadigan belgilar
            for (var i = 0; i < 3; i++)
              _floatingIcon(
                t: (_c.value + i / 3) % 1,
                dx: (i - 1) * 34.w,
                top: bob + heli * 0.55 + rope + box * 0.2,
                icon: icon,
                color: color,
              ),
            Transform.translate(
              offset: Offset(0, bob),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.rotate(
                    angle: math.cos(a) * 0.05,
                    child: Image.asset(
                      "assets/icons/helicopter.webp",
                      width: heli,
                      height: heli * 0.6,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Arqon va quti — arqon tepasidan tebranadi
                  Transform.rotate(
                    angle: swing,
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 3,
                          height: rope,
                          color: const Color(0xFF8D6E63),
                        ),
                        _GiftBox(size: box, color: color, icon: icon),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _floatingIcon({
    required double t,
    required double dx,
    required double top,
    required IconData icon,
    required Color color,
  }) {
    // Pastdan tepaga ko'tarilib, yon tomonga tarqaladi va so'nadi
    final rise = t * 70.h;
    final opacity = t < 0.15 ? t / 0.15 : (1 - t).clamp(0.0, 1.0);
    return Positioned(
      top: top - rise,
      child: Transform.translate(
        offset: Offset(dx * t * 1.6, 0),
        child: Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: 0.6 + t * 0.6,
            child: Icon(icon, color: color, size: 22.sp),
          ),
        ),
      ),
    );
  }
}

/// Lentali sovg'a qutisi, ichida fayl turi belgisi
class _GiftBox extends StatelessWidget {
  const _GiftBox({required this.size, required this.color, required this.icon});

  final double size;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lenta
          Container(
            width: size * 0.16,
            color: Colors.white.withValues(alpha: 0.85),
          ),
          Container(
            height: size * 0.16,
            color: Colors.white.withValues(alpha: 0.85),
          ),
          Container(
            width: size * 0.5,
            height: size * 0.5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: size * 0.32),
          ),
        ],
      ),
    );
  }
}

/// "Tayyor!" — katta yashil belgi va atrofga sochiluvchi yulduzlar
class _DoneScene extends StatefulWidget {
  const _DoneScene({super.key});

  @override
  State<_DoneScene> createState() => _DoneSceneState();
}

class _DoneSceneState extends State<_DoneScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = Curves.easeOut.transform(_c.value);
        final pop = Curves.elasticOut.transform(_c.value);
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            for (var i = 0; i < 8; i++)
              Transform.translate(
                offset: Offset.fromDirection(i * math.pi / 4, 30.w + t * 55.w),
                child: Opacity(
                  opacity: (1 - t).clamp(0.0, 1.0),
                  child: Transform.rotate(
                    angle: t * 2,
                    child: Image.asset(
                      "assets/icons/star_orange.webp",
                      width: 22.w,
                      height: 22.w,
                    ),
                  ),
                ),
              ),
            Transform.scale(
              scale: pop,
              child: Container(
                width: 96.w,
                height: 96.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF43A047),
                  border: Border.all(color: Colors.white, width: 5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF43A047).withValues(alpha: 0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 60.sp,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
