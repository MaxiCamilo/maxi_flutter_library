import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';
import 'package:maxi_library/export_reflectors.dart';

class MaxiTabBarItem {
  final Oration text;
  final Widget icon;
  final Widget child;

  const MaxiTabBarItem({required this.text, required this.icon, required this.child});
}

class MaxiTabBar extends StatefulWidget {
  final int initialIndex;
  final double horizontalWhen;
  final List<MaxiTabBarItem> children;
  final bool buttonsUpperSideVertical;
  final bool buttonsLeftSideHorizontal;
  final Color indicatorColor;
  final Color backgroundColor;

  const MaxiTabBar({
    super.key,
    required this.horizontalWhen,
    required this.children,
    required this.indicatorColor,
    this.initialIndex = 0,
    this.backgroundColor = Colors.transparent,
    this.buttonsLeftSideHorizontal = true,
    this.buttonsUpperSideVertical = true,
  });

  @override
  State<MaxiTabBar> createState() => _MaxiTabBarState();
}

class _MaxiTabBarState extends StateWithLifeCycle<MaxiTabBar> with SingleTickerProviderStateMixin {
  late final TabController tabController;

  late final List<Widget> children;
  late final List<String> texts;
  late final List<Widget> buttons;

  @override
  void initState() {
    super.initState();

    children = widget.children.map((x) => x.child).toList(growable: false);
    texts = widget.children.map((x) => x.text.toString()).toList(growable: false);
    buttons = widget.children.mapWithPosition(_makeButton).toList(growable: false);

    tabController = joinObject(
      item: TabController(
        length: children.length,
        vsync: this,
        initialIndex: widget.initialIndex,
      ),
    );
  }

  Widget _makeButton(MaxiTabBarItem item, int position) {
    return Tab(
      icon: item.icon,
      text: texts[position],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHorizontal = context.screenWidth >= widget.horizontalWhen;

    return Flex(
      direction: isHorizontal ? Axis.horizontal : Axis.vertical,
      mainAxisSize: MainAxisSize.max,
      children: [
        ((widget.buttonsLeftSideHorizontal && isHorizontal) || (widget.buttonsUpperSideVertical && !isHorizontal)) ? (isHorizontal ? _makeHorizontalTab(context) : _makeVerticalTab(context)) : const SizedBox(),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: children,
          ),
        ),
        ((!widget.buttonsLeftSideHorizontal && isHorizontal) || (!widget.buttonsUpperSideVertical && !isHorizontal)) ? (isHorizontal ? _makeHorizontalTab(context) : _makeVerticalTab(context)) : const SizedBox(),
      ],
    );
  }

  Widget _makeHorizontalTab(BuildContext context) {
    return MaxiRectangle(
      backgroundColor: widget.backgroundColor,
      constraints: const BoxConstraints.expand(width: 100),
      child: Center(
        child: NavigationRail(
          selectedIndex: tabController.index,
          indicatorColor: widget.indicatorColor.withAlpha(150),
          backgroundColor: Colors.transparent,
          onDestinationSelected: (int index) {
            //
            setState(() {
              FocusScope.of(context).unfocus();
              tabController.index = index;
            });
          },
          labelType: NavigationRailLabelType.all,
          destinations: widget.children.mapWithPosition((item, i) {
            return NavigationRailDestination(
              icon: item.icon,
              selectedIcon: item.icon,
              label: MaxiText(
                text: texts[i],
                bold: true,
                color: tabController.index == i ? widget.indicatorColor : null,
                aling: TextAlign.center,
              ),
            );
          }).toList(growable: false),
        ),
      ),
    );
  }

  Widget _makeVerticalTab(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: widget.buttonsLeftSideHorizontal ? 0 : 5),
        MaxiRectangle(
          backgroundColor: widget.backgroundColor,
          child: TabBar(
            controller: tabController,
            indicatorColor: widget.indicatorColor,
            labelColor: widget.indicatorColor,
            tabs: buttons,
            onTap: (value) {
              FocusScope.of(context).unfocus();
            },
          ),
        ),
        SizedBox(height: widget.buttonsLeftSideHorizontal ? 5 : 0),
      ],
    );
  }
}
