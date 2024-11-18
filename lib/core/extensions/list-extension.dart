extension ListExtension on List<dynamic> {
  List<String> toListString() {
    return map(
      (e) => e.toString(),
    ).toList();
  }

  List<dynamic> copy() {
    final l = [];

    forEach(
      (element) {
        l.add(element);
      },
    );

    return l;
  }
}
