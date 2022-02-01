class EmptyResponse {
  ResponseEntity<EmptyResponse> get response =>
      ResponseEntity(true, response: null);
}

class ResponseEntity<T> {
  final T? response;
  final bool ok;
  final String? errorMessage;
  final Map<String, dynamic>? errors;

  ResponseEntity(this.ok,
      {required this.response,
       this.errorMessage,
       this.errors});

  factory ResponseEntity.fromJson(
      {String rootNode = 'data',
      required Map<String, dynamic> json,
      required T Function(Map<String, dynamic> o) fromJson}) {
    return ResponseEntity(json['ok'],
        response: fromJson(json[rootNode]), errorMessage: '', errors: null);
  }

  factory ResponseEntity.fromEntity(T t) {
    return ResponseEntity(
      true,
      response: t,
      errorMessage: '',
      errors: null,
    );
  }

  factory ResponseEntity.withError(String message) {
    return ResponseEntity(false,
        response: null, errorMessage: message, errors: null);
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
