import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';

class HideByScroll extends StatefulWidget {
  final ScrollController scrollController;
  final Duration duration;
  final Widget child;
  final Curve curve;
  final bool startHidden;
  final bool Function(BuildContext context, ScrollDirection scrollDirection, double scrollIndex) defineIfItShows;

  const HideByScroll({
    super.key,
    required this.scrollController,
    required this.child,
    required this.defineIfItShows,
    this.startHidden = false,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.decelerate,
  });

  @override
  State<HideByScroll> createState() => _HideByScrollState();
}

class _HideByScrollState extends StateWithLifeCycle<HideByScroll> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;
  late Animation<double> sizeAnimation;
  bool isHidden = false;

  @override
  void initState() {
    super.initState();
    isHidden = widget.startHidden;
    controller = joinObject(
      item: AnimationController(
        vsync: this,
        duration: widget.duration,
      ),
    );

    slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    ));

    fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: controller, curve: widget.curve));

    sizeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: controller, curve: widget.curve));

    widget.scrollController.addListener(handleScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(handleScroll);
    super.dispose();
  }

  void handleScroll() {
    final direction = widget.scrollController.position.userScrollDirection;
    final asItShouldBe = !widget.defineIfItShows(context, direction, widget.scrollController.offset);

    if (isHidden != asItShouldBe) {
      isHidden = asItShouldBe;
      if (isHidden) {
        controller.forward();
        isHidden = true;
      } else {
        controller.reverse();
        isHidden = false;
      }
    }
/*
    if (direction == ScrollDirection.reverse && !isHidden) {
    } else if (direction == ScrollDirection.forward && isHidden) {}*/
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: sizeAnimation,
      axisAlignment: -1.0,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}
