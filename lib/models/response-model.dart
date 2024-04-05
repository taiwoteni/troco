class HttpResponseModel {
  final bool error;
  final String body;
  final int code;
  const HttpResponseModel(
      {required this.error, required this.body, required this.code});
}
