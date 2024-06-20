// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/core/app/size-manager.dart';
import 'package:troco/features/auth/presentation/welcome-back/provider/loading-provider.dart';

// ignore: must_be_immutable
class PinInputWidget extends ConsumerStatefulWidget {
  int pinsEntered;
  final int maxPin;
  PinInputWidget({super.key, required this.pinsEntered, this.maxPin = 4});

  @override
  ConsumerState<PinInputWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends ConsumerState<PinInputWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  List<Animation<double>>? animations;

  @override
  void initState() {
    controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
        reverseDuration: const Duration(milliseconds: 400));
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback(
      (timeStamp) {
        ref.watch(loadingProvider.notifier).state = controller;
        //   animations ??= List.generate(widget.maxPin, (index) {
        //   final start = index * 0.2;
        //   final end = (index==0?0:index) + 0.6;
        //   return Tween<double>(begin: 0, end: 10).animate(
        //     CurvedAnimation(
        //       parent: ref.watch(loadingProvider)!,
        //       curve: Interval(start, end, curve: Curves.easeInOut),
        //     ),
        //   );
        // });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    animations ??= List.generate(widget.maxPin, (index) {
      final start = index * 0.2;
      final end = start + 0.2;
      return Tween<double>(begin: 0.0, end: 10).animate(
        CurvedAnimation(
          parent: ref.watch(loadingProvider)!,
          curve: Interval(start, end, curve: Curves.easeInOut),
        ),
      );
    });
    return Container(
      height:
          /** Size of the input decorator plus half the highest possible value when animating */ SizeManager
                      .regular *
                  1.5 +
              5,
              alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.maxPin,
          (index) {
            return AnimatedBuilder(
              animation: animations![index],
              builder: (context, child) {
                return Padding(
                  padding: EdgeInsets.only(
                      right: SizeManager.regular,
                      left: SizeManager.regular,
                      bottom: animations![index].value+index),
                  child: child,
                );
              },
              child: inputIndicator(entered: widget.pinsEntered - 1 < index),
            );
          },
        ).toList(),
      ),
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
