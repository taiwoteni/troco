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

class _PinInputWidgetState extends ConsumerState<PinInputWidget> with SingleTickerProviderStateMixin{
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000),
        reverseDuration: const Duration(milliseconds: 1000));
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      ref.watch(loadingProvider.notifier).state = controller;
    },);

  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.maxPin,
        (index) {
          int factor = index+1;
          return AnimatedBuilder(
            animation: ref.watch(loadingProvider)??controller,
            builder: (context, child) {
              return FutureBuilder(
                future: wait(index),
                initialData: 0,
                builder: (context,snapshot) {
                  final int value = snapshot.hasData?1:0;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: SizeManager.regular,
                      left: SizeManager.regular,
                      bottom: SizeManager.regular* (ref.watch(loadingProvider)?.value ?? controller.value) * value * factor 
                    ),
                    child: child,
                  );
                }
              );
            },
            child: inputIndicator(entered: widget.pinsEntered-1 < index),
          );
        },
      ).toList(),
    );
  }

  Future<int> wait(int index)async{
    await Future.delayed(Duration(milliseconds: 250 * (index+1)));
    return 1;
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
