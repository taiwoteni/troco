extension ListExtension on List<dynamic> {
  List<String> toListString() {
    return map(
      (e) => e.toString(),
    ).toList();
  }
}
