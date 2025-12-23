import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final VoidCallback onBack;

  const TopBar({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Orqaga qaytish
            SizedBox(
              width: 50,
              height: 50,
              child: GestureDetector(
                onTap: onBack,
                child: Image.asset(
                  "assets/icons/arrow_right_button.png",
                  fit: BoxFit.fill,
                ),
              ),
            ),
            // Yulduzlar
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
    );
  }
}
