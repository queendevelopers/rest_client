import 'package:dio/dio.dart';

abstract class IHttpConfig {
  Interceptor? customRequestInterceptor;
  String get baseUrl;

  String get socketUrl;

  Future<String?> get token;

  late int connectionTimeout;
  late int receiveTimeout;
  late String contentType;

  late bool dioLogger;
  late bool curlLogger;

  IHttpHelperEventListening get listener;
}

abstract class IHttpHelperEventListening {
  Future<void> clearSession();
}
