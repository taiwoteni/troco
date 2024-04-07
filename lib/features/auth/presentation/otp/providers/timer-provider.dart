import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

StateProvider<Duration> _durationProvider =
    StateProvider((ref) => const Duration());

///[TimerProvider] is a class used to manage time ticking.
///It has flutter riverpod support inorder to get its values without resetting state.
///Ensure to call the [TimerProvider.cancel] method at your dispose() method in your widget tree.
class TimerProvider {
  Timer? _timer;
  final WidgetRef _ref;
  final Duration _duration;
  final void Function() onComplete;

  ///[TimerProvider] is a class used to manage time ticking.
  ///It has flutter riverpod support inorder to get its values without resetting state.
  ///Ensure to call the [cancel] method at your dispose() method in your widget tree.
  TimerProvider(
      {required final Duration duration,
      required final WidgetRef ref,
      required this.onComplete})
      : _duration = duration,
        _ref = ref;

  final Stopwatch _stopwatch = Stopwatch();

  /// [value] is used to get the current value of the timer's tick in SECONDS.
  /// It is used with riverpod state management so the ticks are updated.
  int value() {
    return _ref.watch(_durationProvider).inSeconds;
  }

  /// [start] is used to start the timer.
  Future<void> start() async {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _ref.watch(_durationProvider.notifier).state = _stopwatch.elapsed;

      // that is if the max duration is exceeded or reached:
      if (_duration.inMilliseconds <= _stopwatch.elapsed.inMilliseconds) {
        cancel(disposing: false);
        onComplete();
      }
    });
  }

  /// [cancel] is used to stop the timer.
  Future<void> cancel({bool disposing = true}) async {
    if (!disposing) {
      log("sucessfully reset provider duration.");
      _ref.watch(_durationProvider.notifier).state = const Duration();
    }
    _stopwatch.stop();
    _stopwatch.reset();
    _timer!.cancel();
  }

  /// [pause] is used to pause the timer.
  Future<void> pause() async {
    _stopwatch.stop();
    _timer!.cancel();
  }
}
