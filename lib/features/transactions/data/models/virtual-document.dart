class VirtualDocument {
  final String _value;
  final String? _taskName;
  final String? _taskId;

  const VirtualDocument(
      {required final String value,
      final String? taskName,
      final String? taskId})
      : _value = value,
        _taskId = taskId,
        _taskName = taskName;

  VirtualDocumentType get type {
    final RegExp urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
      multiLine: false,
    );

    if (urlRegex.hasMatch(source)) {
      //Already uploaded virtual documents would be a link of course
      // The remedy is to check if it matches or contains `storage.googleapis.com`
      // which is the link that a virtual document would have if a document was uploaded.
      if (source.toLowerCase().contains('storage.googleapis.com/troco_app')) {
        return VirtualDocumentType.File;
      }
      return VirtualDocumentType.Link;
    }
    return VirtualDocumentType.File;
  }

  String get taskName {
    return _taskName ?? "";
  }

  String get taskId {
    return _taskId ?? "";
  }

  String get source {
    return _value;
  }
}

enum VirtualDocumentType { File, Link }
