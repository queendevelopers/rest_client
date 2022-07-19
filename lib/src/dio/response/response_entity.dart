class EmptyResponse {
  final String? message;

  EmptyResponse({this.message});

  ResponseEntity<EmptyResponse> get response =>
      ResponseEntity(true, message: message, response: null);
}

class ResponseEntity<T> {
  final T? response;
  final bool ok;
  final String? message;
  final Map<String, dynamic>? errors;

  ResponseEntity(
    this.ok, {
    required this.response,
    this.message,
    this.errors,
  });

  factory ResponseEntity.fromJson(
      {String rootNode = 'data',
      required Map<String, dynamic> json,
      required T Function(Map<String, dynamic> o) fromJson}) {
    return json[rootNode] != null
        ? ResponseEntity(
            json['ok'],
            response: fromJson(json[rootNode]),
            message: json['message'] ?? '',
            errors: null,
          )
        : ResponseEntity.withError(json['message']);
  }

  factory ResponseEntity.fromEntity(T t) {
    return ResponseEntity(
      true,
      response: t,
      message: '',
      errors: null,
    );
  }

  factory ResponseEntity.withError(String message) {
    return ResponseEntity(
      false,
      response: null,
      message: message,
      errors: null,
    );
  }
}

class ErrorObject {
  final Map<dynamic, dynamic> data;

  ErrorObject(this.data);

  factory ErrorObject.fromJson(dynamic json) {
    assert(json is Map);
    return ErrorObject(json['data']);
  }
}
