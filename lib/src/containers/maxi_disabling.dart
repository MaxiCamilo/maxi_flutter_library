import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/src/widgets.dart';
import 'package:maxi_library/export_reflectors.dart';

class MaxiDisabling extends StatelessWidget {
  final bool isEnabled;
  final Widget child;
  final Color backgroundColor;
  final Oration disabledText;

  const MaxiDisabling({
    super.key,
    required this.isEnabled,
    required this.child,
    this.backgroundColor = Colors.black,
    this.disabledText = Oration.empty,
  });

  @override
  Widget build(BuildContext context) {
    if (isEnabled) {
      return child;
    }

    if (disabledText.isEmpty) {
      return _buildStack(context);
    } else {
      return MaxiTooltip(
        text: disabledText,
        child: _buildStack(context),
      );
    }
  }

  Widget _buildStack(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: !isEnabled,
          child: FocusScope(
            canRequestFocus: isEnabled,
            child: child,
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !isEnabled,
            child: Container(
              color: backgroundColor,
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(ignoring: !isEnabled, child: const SizedBox()),
        ),
      ],
    );
  }
}
