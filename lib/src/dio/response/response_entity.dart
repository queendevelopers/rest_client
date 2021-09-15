import 'package:flutter/foundation.dart';

class EmptyResponse {
  ResponseEntity<EmptyResponse> get response =>
      ResponseEntity(response: null, errorMessage: '', errors: null);
}

class ResponseEntity<T> {
  final T response;
  final String errorMessage;
  final Map<String, dynamic> errors;

  ResponseEntity(
      {@required this.response,
      @required this.errorMessage,
      @required this.errors});

  factory ResponseEntity.fromJson(
      {String rootNode = 'data',
      @required Map<String, dynamic> json,
      T Function(Object o) fromJson}) {
    return ResponseEntity(
        response: fromJson(json[rootNode]), errorMessage: '', errors: null);
  }

  factory ResponseEntity.fromEntity(T t) {
    return ResponseEntity(response: t, errorMessage: '', errors: null);
  }

  factory ResponseEntity.withError(String message) {
    return ResponseEntity(response: null, errorMessage: message, errors: null);
  }
}
