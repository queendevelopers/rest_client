abstract class IHttpConfig {
  String get baseUrl;

  Future<String> get token;

  int connectionTimeout;
  int receiveTimeout;
  String contentType;
}
