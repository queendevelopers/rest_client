abstract class IRequestEndPoint {
  String get url;

  RequestMethod method;
}

enum RequestMethod { GET, POST, PATCH, PUT, DELETE }

class RequestEndPoint implements IRequestEndPoint {
  final RequestMethod requestMethod;
  final String requestUrl;

  RequestEndPoint(this.requestMethod, this.requestUrl);

  @override
  RequestMethod method;

  @override
  String get url => requestUrl;
}
