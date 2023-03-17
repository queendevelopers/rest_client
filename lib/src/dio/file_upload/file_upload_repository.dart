import 'package:dio/dio.dart';
import 'package:flutter_rest_client/flutter_rest_client.dart';
import 'package:flutter_rest_client/src/dio/dio_builder.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

abstract class IFileUploadRepository {
  Future<dynamic> uploadSingleFile({
    required IRequestEndPoint endPoint,
    required String filePath,
    String filename,
    String key,
  });

  Future<dynamic> uploadMultipleFile({
    required IRequestEndPoint endPoint,
    required List<String> filePath,
    String key,
  });

  Future<dynamic> uploadImageAndFormData(
      {required IRequestEndPoint endPoint,
      required FormData data,
      RequestMethod requestMethod = RequestMethod.POST});
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
    } on DioError {
      rethrow;
    }
  }

  @override
  Future uploadMultipleFile(
      {required IRequestEndPoint endPoint,
      required List<String> filePath,
      String key = 'file'}) async {
    List<MultipartFile> multipartImageList = [];
    for (var file in filePath) {
      if (file.isNotEmpty) {
        String? mimetype = lookupMimeType(file);
        MultipartFile multipartFile = await MultipartFile.fromFile(
          file,
          filename: file.split('/').last,
          contentType: MediaType.parse(mimetype!),
        );
        multipartImageList.add(multipartFile);
      }
    }
    FormData formData = FormData.fromMap({
      key: multipartImageList,
    });

    final response = await _dio.post(endPoint.url, data: formData);
    return response.data;
  }

  @override
  Future<dynamic> uploadImageAndFormData(
      {required IRequestEndPoint endPoint,
      required FormData data,
      RequestMethod requestMethod = RequestMethod.POST}) async {
    try {
      if (requestMethod == RequestMethod.PATCH) {
        var response = await _dio.patch(
          endPoint.url,
          data: data,
        );
        return response.data;
      }
      var response = await _dio.post(
        endPoint.url,
        data: data,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
