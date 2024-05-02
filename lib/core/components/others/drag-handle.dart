import 'package:flutter/cupertino.dart';

import '../../app/color-manager.dart';
import '../../app/size-manager.dart';

class DragHandle extends StatelessWidget {
  final double scale;
  const DragHandle({super.key, this.scale = 1});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: scale* 55,
      height: 5,
      decoration: BoxDecoration(
          color: ColorManager.secondary.withOpacity(0.18),
          borderRadius: BorderRadius.circular(SizeManager.extralarge)),
    );
  }
}
