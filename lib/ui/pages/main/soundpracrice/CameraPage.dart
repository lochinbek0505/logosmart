import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logosmart/ui/widgets/AICamera.dart';
import 'package:provider/provider.dart';

import '../../../../core/storage/level_state.dart';
import '../../../../providers/level_provider.dart';

class CameraPage extends StatefulWidget {
  final LevelState data;

  const CameraPage({super.key, required this.data});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

enum _SeqState { idle, waiting, success, fail }

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {

  Key _camKey = UniqueKey();

  bool _cameraActive = true;

  Color _camBorderColor = const Color(0xff20B9E8);

  late List<String> _sequence;

  int _idx = 0;

  int _errors = 0;

  static const Duration _acceptCooldown = Duration(milliseconds: 600);

  DateTime? _lastAcceptedAt;

  _SeqState _seqState = _SeqState.idle;

  DateTime? _lastToastAt;

  // ====== Yangi: barqaror qabul qilish (histerezis + voting + timeout) sozlamalari ======
  static const int _windowMs = 800;          // slayding oyna (so'ngi N ms)

  static const int _minHoldMs = 300;         // expected kamida shuncha vaqt oynada bor bo'lsin

  static const int _stepTimeoutMs = 5000;    // bitta bosqich uchun maksimal kutish

  static const int _minVotes = 1;            // oynada expected kamida necha martta ko'rinsin

  static const double _minAvgConf = 0.50;    // expectedning o'rtacha ishonch minimal qiymati


  late DateTime _stepStartAt;                // joriy bosqich boshlanish vaqti
  final _VoteWindow _vote = _VoteWindow(windowMs: _windowMs);
  String? _lastAcceptedLabel;                // ketma-ket bir xil qabulni throttling

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final steps = widget.data.exercise!.steps;
    steps.removeAt(0);
    _sequence = steps
        .map((s) => _normalizeUz(s.action.toString()))
        .where((a) => a.isNotEmpty)
        .toList();
    if (_sequence.length > 4) {
      _sequence = _sequence.take(4).toList();
    }

    _seqState = _SeqState.waiting;
    _setBorderNormal();

    // Yangi step boshlanishi
    _stepStartAt = DateTime.now();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    _safeStopCameraAndRemount();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      if (_cameraActive) {
        setState(() => _cameraActive = false);
      }
    } else if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() {
            _camKey = UniqueKey();
            _cameraActive = true;
          });
        }
      });
    }
  }

  void _safeStopCameraAndRemount() {
    if (!mounted) return;
    setState(() => _cameraActive = false);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() {
        _camKey = UniqueKey();
        _cameraActive = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        if (mounted) setState(() => _cameraActive = false);
        return true;
      },
      child: Scaffold(
        body: SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/backround_xira.png"),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                          onTap: () {
                            if (mounted) setState(() => _cameraActive = false);
                            Navigator.of(context).pop();
                          },
                          child: Image.asset(
                            "assets/icons/arrow_right_button.png",
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Image.asset("assets/icons/star.png", width: 40, height: 40),
                          const SizedBox(width: 12),
                          Image.asset("assets/icons/namber_o.png", height: 35),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: size.width, height: 150),
                  // Namoyish gif/rasm (mashq namunasi)
                  Container(
                    width: size.width * 0.6,
                    height: size.width * 0.6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xff20B9E8), width: 3),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        color: Colors.white,
                        image: DecorationImage(
                          image: AssetImage(widget.data.exercise!.mediaPath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Kamera oynasi
                  Container(
                    width: size.width * 0.6,
                    height: size.width * 0.6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: _camBorderColor, width: 3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(19),
                      child: _cameraActive
                          ? AICamera(
                        key: _camKey,
                        modelPath: widget.data.exercise!.modelPath,
                        labelsPath: widget.data.exercise!.labelsPath,
                        useGpu: true,
                        numThreads: 2,
                        lensDirection: CameraLensDirection.front,
                        intervalMs: 450,
                        iouThreshold: 0.45,
                        confThreshold: 0.35,
                        classThreshold: 0.5,
                        onDetections: _onDetections,
                      )
                          : const _SuccessGifPlaceholder(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === Detections (barqaror qabul qilish bilan) ===

  void _onDetections(List<Map<String, dynamic>> results, Size imgSize) {
    if (!mounted || results.isEmpty) return;
    if (_seqState == _SeqState.success) return;

    // Eng ishonchli obyekt
    Map<String, dynamic>? best;
    double bestConf = -1;
    for (final r in results) {
      final conf = _extractConfidence(r);
      if (conf > bestConf) {
        bestConf = conf;
        best = r;
      }
    }
    if (best == null) return;

    final tag = _normalizeUz(_extractLabel(best));
    if (tag.isEmpty) return;

    _maybeToast(tag);

    final expected = (_idx < _sequence.length) ? _sequence[_idx] : null;
    if (expected == null) return;

    final now = DateTime.now();

    _vote.add(label: tag, conf: bestConf, at: now);

    final votesForExpected = _vote.countLabel(expected);
    final avgConfExpected = _vote.avgConf(expected);
    final expectedFirstSeen = _vote.firstSeen(expected);

    final hasMinVotes = votesForExpected >= _minVotes;
    final hasMinConf = avgConfExpected >= _minAvgConf;
    final heldLongEnough = expectedFirstSeen != null &&
        now.difference(expectedFirstSeen) >= Duration(milliseconds: _minHoldMs);

    if (hasMinVotes && hasMinConf && heldLongEnough) {

      if (_lastAcceptedLabel == expected &&
          _lastAcceptedAt != null &&
          now.difference(_lastAcceptedAt!) < _acceptCooldown) {
        return;
      }

      _lastAcceptedAt = now;
      _lastAcceptedLabel = expected;

      _idx++;
      _seqState = _SeqState.waiting;
      _setBorderGreen();

      _vote.clear();
      _stepStartAt = now;

      if (_idx >= _sequence.length) {
        _seqState = _SeqState.success;
        if (mounted) {
          setState(() => _cameraActive = false);
        }
        _showSuccessDialog();
        return;
      }

      // Yashil chetni qaytarish
      Future.delayed(const Duration(milliseconds: 250), () {
        if (!mounted || _seqState == _SeqState.success) return;
        _setBorderNormal();
      });
      return;
    }

    // Timeout: expected barqarorlasha olmasa, bitta xato va keyingi stepga o'tish
    if (now.difference(_stepStartAt) >= Duration(milliseconds: _stepTimeoutMs)) {
      _errors += 1; // ❗ faqat shu yerda xato qo'shiladi
      _seqState = _SeqState.waiting;
      _setBorderRed();

      // Keyingi bosqich
      _idx = (_idx + 1).clamp(0, _sequence.length);
      _vote.clear();
      _stepStartAt = now;

      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted || _seqState == _SeqState.success) return;
        _setBorderNormal();
      });
    }

    // Diqqat: tag != expected bo'lsa darhol xato sanalmaydi — kutamiz.
  }

  double _extractConfidence(Map<String, dynamic> r) {
    // AICamera’dan kelishi mumkin bo‘lgan turli nomlar
    final candidates = [
      r['confidence'],
      r['score'],
      r['conf'],
      if (r['box'] is List && (r['box'] as List).length > 4) (r['box'] as List)[4],
    ];
    for (final c in candidates) {
      if (c is num) return c.toDouble();
    }
    return 0.0;
  }

  String _extractLabel(Map<String, dynamic> r) {
    // Model turiga qarab turli maydonlar bo‘lishi mumkin
    final candidates = [
      r['tag'],
      r['label'],
      r['className'],
      r['cls'],
      r['name'],
      r['class'],
    ];
    for (final c in candidates) {
      if (c != null) return c.toString();
    }
    return '';
  }

  // === UI ranglar ===

  void _setBorderNormal() {
    if (mounted) setState(() => _camBorderColor = const Color(0xff20B9E8));
  }

  void _setBorderGreen() {
    if (mounted) setState(() => _camBorderColor = Colors.green);
  }

  void _setBorderRed() {
    if (mounted) setState(() => _camBorderColor = Colors.red);
  }

  // === Dialog & yulduzlar ===

  Future<void> _showSuccessDialog() async {
    final prov = context.read<LevelProvider>();
    final locked = prov.levels.firstWhere(
          (e) => e.locked,
      orElse: () => prov.levels.last,
    );

    int stars = 3;
    if (_errors == 1) {
      stars = 2;
    } else if (_errors > 1) {
      stars = 1;
    }

    prov.unlock(locked.id, stars);
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  "https://i.pinimg.com/originals/4a/10/e3/4a10e39ee8325a06daf00881ac321b2f.gif",
                  fit: BoxFit.cover,
                  width: 160,
                  height: 120,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Ketma-ketlik bajarildi (${_sequence.length} bosqich). Xatolar: $_errors",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("OK", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === Normalizatsiya & Toast ===

  String _normalizeUz(String s) {
    var t = s.toLowerCase();
    t = t
        .replaceAll('’', "'")
        .replaceAll('ʼ', "'")
        .replaceAll('‘', "'")
        .replaceAll('`', "'")
        .replaceAll('ʻ', "'")
        .replaceAll('´', "'");
    t = t
        .replaceAll("o'", "o")
        .replaceAll("g'", "g")
        .replaceAll("o‘", "o")
        .replaceAll("g‘", "g");
    t = t.replaceAll(RegExp(r'\s+|\.'), '');
    return t;
  }

  void _maybeToast(String msg) {
    final now = DateTime.now();
    if (_lastToastAt == null || now.difference(_lastToastAt!) > const Duration(milliseconds: 900)) {
      _lastToastAt = now;
      Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}

// ====== Yordamchi: slayding oyna voting ======

class _VoteWindow {
  final int windowMs;
  final List<_Hit> _hits = [];

  _VoteWindow({required this.windowMs});

  void add({required String label, required double conf, required DateTime at}) {
    _hits.add(_Hit(label, conf, at));
    _trim(at);
  }

  void _trim(DateTime now) {
    final cutoff = now.subtract(Duration(milliseconds: windowMs));
    while (_hits.isNotEmpty && _hits.first.at.isBefore(cutoff)) {
      _hits.removeAt(0);
    }
  }

  int countLabel(String label) => _hits.where((h) => h.label == label).length;

  double avgConf(String label) {
    final list = _hits.where((h) => h.label == label).toList();
    if (list.isEmpty) return 0.0;
    final sum = list.fold<double>(0.0, (a, b) => a + b.conf);
    return sum / list.length;
  }

  DateTime? firstSeen(String label) {
    for (final h in _hits) {
      if (h.label == label) return h.at;
    }
    return null;
  }

  String? topLabel() {
    if (_hits.isEmpty) return null;
    final counts = <String, int>{};
    for (final h in _hits) {
      counts[h.label] = (counts[h.label] ?? 0) + 1;
    }
    if (counts.isEmpty) return null;
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  void clear() => _hits.clear();
}

class _Hit {
  final String label;
  final double conf;
  final DateTime at;
  _Hit(this.label, this.conf, this.at);
}

// ====== Kamera o'chganda ko'rsatiladigan placeholder ======

class _SuccessGifPlaceholder extends StatelessWidget {
  const _SuccessGifPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              "https://i.pinimg.com/originals/4a/10/e3/4a10e39ee8325a06daf00881ac321b2f.gif",
              fit: BoxFit.cover,
              width: 160,
              height: 120,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Yakunlandi",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
