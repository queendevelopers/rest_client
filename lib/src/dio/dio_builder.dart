import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_rest_client/flutter_rest_client.dart';
import 'package:flutter_rest_client/src/dio/interceptors/error_interceptor.dart';
import 'package:flutter_rest_client/src/dio/interceptors/request_interceptor.dart';

import 'interceptors/pretty_logger.dart';

class DioBuilder {
  late Dio _dio;
  final IHttpConfig config;

  DioBuilder({required this.config});

  Dio build() {
    var response;
    _dio = Dio(
      
    );
    _dio
      ..options.connectTimeout = config.connectionTimeout
      ..options.receiveTimeout = config.receiveTimeout
      ..interceptors.add(ErrorInterceptor(_dio, config))
      ..interceptors.add(QueuedInterceptor())
      ..interceptors.add(RequestInterceptor(config).getInterceptor());

    if (kDebugMode) {
      if (config.dioLogger) {
        _dio..interceptors.add(PrettyLoggerInterceptor().prettyDioLogger);
      }
      if (config.curlLogger) {
        _dio..interceptors.add(CurlLoggerDioInterceptor());
      }
    }
    _dio.options.baseUrl = config.baseUrl;
    
    return _dio;
  }
}
