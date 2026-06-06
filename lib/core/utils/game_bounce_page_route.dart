import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class GameBouncePageRoute extends PageRouteBuilder {
  final Widget page;

  // Customization uchun audio fayl manzilini parameter sifatida olamiz
  final String audioAssetPath;

  GameBouncePageRoute({
    required this.page,
    this.audioAssetPath = 'sound/navigation.mp3', // Default ovoz
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionDuration: const Duration(milliseconds: 900),
         reverseTransitionDuration: const Duration(milliseconds: 400),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
             CurvedAnimation(parent: animation, curve: Curves.elasticOut),
           );

           final rotationAnimation = Tween<double>(begin: -0.03, end: 0.0)
               .animate(
                 CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
               );

           final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
             CurvedAnimation(
               parent: animation,
               curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
             ),
           );

           return FadeTransition(
             opacity: fadeAnimation,
             child: ScaleTransition(
               scale: scaleAnimation,
               child: RotationTransition(
                 turns: rotationAnimation,
                 child: child,
               ),
             ),
           );
         },
       );

  @override
  TickerFuture didPush() {
    _playTransitionSound();

    return super.didPush();
  }

  // Mustaqil I/O operatsiyasi
  Future<void> _playTransitionSound() async {
    final player = AudioPlayer();

    // Ovoz chalishni boshlash (Asinxron)
    await player.play(AssetSource(audioAssetPath));

    player.onPlayerComplete.listen((_) {
      player.dispose();
    });
  }
}
