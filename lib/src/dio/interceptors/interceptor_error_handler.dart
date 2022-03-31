import 'dart:io';

import 'package:flutter/foundation.dart';

class InterceptorErrorHandler {
  final dynamic error;

  InterceptorErrorHandler(this.error);

  handleError() {
    debugPrint(
        'path: ${error.request.path} and network response: ${error.response.toString()}');
    if (error is SocketException) {}
  }
}
