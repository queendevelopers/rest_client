import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../http_config.dart';

class RequestInterceptor {
  final IHttpConfig config;

  RequestInterceptor(this.config);

  InterceptorsWrapper getInterceptor() {
    return InterceptorsWrapper(onRequest: (RequestOptions options) async {
      return onRequest(options);
    });
  }

  Object onRequest(RequestOptions options) async {
    final token = await config.token;
    options.contentType = config.contentType;
    options.baseUrl = config.baseUrl;
    token != null
        ? (options.headers['Authorization'] = 'Bearer ${await config.token}')
        : options.headers;
    debugPrint('baseUrl ${config.baseUrl}');
    return options;
  }
}
