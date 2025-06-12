import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';

class MaxiBodyWithHeaderAndFooter extends StatelessWidget {
  final double determiningWidth;
  final double determiningHeigth;
  final bool useScreenSize;
  final Axis direction;

  final Widget? header;
  final Widget? body;
  final Widget? footer;

  final bool likeAsMaxiFlex;
  final bool expandVertically;

  const MaxiBodyWithHeaderAndFooter({
    super.key,
    required this.determiningWidth,
    required this.determiningHeigth,
    this.useScreenSize = true,
    this.expandVertically = true,
    this.direction = Axis.vertical,
    this.header,
    this.body,
    this.footer,
    this.likeAsMaxiFlex = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useScreenSize) {
      return _buildWithWidth(context, context.screenWidth, context.screenHeigth);
    } else {
      return LayoutBuilder(builder: (context, constraints) => _buildWithWidth(context, constraints.maxWidth, constraints.maxHeight));
    }
  }

  Widget _buildWithWidth(BuildContext context, double width, double heigth) {
    if (likeAsMaxiFlex) {
      if (width >= determiningWidth && (heigth == double.infinity || heigth >= determiningHeigth)) {
        return _buildExtendedFlex(context, Axis.horizontal);
      } else {
        return _buildCompactFlex(context, Axis.vertical);
      }
    }

    if (width >= determiningWidth && (heigth == double.infinity || heigth >= determiningHeigth)) {
      /* if (expandVertically && width != double.infinity && heigth != double.infinity) {
        return MaxiRectangle(
          constraints: BoxConstraints(maxHeight: heigth, maxWidth: width),
          child: _buildExtendedFlex(context, direction),
        );
      } else {*/
      return _buildExtendedFlex(context, direction);
      //}
    } else {
      return _buildCompactFlex(context, direction);
    }
  }

  Widget _buildExtendedFlex(BuildContext context, Axis direction) {
    if (footer != null && header != null) {
      return Flex(
        direction: direction,
        mainAxisSize: expandVertically ? MainAxisSize.max : MainAxisSize.min,
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          header!,
          expandVertically
              ? Expanded(
                  child: body == null ? const SizedBox() : MaxiScroll(expand: true, child: body!),
                )
              : body == null
                  ? const SizedBox()
                  : Flexible(child: MaxiScroll(child: body!)),
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
      //expand: true,
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
