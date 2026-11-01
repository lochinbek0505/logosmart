import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';

import 'resource_manager.dart';

/// Asset o'rniga ishlatiladigan helper'lar: avval serverdan yuklab olingan fayl
/// (<AppSupport>/resources/<yo'l>), u bo'lmasa — APK ichidagi asset.
/// Yo'l "assets/game/x.webp" yoki "sound/x.mp3" ko'rinishida bo'lishi mumkin.
class AppImage {
  AppImage._();

  /// [Image.asset] bilan bir xil parametrlar
  static Widget asset(
    String path, {
    Key? key,
    double? width,
    double? height,
    BoxFit? fit,
    Color? color,
    BlendMode? colorBlendMode,
    AlignmentGeometry alignment = Alignment.center,
    double? scale,
    ImageErrorWidgetBuilder? errorBuilder,
    bool gaplessPlayback = false,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    final file = ResourceManager.instance.fileFor(path);
    if (file != null) {
      return Image.file(
        file,
        key: key,
        width: width,
        height: height,
        fit: fit,
        color: color,
        colorBlendMode: colorBlendMode,
        alignment: alignment,
        scale: scale ?? 1.0,
        // Yuklangan fayl ochilmasa (buzilgan/yo'qolgan) — qayta yuklashga qo'yiladi,
        // hozircha APK ichidagi nusxa ko'rsatiladi
        errorBuilder: (context, error, stack) {
          ResourceManager.instance.reportBroken(path);
          return Image.asset(
            normalizeResourcePath(path),
            width: width,
            height: height,
            fit: fit,
            color: color,
            colorBlendMode: colorBlendMode,
            alignment: alignment,
            errorBuilder: errorBuilder ?? (_, __, ___) => SizedBox(width: width, height: height),
          );
        },
        gaplessPlayback: gaplessPlayback,
        filterQuality: filterQuality,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
      );
    }
    return Image.asset(
      normalizeResourcePath(path),
      key: key,
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
      alignment: alignment,
      scale: scale,
      errorBuilder: errorBuilder,
      gaplessPlayback: gaplessPlayback,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  /// [AssetImage] o'rniga (DecorationImage, precacheImage va h.k. uchun)
  static ImageProvider provider(String path) {
    final file = ResourceManager.instance.fileFor(path);
    if (file != null) return FileImage(file);
    return AssetImage(normalizeResourcePath(path));
  }
}

class AppLottie {
  AppLottie._();

  /// [Lottie.asset] bilan bir xil asosiy parametrlar
  static Widget asset(
    String path, {
    Key? key,
    double? width,
    double? height,
    BoxFit? fit,
    bool? repeat,
    bool? reverse,
    bool? animate,
    Animation<double>? controller,
    void Function(LottieComposition)? onLoaded,
    ImageErrorWidgetBuilder? errorBuilder,
  }) {
    final file = ResourceManager.instance.fileFor(path);
    if (file != null) {
      return Lottie.file(
        file,
        key: key,
        width: width,
        height: height,
        fit: fit,
        repeat: repeat,
        reverse: reverse,
        animate: animate,
        controller: controller,
        onLoaded: onLoaded,
        errorBuilder: (context, error, stack) {
          ResourceManager.instance.reportBroken(path);
          return Lottie.asset(
            normalizeResourcePath(path),
            width: width,
            height: height,
            fit: fit,
            repeat: repeat,
            reverse: reverse,
            animate: animate,
            controller: controller,
            onLoaded: onLoaded,
            errorBuilder: errorBuilder ?? (_, __, ___) => SizedBox(width: width, height: height),
          );
        },
      );
    }
    return Lottie.asset(
      normalizeResourcePath(path),
      key: key,
      width: width,
      height: height,
      fit: fit,
      repeat: repeat,
      reverse: reverse,
      animate: animate,
      controller: controller,
      onLoaded: onLoaded,
      errorBuilder: errorBuilder,
    );
  }
}

/// [AssetSource] o'rniga. audioplayers'ning AssetSource'i "assets/" ni o'zi qo'shadi,
/// shuning uchun bu yerga ikkala ko'rinish ham beriladi.
Source appAudioSource(String path) {
  final file = ResourceManager.instance.fileFor(path);
  if (file != null) return DeviceFileSource(file.path);
  return AssetSource(normalizeResourcePath(path).substring('assets/'.length));
}

/// Video: qurilmada bo'lmasa (videolar orqa fonda yuklanadi) avval o'sha faylni yuklab oladi.
Future<VideoPlayerController> appVideoController(String path) async {
  final file = await ResourceManager.instance.ensure(path);
  if (file != null) return VideoPlayerController.file(file);
  return VideoPlayerController.asset(normalizeResourcePath(path));
}

/// YOLO modeli: qurilmadagi absolyut yo'l (plugin buni qo'llab-quvvatlaydi), bo'lmasa asset yo'li.
Future<String> appModelPath(String path) async {
  final file = await ResourceManager.instance.ensure(path);
  return file?.path ?? path;
}
