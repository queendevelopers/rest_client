import 'package:flutter_rest_client/src/exceptions/network_exception.dart';

class ErrorParser {
  static String parseDioException(dynamic error) {
    final dioException = NetworkException.getDioException(error);
    return NetworkException.getErrorMessage(dioException);
  }
}
