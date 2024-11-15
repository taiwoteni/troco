import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../utils/enums.dart';

class FadeSlideWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final SlideDirection direction;
  final bool mustBeVisible;

  const FadeSlideWidget({
    super.key,
    required this.delay,
    this.direction = SlideDirection.up,
    this.mustBeVisible = false,
    required this.child,
  });

  @override
  State createState() => _FadeSlideWidgetState();
}

class _FadeSlideWidgetState extends State<FadeSlideWidget> {
  double _opacity = 0;
  Offset _offset = const Offset(0, 0);
  late Timer _timer;
  final UniqueKey key = UniqueKey();

  @override
  void initState() {
    switch (widget.direction) {
      case SlideDirection.up:
        _offset = const Offset(0, 50);
        break;
      case SlideDirection.down:
        _offset = const Offset(0, -50);
        break;
      case SlideDirection.left:
        _offset = const Offset(-50, 0);
        break;
      case SlideDirection.right:
        _offset = const Offset(50, 0);
        break;
    }
    super.initState();
    if (!widget.mustBeVisible) {
      animate();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void animate() {
    _timer =
        Timer(widget.mustBeVisible ? widget.delay * 0.25 : widget.delay, () {
      setState(() {
        _opacity = 1;
        _offset = const Offset(0, 0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: key,
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.25 &&
            _opacity <= 0 &&
            widget.mustBeVisible) {
          animate();
        }
      },
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(seconds: 1),
        child: AnimatedContainer(
          duration: const Duration(seconds: 1),
          transform: Matrix4.translationValues(_offset.dx, _offset.dy, 0),
          child: widget.child,
        ),
      ),
    );
  }
}
