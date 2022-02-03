import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../http_config.dart';

class RequestInterceptor {
  final IHttpConfig config;

  RequestInterceptor(this.config);

  InterceptorsWrapper getInterceptor() {
    return InterceptorsWrapper(onRequest: (RequestOptions options,
        RequestInterceptorHandler requestInterceptorHandler) async {
      return Future.value(onRequest(options, requestInterceptorHandler));
    });
  }

  Object onRequest(RequestOptions options,
      RequestInterceptorHandler requestInterceptorHandler) async {
    final token = await config.token;
    options.contentType = config.contentType;
    options.baseUrl = config.baseUrl;
    token != null
        ? options.headers['Authorization'] = 'Bearer${await config.token}'
        : options.headers;
    debugPrint('baseUrl ${config.baseUrl}');
    print(options.path);
    print(options.method);
    requestInterceptorHandler.next(options);
    return options;
  }
}
