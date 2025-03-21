import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';

class MaxiBodyWithHeaderAndFooter extends StatelessWidget {
  final double determiningWidth;
  final bool useScreenSize;
  final Axis direction;

  final Widget? header;
  final Widget? body;
  final Widget? footer;

  final bool likeAsMaxiFlex;

  const MaxiBodyWithHeaderAndFooter({
    super.key,
    required this.determiningWidth,
    this.useScreenSize = true,
    this.direction = Axis.vertical,
    this.header,
    this.body,
    this.footer,
    this.likeAsMaxiFlex = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useScreenSize) {
      return _buildWithWidth(context, context.screenWidth);
    } else {
      return LayoutBuilder(builder: (context, constraints) => _buildWithWidth(context, constraints.maxWidth));
    }
  }

  Widget _buildWithWidth(BuildContext context, double width) {
    if (likeAsMaxiFlex) {
      if (width >= determiningWidth) {
        return _buildExtendedFlex(context, Axis.horizontal);
      } else {
        return _buildCompactFlex(context, Axis.vertical);
      }
    }

    if (width >= determiningWidth) {
      return _buildExtendedFlex(context, direction);
    } else {
      return _buildCompactFlex(context, direction);
    }
  }

  Widget _buildExtendedFlex(BuildContext context, Axis direction) {
    if (footer != null && header != null) {
      return Flex(
        direction: direction,
        mainAxisSize: MainAxisSize.max,
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          header!,
          Expanded(
            child: body == null ? const SizedBox() : MaxiScroll(expand: true, child: body!),
          ),
          footer!,
        ],
      );
    }
    //Only Header
    else if (footer == null && header != null) {
      return Flex(
        direction: direction,
        mainAxisSize: MainAxisSize.max,
        children: [
          header!,
          body == null ? const SizedBox() : Expanded(child: MaxiScroll(child: body!)),
        ],
      );
    }
    //Only Footer
    else if ((footer != null && header == null)) {
      return MaxiScroll(
        expand: true,
        child: Flex(
          direction: direction,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            body == null ? const SizedBox() : MaxiScroll(child: body!),
            footer!,
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _buildCompactFlex(BuildContext context, Axis direction) {
    if (body == null && footer == null && header == null) {
      return const SizedBox();
    }

    return MaxiScroll(
      expand: true,
      child: Flex(
        direction: direction,
        mainAxisSize: MainAxisSize.min,
        children: [
          header ?? const SizedBox(),
          Flexible(child: body ?? const SizedBox()),
          footer ?? const SizedBox(),
        ],
      ),
    );
  }
}
