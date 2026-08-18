
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// 3D animatsiyali Start tugmasi
class AnimatedStartButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const AnimatedStartButton({super.key,required this.text, required this.onTap});

  @override
  State<AnimatedStartButton> createState() => _AnimatedStartButtonState();
}

class _AnimatedStartButtonState extends State<AnimatedStartButton> {
  bool _isPressed = false;

  void _handleTap() async {
    if (_isPressed) return;

    setState(() => _isPressed = true);
    await Future.delayed(const Duration(milliseconds: 160));
    if (mounted) setState(() => _isPressed = false);

    widget.onTap(); // Asosiy vazifani bajarish
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        width: width * 0.8,
        height: 65.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
        ),
        child: _isPressed ? _buildPressedState() : _buildDefaultState(width),
      ),
    );
  }

  Widget _buildPressedState() {
    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        color: const Color(0xff20B9E8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(child: _buildText()),
    );
  }

  Widget _buildDefaultState(double width) {
    return Container(
      padding: const EdgeInsets.only(bottom: 3),
      height: 60.h,
      decoration: BoxDecoration(
        color: const Color(0xff47809e),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(29),
          gradient: const LinearGradient(
            colors: [Color(0xffbee9f7), Color(0xff20B9E8)],
            end: Alignment.bottomCenter,
            begin: Alignment.topCenter,
          ),
        ),
        child: Center(child: _buildText()),
      ),
    );
  }

  Widget _buildText() {
    return Text(
      widget.text,
      style: GoogleFonts.nunito(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 22.sp,
      ),
    );
  }
}
