import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rest_client/rest_client.dart';
import 'package:rest_client/src/dio/interceptors/request_interceptor.dart';

import 'interceptors/pretty_logger.dart';

class DioBuilder {
  Dio _dio;
  final IHttpConfig config;
  DioBuilder({this.config});

  Dio build() {
    debugPrint('dio initialized ${config.baseUrl}');
    _dio = Dio();
    // ..options.connectTimeout = config?.connectTimeout ?? 10000
    // ..options.receiveTimeout = config?.receiveTimeout ?? 10000
   _dio.interceptors.add(PrettyLoggerInterceptor().prettyDioLogger);
    _dio.interceptors.add(RequestInterceptor(config).getInterceptor());
    _dio.options.baseUrl = config.baseUrl;
    // _dio.options.headers = {'Authorization':'Bearer ${config.token}'};
    return _dio;
  }
}
