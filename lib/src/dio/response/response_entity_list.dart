class ResponseEntityList<T> {
  final List<T> response;
  final String? errorMessage;


  ResponseEntityList({
    required this.response,
    required this.errorMessage,
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
      response: List<T>.from(json[rootNode].map((x) => fromJson(x))),
      errorMessage: '',
    );
  }

  factory ResponseEntityList.fromEntityList(List<T> t) {
    return ResponseEntityList(response: t, errorMessage: '');
  }

  factory ResponseEntityList.withError(String errorValue) {
    return ResponseEntityList(
      response: <T>[],
      errorMessage: errorValue,
    );
  }
}
