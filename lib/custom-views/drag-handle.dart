import 'package:flutter/cupertino.dart';

import '../app/color-manager.dart';
import '../app/size-manager.dart';

class DragHandle extends StatelessWidget {
  const DragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: 5,
      decoration: BoxDecoration(
          color: ColorManager.secondary.withOpacity(0.18),
          borderRadius: BorderRadius.circular(SizeManager.extralarge)),
    );
  }
}
