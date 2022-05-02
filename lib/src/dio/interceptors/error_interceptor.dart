import 'package:dio/dio.dart';
import 'package:flutter_rest_client/flutter_rest_client.dart';

class ErrorInterceptor extends Interceptor {
  final Dio _dio;
  final IHttpConfig config;

  ErrorInterceptor(this._dio, this.config);

  @override
  void onError(DioError error, ErrorInterceptorHandler handler) async {
    final exception = NetworkException.getDioException(error);
    if (exception is TokenExpired || exception is UnauthorizedRequest) {
      await config.listener.clearSession();
    }
    return super.onError(error, handler);
  }
}
