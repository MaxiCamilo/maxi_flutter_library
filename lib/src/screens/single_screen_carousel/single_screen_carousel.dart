import 'package:flutter/widgets.dart';
import 'package:maxi_flutter_library/maxi_flutter_library.dart';

class SingleScreenCarousel extends StatefulWidget {
  final SingleScreenCarouselOperator? carouselOperator;
  final void Function(SingleScreenCarouselOperator)? carouselOperatorCreated;

  const SingleScreenCarousel({super.key, this.carouselOperator, this.carouselOperatorCreated});

  @override
  State<SingleScreenCarousel> createState() => _SingleScreenCarouselState();
}

class _SingleScreenCarouselState extends State<SingleScreenCarousel> {
  late SingleScreenCarouselOperator carouselOperator;

  @override
  void initState() {
    super.initState();

    if (widget.carouselOperator == null) {
      carouselOperator = SingleScreenCarouselOperator();
    } else {
      carouselOperator = widget.carouselOperator!;
    }

    if (widget.carouselOperatorCreated != null) {
      widget.carouselOperatorCreated!(carouselOperator);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StackedCanvas(
      canvasOperator: carouselOperator.canvasOperator,
    );
  }
}
