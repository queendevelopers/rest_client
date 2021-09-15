import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class PrettyLoggerInterceptor {
  final PrettyDioLogger prettyDioLogger = PrettyDioLogger(
      request: true, requestBody: true, requestHeader: true, maxWidth: 140);
}
