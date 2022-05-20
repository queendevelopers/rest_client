abstract class IHttpConfig {
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
