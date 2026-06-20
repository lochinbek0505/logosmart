import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/diagnostic/provider/voice_diagnostic_provider.dart';
import 'package:logosmart/ui/pages/main/soundpracrice/MapRoadPage.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

class AdviseAlphabetPage extends StatefulWidget {
  const AdviseAlphabetPage({super.key});

  @override
  State<AdviseAlphabetPage> createState() => _AdviseAlphabetPageState();
}

class _AdviseAlphabetPageState extends State<AdviseAlphabetPage> {
  bool _isPressed = false; // Tugma bosilishi effekti uchun

  // Asosiy mashqlar ro'yxati
  final List<Map<String, dynamic>> alphabet = [
    {"alphabet": "assets/alphabet/r.png", "text": "R", "number": 32},
    {"alphabet": "assets/alphabet/l.png", "text": "L", "number": 32},
    {"alphabet": "assets/alphabet/s.png", "text": "S", "number": 32},
    {"alphabet": "assets/alphabet/y.png", "text": "Y", "number": 32},
  ];

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<VoiceDiagnosticProvider>(context);
    var scores = provider.scores;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backround/fon_q.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // --- TEPADAGI APPBAR (Sarlavha) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Image.asset(
                        "assets/images/arow_back.png",
                        width: 24,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Tovush mashqlari",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.blueGrey.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- ASOSIY SKROLL QILINADIGAN QISM (Sliver usuli bilan) ---
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // 1. Asosiy ma'lumotlar (Karta va List)
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _buildMistakesCard(),
                          const SizedBox(height: 20),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: alphabet.length,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemBuilder: (context, index) {
                              var check = scores.any(
                                (element) =>
                                    element.sound == alphabet[index]["text"] &&
                                    !element.matchedSound,
                              );

                              return check
                                  ? AnimatedGameItem(
                                      index: index,
                                      child: _buildAlphabetCard(index),
                                    )
                                  // Bo'sh joylar xato chiqarmasligi uchun SizedBox.shrink() qilingan
                                  : const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),

                    // 2. Qolgan bo'sh joyni egallab, tugmani doim pastga itarib turuvchi qism
                    SliverFillRemaining(
                      hasScrollBody: false, // O'zi skroll bo'lmaydi
                      fillOverscroll: true,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(height: 30),
                          _buildContinueButton(),
                          const SizedBox(height: 40), // Xavfsiz bo'shliq
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================
  // QO'SHIMCHA WIDGET FUNKSIYALARI
  // ==============================

  Widget _buildMistakesCard() {
    var provider = Provider.of<VoiceDiagnosticProvider>(context);
    var scores = provider.scores;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.sky_blue_300, width: 3),
        boxShadow: const [
          BoxShadow(
            color: AppColors.sky_blue_400,
            offset: Offset(0, 5),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.psychology_alt_rounded,
                color: Color(0xff20B9E8),
                size: 36,
              ),
              SizedBox(width: 8),
              Text(
                "Kichik xatolar",
                style: TextStyle(
                  color: Color(0xff093e5e),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Quyidagi so'zlarda biroz adashdingiz.\nKel, ularni birga to'g'rilaymiz!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.blueGrey.shade700,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 10,
            children: scores.map((word) {
              return word.matchedSound
                  ? const SizedBox.shrink()
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffE1F8FD),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xff8EDCF2),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("🔄 ", style: TextStyle(fontSize: 14)),
                          Text(
                            word.matchedWord.toString().split(",")[0],
                            style: const TextStyle(
                              color: Color(0xff093e5e),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAlphabetCard(int index) {
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => MapRoadPage()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Bu qism bo'yicha ishlar davom etyabdi"),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Container(
          height: 115,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage("assets/backround/bacround_sound.png"),
              fit: BoxFit.fill,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.shade200.withOpacity(0.5),
                spreadRadius: 4,
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      gradient: const LinearGradient(
                        colors: [Color(0xffb5e9f7), Color(0xff5ad4f2)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                        color: Colors.cyan.shade50,
                      ),
                      child: Center(
                        child: Image.asset(
                          alphabet[index]["alphabet"],
                          height: 35,
                          width: 35,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${alphabet[index]["text"]} tovushini\nrivojlantirish",
                        style: const TextStyle(
                          color: Color(0xff093e5e),
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: const AssetImage(
                              "assets/icons/circle.png",
                            ),
                            radius: 15,
                            child: Transform.translate(
                              offset: const Offset(1, -1),
                              child: Image.asset(
                                "assets/icons/play.png",
                                width: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            "Boshlash",
                            style: TextStyle(
                              color: Color(0xff20B9E8),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 100,
                  height: 25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xffd9F6FB),
                  ),
                  child: Center(
                    child: Text(
                      "${alphabet[index]["number"]} ta mashg'ulot",
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff093e5e),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        Navigator.pop(context);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        padding: const EdgeInsets.all(5.5),
        width: 250,
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: _isPressed ? const Color(0xff20B9E8) : null,
            gradient: _isPressed
                ? null
                : const LinearGradient(
                    colors: [Color(0xffbee9f7), Color(0xff20B9E8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
            boxShadow: _isPressed
                ? []
                : const [
                    BoxShadow(
                      color: Color(0xff47809e),
                      offset: Offset(0, 3.5),
                      blurRadius: 0,
                      spreadRadius: 0,
                    ),
                  ],
          ),
          child: const Center(
            child: Text(
              "DAVOM ETISH",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedGameItem extends StatefulWidget {
  final int index;
  final Widget child;

  const AnimatedGameItem({Key? key, required this.index, required this.child})
    : super(key: key);

  @override
  State<AnimatedGameItem> createState() => _AnimatedGameItemState();
}

class _AnimatedGameItemState extends State<AnimatedGameItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 150 * widget.index), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
      ),
    );
  }
}
