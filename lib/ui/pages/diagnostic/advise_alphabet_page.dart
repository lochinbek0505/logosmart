import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/main/soundpracrice/MapRoadPage.dart';

class AdviseAlphabetPage extends StatefulWidget {
  const AdviseAlphabetPage({super.key});

  @override
  State<AdviseAlphabetPage> createState() => _AdviseAlphabetPageState();
}

class _AdviseAlphabetPageState extends State<AdviseAlphabetPage> {
  final List<Map<String, dynamic>> alphabet = [
    {"alphabet": "assets/alphabet/r.png", "text": "R", "number": 32},
    {"alphabet": "assets/alphabet/l.png", "text": "L", "number": 32},
    {"alphabet": "assets/alphabet/s.png", "text": "S", "number": 32},
    {"alphabet": "assets/alphabet/y.png", "text": "Y", "number": 32},
  ];

  @override
  Widget build(BuildContext context) {
    // var size = MediaQuery.of(context).size; // Hozircha ishlatilmagan
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/backround/fon_q.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 60, width: double.infinity),
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
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: alphabet.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, index) {
                    // Animatsiya wrapperiga index va UI qismini uzatamiz
                    return AnimatedGameItem(
                      index: index,
                      child: GestureDetector(
                        onTap: () {
                          if (index == 0) {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) =>  MapRoadPage()),
                            );
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
                                /// Left side
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
                                              backgroundImage: const AssetImage("assets/icons/circle.png"),
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

                                /// Right side
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
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Decoupled Animation Component
/// ListView builder ichida har bir element mount bo'lganda o'z-o'zidan animatsiyani boshqaradi.
class AnimatedGameItem extends StatefulWidget {
  final int index;
  final Widget child;

  const AnimatedGameItem({
    Key? key,
    required this.index,
    required this.child,
  }) : super(key: key);

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

    // Controller Lifecycle
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Bounce/Overshoot effekti (O'yinlarga xos)
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    // Yon tomondan siljib kirish
    _slideAnimation = Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    // Staggering (Kechikish mexanizmi).
    // Har bir keyingi element 150ms kechikib chiqadi (Cascade effect).
    Future.delayed(Duration(milliseconds: 150 * widget.index), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Memory leak oldini olish
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}