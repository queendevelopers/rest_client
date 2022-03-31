import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_rest_client/flutter_rest_client.dart';

import 'dio_builder.dart';

abstract class IHttpHelper {
  Future<dynamic> request(IRequestEndPoint endPoint, IRequestModel requestModel,
      {Map<String, dynamic> headers});
}

class HttpHelper implements IHttpHelper {
  final Dio _dio;
  CancelToken cancelToken = CancelToken();
  IHttpConfig config;

  HttpHelper({required this.config})
      : _dio = DioBuilder(config: config).build();

  @override
  Future request(IRequestEndPoint endPoint, IRequestModel requestModel,
      {Map<String, dynamic>? headers}) async {
    try {
      switch (endPoint.method) {
        case RequestMethod.DELETE:
          return (await _dio.delete(endPoint.url,
                  options: Options(headers: headers),
                  queryParameters: requestModel.toJson(),
                  cancelToken: cancelToken))
              .data;
        case RequestMethod.GET:
          return (await _dio.get(endPoint.url,
                  options: Options(headers: headers),
                  queryParameters: requestModel.toJson(),
                  cancelToken: cancelToken))
              .data;
        case RequestMethod.POST:
          return (await _dio.post(endPoint.url,
                  options: Options(headers: headers),
                  data: requestModel.toJson(),
                  cancelToken: cancelToken))
              .data;
        case RequestMethod.PATCH:
          return (await _dio.patch(endPoint.url,
                  options: Options(headers: headers),
                  data: requestModel.toJson(),
                  cancelToken: cancelToken))
              .data;
        case RequestMethod.PUT:
          return (await _dio.put(endPoint.url,
                  options: Options(headers: headers),
                  data: requestModel.toJson(),
                  cancelToken: cancelToken))
              .data;
      }
    } on DioError catch (e) {
      switch (e.response?.statusCode) {
        case 400:
        case 401:
        case 403:
          config.listener.clearSession();
      }
      return e.response?.data;
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw FormatException();
    } catch (e) {
      throw e;
    }
  }
}
