abstract class IRequestEndPoint {
  String get url;

  late RequestMethod method;
}

enum RequestMethod { GET, POST, PATCH, PUT, DELETE }

class RequestEndPoint implements IRequestEndPoint {
  final RequestMethod requestMethod;
  final String requestUrl;

  RequestEndPoint(this.requestMethod, this.requestUrl, this.method);

  @override
  RequestMethod method;

  @override
  String get url => requestUrl;
}

class BaseRequestEndPoint implements IRequestEndPoint {
  @override
  RequestMethod method = RequestMethod.POST;

  @override
  String get url => '';
}
