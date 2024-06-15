// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:troco/core/app/size-manager.dart';

// ignore: must_be_immutable
class PinInputWidget extends StatefulWidget {
  int pinsEntered;
  final int maxPin;
  PinInputWidget({super.key, required this.pinsEntered, this.maxPin = 4});

  @override
  State<PinInputWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.maxPin,
        (index) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: SizeManager.regular),
            child: inputIndicator(entered: widget.pinsEntered-1 < index),
          );
        },
      ).toList(),
    );
  }

  Widget inputIndicator({required bool entered}) {
    return Container(
      width: SizeManager.regular * 1.5,
      height: SizeManager.regular * 1.5,
      decoration: BoxDecoration(
          color: entered ? Colors.transparent : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2)),
    );
  }
}
