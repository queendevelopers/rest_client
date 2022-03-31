import 'package:dio/dio.dart';
import 'package:flutter_rest_client/flutter_rest_client.dart';

import 'interceptor_error_handler.dart';

class ErrorInterceptor extends Interceptor {
  final Dio _dio;
  final IHttpConfig config;

  ErrorInterceptor(this._dio, this.config);

  @override
  void onError(DioError error, ErrorInterceptorHandler handler) async {
    final exception = await InterceptorErrorHandler(error.error).handleError();
    // if (exception is TokenExpiredException) {}
  }
}
