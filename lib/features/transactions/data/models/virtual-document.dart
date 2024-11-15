class VirtualDocument {
  final String _value;
  final String? _taskName;

  const VirtualDocument({required final String value, final String? taskName}) : _value = value, _taskName = taskName;

  VirtualDocumentType get type {
    final RegExp urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
      multiLine: false,
    );

    if (urlRegex.hasMatch(source)) {
      return VirtualDocumentType.Link;
    }
    return VirtualDocumentType.File;
  }

  String get taskName{
    return _taskName ?? "";
  }

  String get source {
    return _value;
  }
}

enum VirtualDocumentType { File, Link }
