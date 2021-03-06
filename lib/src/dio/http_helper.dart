import 'dart:io';

import 'package:dio/dio.dart';
import 'package:rest_client/rest_client.dart';
import 'package:rest_client/src/dio/request/request_endpoint.dart';
import 'package:rest_client/src/dio/request/request_model.dart';

import 'dio_builder.dart';

abstract class IHttpHelper {
  Future<dynamic> request(IRequestEndPoint endPoint, IRequestModel requestModel,
      {Map<String, dynamic> headers});
}

class HttpHelper implements IHttpHelper {
  final Dio _dio;
  CancelToken cancelToken = CancelToken();
  IHttpConfig config;

  HttpHelper({this.config}) : _dio = DioBuilder(config: config).build();

  @override
  Future request(IRequestEndPoint endPoint, IRequestModel requestModel,
      {Map<String, dynamic> headers}) async {
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
          break;
        case RequestMethod.PUT:
          return (await _dio.put(endPoint.url,
                  options: Options(headers: headers),
                  data: requestModel.toJson(),
                  cancelToken: cancelToken))
              .data;
      }
    } on DioError catch (e) {
      switch (e.response.statusCode) {
        //logout
      }
      return e.response.data;
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw FormatException("Unable to process the data");
    } catch (e) {
      throw e;
    }
  }
}
