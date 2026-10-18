import 'package:flutter/material.dart';

/// Xarita foni (asl rasm 679x20089) 10 ta bo'lakka bo'lingan.
/// Bitta katta rasm RAM da ~52 MB egallardi, bo'laklar esa ListView orqali
/// faqat ekranda ko'rinib turganda yuklanadi (har biri ~5.5 MB).
const double _kSliceSourceWidth = 679;
const List<int> _kSliceSourceHeights = [
  2009,
  2009,
  2009,
  2009,
  2009,
  2009,
  2009,
  2009,
  2009,
  2008,
];

String _slicePath(int index) => 'assets/backround/map/map_bg_${index + 1}.webp';

class SlicedMapBackground extends StatefulWidget {
  /// Xaritaning asosiy scroll controlleri — fon unga ergashib siljiydi.
  final ScrollController controller;
  final double height;

  const SlicedMapBackground({
    super.key,
    required this.controller,
    required this.height,
  });

  @override
  State<SlicedMapBackground> createState() => _SlicedMapBackgroundState();
}

class _SlicedMapBackgroundState extends State<SlicedMapBackground> {
  final ScrollController _bgController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncOffset);
  }

  @override
  void didUpdateWidget(covariant SlicedMapBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncOffset);
      widget.controller.addListener(_syncOffset);
    }
  }

  void _syncOffset() {
    if (!widget.controller.hasClients || !_bgController.hasClients) return;
    final max = _bgController.position.maxScrollExtent;
    _bgController.jumpTo(widget.controller.offset.clamp(0.0, max));
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncOffset);
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // fitWidth: bo'lak kengligi ekran kengligiga cho'ziladi
        final scale = width / _kSliceSourceWidth;
        final sliceHeights = [for (final h in _kSliceSourceHeights) h * scale];

        // Xarita rasmdan uzun bo'lsa, bo'laklar qaytadan takrorlanadi (avvalgi repeatY)
        int itemCount = 0;
        double covered = 0;
        while (covered < widget.height) {
          covered += sliceHeights[itemCount % sliceHeights.length];
          itemCount++;
        }

        // Birinchi kadrda ham scroll pozitsiyasi to'g'ri bo'lishi uchun
        WidgetsBinding.instance.addPostFrameCallback((_) => _syncOffset());

        return IgnorePointer(
          child: ListView.builder(
            controller: _bgController,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: itemCount,
            itemBuilder: (context, i) {
              final index = i % sliceHeights.length;
              return _MapSlice(
                asset: _slicePath(index),
                width: width,
                // Bo'laklar orasida ingichka chiziq ko'rinmasligi uchun 1px ustma-ust
                height: sliceHeights[index] + 1,
                displayHeight: sliceHeights[index],
              );
            },
          ),
        );
      },
    );
  }
}

class _MapSlice extends StatefulWidget {
  final String asset;
  final double width;
  final double height;
  final double displayHeight;

  const _MapSlice({
    required this.asset,
    required this.width,
    required this.height,
    required this.displayHeight,
  });

  @override
  State<_MapSlice> createState() => _MapSliceState();
}

class _MapSliceState extends State<_MapSlice> {
  @override
  void dispose() {
    // Ekrandan chiqqan bo'lakni keshdan o'chiramiz — RAM to'planib qolmaydi
    PaintingBinding.instance.imageCache.evict(AssetImage(widget.asset));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.displayHeight,
      child: OverflowBox(
        alignment: Alignment.topCenter,
        maxHeight: widget.height,
        child: Image.asset(
          widget.asset,
          width: widget.width,
          height: widget.height,
          fit: BoxFit.fill,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
