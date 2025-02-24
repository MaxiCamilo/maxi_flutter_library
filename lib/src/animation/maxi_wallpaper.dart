import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/maxi_library.dart';

class MaxiWallpaper extends StatefulWidget with IMaxiAnimatorWidget {
  final ImageProvider<Object> initialImage;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final FilterQuality filterQuality;
  final bool expanded;

  final Duration duration;
  final Curve curve;

  @override
  final IMaxiAnimatorManager? animatorManager;

  final void Function(IMaxiWallpaperOperator)? onCreatedOperator;

  const MaxiWallpaper({
    required this.initialImage,
    super.key,
    this.width,
    this.height,
    this.expanded = true,
    this.fit = BoxFit.cover,
    this.duration = const Duration(seconds: 1),
    this.curve = Curves.linear,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.filterQuality = FilterQuality.medium,
    this.onCreatedOperator,
    this.animatorManager,
  });

  @override
  State<MaxiWallpaper> createState() => _MaxiWallpaperState();
}

mixin IMaxiWallpaperOperator {
  Future<void> waitForConstruction();
  Future<void> changeWallpaper({
    required ImageProvider<Object> image,
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    ImageRepeat? repeat,
    FilterQuality? filterQuality,
    Duration? duration,
    Curve? curve,
  });
}

class _MaxiWallpaperState extends StateWithLifeCycle<MaxiWallpaper> with IMaxiWallpaperOperator, IMaxiAnimatorState<MaxiWallpaper> {
  late Widget initialChild;
  late ISingleStackScreenOperator stackScreenOperator;
  late ImageProvider<Object> currentImageProvider;

  final waiterForBuild = Completer();

  bool wasBuild = false;

  @override
  void initState() {
    super.initState();

    currentImageProvider = widget.initialImage;
    initialChild = buildImage(image: widget.initialImage);

    initializeAnimator();
    if (widget.onCreatedOperator != null) {
      widget.onCreatedOperator!(this);
    }
  }

  Widget buildImage({
    required ImageProvider<Object> image,
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    ImageRepeat? repeat,
    FilterQuality? filterQuality,
  }) {
    if (widget.expanded && !(width != null && height != null)) {
      return LayoutBuilder(
          builder: (context, constraints) => Image(
                image: image,
                width: width ?? constraints.maxWidth,
                height: height ?? constraints.maxHeight,
                fit: fit ?? widget.fit,
                alignment: alignment ?? widget.alignment,
                repeat: repeat ?? widget.repeat,
                filterQuality: filterQuality ?? widget.filterQuality,
              ));
    } else {
      return Image(
        image: image,
        width: width ?? widget.width,
        height: height ?? widget.height,
        fit: fit ?? widget.fit,
        alignment: alignment ?? widget.alignment,
        repeat: repeat ?? widget.repeat,
        filterQuality: filterQuality ?? widget.filterQuality,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleStackScreen(
      curve: widget.curve,
      duration: widget.duration,
      initialChildBuild: (p0) => initialChild,
      onCreatedOperator: onCreatedOperator,
    );
  }

  void onCreatedOperator(ISingleStackScreenOperator newOperator) {
    stackScreenOperator = newOperator;
    wasBuild = true;
    waiterForBuild.completeIfIncomplete();
  }

  @override
  Future<void> waitForConstruction() async {
    if (wasBuild) {
      return;
    }

    await waiterForBuild.future;
  }

  @override
  Future<void> changeWallpaper({
    required ImageProvider<Object> image,
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    ImageRepeat? repeat,
    FilterQuality? filterQuality,
    Duration? duration,
    Curve? curve,
  }) async {
    if (currentImageProvider == image) {
      return;
    }
    currentImageProvider = image;

    final newImage = buildImage(image: image, alignment: alignment, filterQuality: filterQuality, fit: fit, height: height, repeat: repeat, width: width);
    await waitForConstruction();

    await stackScreenOperator.changeScreen(newChild: newImage, curve: curve, duration: duration);
  }
}
