import 'dart:async';
import 'dart:math';

abstract class ProgressStream<T extends Object?> {
  T onProgress(void Function(double) onProgress);
  T onError(void Function() e);
  T onCompleted(void Function(dynamic) completed);
}

class ConcurrentFuture<T extends Object?>
    implements ProgressStream<ConcurrentFuture<T>> {
  final List<Future<T>> _futures;
  List<T>? results;
  StreamController<List<T>>? _streamController;

  ConcurrentFuture({required List<Future<T>> futures})
      : _futures = futures,
        _streamController = StreamController<List<T>>.broadcast();

  ConcurrentFuture.stream({required List<Future<T>> futures})
      : _futures = futures,
        _streamController = StreamController<List<T>>.broadcast();

  static Future<List<T>?> run<T extends Object?>(
      {required final List<Future<T>> futures}) async {
    try {
      final results = <T>[];
      for (final future in futures) {
        final result = await future;
        results.add(result);
      }
      return results;
    } on Error catch (e) {
      return null;
    } on Exception catch (e) {
      return null;
    }
  }

  static Future<List<T>> runWithResult<T extends Object?>(
      {required final List<Future<T>> futures}) async {
    final results = <T>[];
    try {
      for (final future in futures) {
        final result = await future;
        results.add(result);
      }
      return results;
    } on Error catch (e) {
      return results;
    } on Exception catch (e) {
      return results;
    }
  }

  Future<void> runAsStream() async {
    results = <T>[];
    try {
      for (final future in _futures) {
        final result = await future;
        results!.add(result);
        _streamController!.sink.add(results!);
      }
    } on Error catch (e) {
      _streamController?.sink.addError(e);
      dispose();
    } on Exception catch (e) {
      _streamController?.sink.addError(e);
      dispose();
    }
  }

  Future dispose() async {
    return _streamController?.close();
  }

  @override
  ConcurrentFuture<T> onCompleted(void Function(List<T> result) completed) {
    _streamController?.stream.listen(
      (event) {
        if (event.length == _futures.length) {
          completed(event);
          _streamController!.close();
        }
      },
    );
    return this;
  }

  @override
  ConcurrentFuture<T> onProgress(void Function(double progress) onProgress) {
    _streamController?.stream.listen(
      (event) {
        onProgress(event.length / _futures.length * 100);
      },
    );

    return this;
  }

  @override
  ConcurrentFuture<T> onError(void Function() e) {
    _streamController?.stream.listen(null, onError: (error) {
      e();
    });
    return this;
  }
}
