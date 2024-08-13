import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:troco/features/auth/presentation/providers/client-provider.dart';

/// We can't use providers to store this simply because, it's a matter
/// of contexts. Calling `ref` to change data in app.dart may not work
/// simply because it won't be the current context of the app.
var kInBlockedScreen = false;
var kIsBlocked = ClientProvider.readOnlyClient?.blocked ?? false;

final blockedStreamProvider = StreamProvider<bool>((ref) {
  final blockedStreamController = StreamController<bool>();

  final timer = Timer.periodic(
    const Duration(seconds: 10),
    (timer) {
      blockedStreamController.sink.add(kIsBlocked);
      kInBlockedScreen = kIsBlocked;
    },
  );

  ref.onDispose(() {
    blockedStreamController.close();
    timer.cancel();
  });

  return blockedStreamController.stream;
});
