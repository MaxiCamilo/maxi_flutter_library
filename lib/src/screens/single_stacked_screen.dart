import 'package:flutter/material.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';

class SingleStackedScreen extends StatefulWidget {
  final SingleStackedScreenOperator? stackedOperator;
  final void Function(SingleStackedScreenOperator)? stackedOperatorCreated;

  const SingleStackedScreen({super.key, this.stackedOperator, this.stackedOperatorCreated});

  @override
  State<SingleStackedScreen> createState() => _SingleStackedScreenState();
}

class _SingleStackedScreenState extends State<SingleStackedScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
