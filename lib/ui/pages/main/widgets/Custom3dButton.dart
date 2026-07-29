import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/games/alphabet_map/provider/level_provider.dart';
import 'package:provider/provider.dart';

class Custom3DButton extends StatefulWidget {
  const Custom3DButton({Key? key}) : super(key: key);

  @override
  State<Custom3DButton> createState() => _Custom3DButtonState();
}

class _Custom3DButtonState extends State<Custom3DButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 20),
      child: GestureDetector(
        // Bosganda (barmog'ingiz tekkanda)
        onTapDown: (_) {
          setState(() {
            _isPressed = true;
          });
        },
        // Qo'yib yuborganda (barmog'ingizni olganda)
        onTapUp: (_) async {
          setState(() {
            _isPressed = false;
          });
          var provider = Provider.of<LevelProvider>(context, listen: false);
          var ch = await provider.unlock();
          if (!ch) {
            // 1. Avval klaviaturani tushiramiz (muhim!)
            // FocusManager.instance.primaryFocus?.unfocus();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    // Orqa fon gradienti
                    gradient: const LinearGradient(
                      colors: [Color(0xff20B9E8), Color(0xff1E88E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff1E88E5).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    // MainAxisSize.min ni OLIB TASHLADIK, shunda u to'liq kenglikka yoyiladi
                    children: const [
                      Icon(
                        Icons.access_time_filled_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tez orada...",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Keyingi qismlar ustida ishlayapmiz",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                elevation: 0,
                // Marginni biroz kamaytirdik, juda tepaga chiqib ketmasligi uchun
                margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
                duration: const Duration(milliseconds: 2500),
              ),
            );
          }
          // ✅ Asosiy funksiya: Orqaga qaytish
          Navigator.pop(context);
        },
        // Agar bosib turib, barmog'ingizni chetga surib yuborsangiz
        onTapCancel: () {
          setState(() {
            _isPressed = false;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          width: size.width,
          // Ekranga moslashuvchan
          height: 65,
          // Biroz kattalashtirdim, sig'ishi uchun
          decoration: BoxDecoration(
            color: Colors.white, // Oq hoshiya (Border o'rnida)
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              // Ozgina soya qo'shdik (ixtiyoriy)
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: _isPressed
                ? _buildPressedState() // Bosilgan holat
                : _buildUnpressedState(),
          ), // Bosilmagan holat
        ),
      ),
    );
  }

  // 1. BOSILGAN HOLAT (Yassi ko'rinish)
  Widget _buildPressedState() {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        color: const Color(0xff20B9E8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(child: _buildButtonContent()),
    );
  }

  // 2. ODDIY HOLAT (3D effekt)
  Widget _buildUnpressedState() {
    return Container(
      padding: const EdgeInsets.only(bottom: 4),
      // Pastdagi "qalinlik"
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        color: const Color(0xff47809e), // To'qroq ko'k (soya qismi)
        borderRadius: BorderRadius.circular(30),
      ),
      child: Container(
        // Bu ichki qavat tepaga biroz siljiydi
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(29),
          gradient: const LinearGradient(
            colors: [
              Color(0xffbee9f7), // Och ko'k
              Color(0xff20B9E8), // Asosiy ko'k
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(child: _buildButtonContent()),
      ),
    );
  }

  // Tugma ichidagi Matn va Icon
  Widget _buildButtonContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Davom etish',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 20, // Dizaynga moslab sal kattalashtirdim
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        // SizedBox(width: 15),
        // Icon(Icons.navigate_next, color: Colors.white, size: 30),
      ],
    );
  }
}
