class ResponseEntityList<T> {
  final bool ok;
  final List<T> response;
  final String? message;

  ResponseEntityList(
    this.ok, {
    required this.response,
    required this.message,
  });

  factory ResponseEntityList.fromJson(
      {String rootNode = 'data',
      dynamic json,
      required T Function(Map<String, dynamic> o) fromJson}) {
    if (json == null || json.isEmpty == null || json[rootNode] == null) {
      return ResponseEntityList.withError('No data found');
    }
    if (json[rootNode] is! List) {
      return ResponseEntityList.withError('Invalid data');
    }
    return ResponseEntityList(
      json['ok'],
      response: List<T>.from(json[rootNode].map((x) => fromJson(x))),
      message: '',
    );
  }

  factory ResponseEntityList.fromEntityList(List<T> t) {
    return ResponseEntityList(
      true,
      response: t,
      message: '',
    );
  }

  factory ResponseEntityList.withError(String errorValue) {
    return ResponseEntityList(
      false,
      response: <T>[],
      message: errorValue,
    );
  }
}
