import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/src/framework/state_with_life_cycle.dart';
import 'package:maxi_library/maxi_library.dart';

/*
import 'package:maxi_flutter_library/maxi_flutter_library.dart';

class MaxiAnimatedPortrait with WidgetAnimator {
  final Curve curve;
  final Duration duration;

  const MaxiAnimatedPortrait({this.curve = Curves.linear, required this.duration});

  @override
  Widget build({required BuildContext context, required Widget child}) {
    return MaxiPortrait(
      duration: duration,
      curve: curve,
      child: child,
    );
  }
}
*/

class MaxiPortrait extends StatefulWidget {
  final Widget child;
  final Curve curve;
  final Duration duration;

  final void Function(MaxiPortraitState)? onCreated;

  const MaxiPortrait({
    super.key,
    required this.child,
    required this.duration,
    this.curve = Curves.linear,
    this.onCreated,
  });

  @override
  State<MaxiPortrait> createState() => MaxiPortraitState();
}

class MaxiPortraitState extends State<MaxiPortrait> {
  bool isFirst = true;

  bool hideFirst = false;
  bool hideSecond = true;

  late Widget firstWidget;
  late Widget secondWidget;

  late Curve curve;
  late Duration duration;

  Completer? _waiter;

  @override
  void initState() {
    super.initState();

    firstWidget = widget.child;
    secondWidget = const SizedBox();

    curve = widget.curve;
    duration = widget.duration;

    if (widget.onCreated != null) {
      widget.onCreated!(this);
    }
  }
/*

  Future<void> changeWidget({required Widget newChild, Curve? curve, Duration? duration}) async {
    if (curve != null) {
      this.curve = curve;
    }

    if (duration != null) {
      this.duration = duration;
    }

    ENTRA EN CONFLICTO CON EL WIDGET DE ARRIBA

    if(isFirst){

    }
    else{

    }
  }
  */

  @override
  Widget build(BuildContext context) {
    if (isFirst && firstWidget != widget.child) {
      secondWidget = widget.child;
      isFirst = false;
      _investHidden();
    } else if (!isFirst && secondWidget != widget.child) {
      firstWidget = widget.child;
      isFirst = true;
      _investHidden();
    }

    return Stack(
      children: [
        //CREO QUE SOLO UNO DEBE ANIMAR SU TRANSPARECIA, YA QUE SINO EN UN MOMENTO LOS DOS QUEDAN TRANSPARENTES
        Offstage(
          offstage: hideFirst,
          child: AnimatedOpacity(
            opacity: isFirst ? 1.0 : 0.0,
            curve: curve,
            duration: duration,
            child: firstWidget,
          ),
        ),
        Offstage(
          offstage: hideSecond,
          child: AnimatedOpacity(
            opacity: isFirst ? 0.0 : 1.0,
            curve: curve,
            duration: duration,
            child: secondWidget,
          ),
        ),
      ],
    );
  }

  Future<void> _investHidden() async {
    await Future.delayed(widget.duration);
    hideFirst = !hideFirst;
    hideSecond = !hideSecond;

    if (mounted) {
      setState(() {});
    }

    _waiter?.completeIfIncomplete();
    _waiter = null;
  }
}
