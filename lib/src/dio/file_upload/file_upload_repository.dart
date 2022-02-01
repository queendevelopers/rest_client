import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:flutter_rest_client/flutter_rest_client.dart';
import 'package:flutter_rest_client/src/dio/dio_builder.dart';

abstract class IFileUploadRepository {
  Future<dynamic> uploadSingleFile(
      {required IRequestEndPoint endPoint,
      required String filePath,
      String filename,
      String key});
}

class FileUploadRepository implements IFileUploadRepository {
  final Dio _dio;

  FileUploadRepository({required IHttpConfig config})
      : _dio = DioBuilder(config: config).build();

  @override
  Future uploadSingleFile(
      {required IRequestEndPoint endPoint,
      required String filePath,
      String? filename,
      String key = 'file'}) async {
    try {
      String? mimetype = lookupMimeType(filePath);
      final formData = FormData.fromMap({
        key: await MultipartFile.fromFile(filePath,
            filename: filename, contentType: MediaType.parse(mimetype!))
      });
      final response = await _dio.post(endPoint.url, data: formData);
      return response.data;
    } on DioError catch (e) {
      debugPrint(e.message);
      rethrow;
    }
  }
}
