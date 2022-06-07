import 'dart:io';

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_exception.freezed.dart';

@freezed
class NetworkException with _$NetworkException {
  const factory NetworkException.requestCancelled() = RequestCancelled;

  const factory NetworkException.unauthorizedRequest(String reason) =
      UnauthorizedRequest;

  const factory NetworkException.tokenExpired(String reason) = TokenExpired;

  const factory NetworkException.badRequest(String message, dynamic errors) =
      BadRequest;

  const factory NetworkException.notFound(String reason) = NotFound;

  const factory NetworkException.methodNotAllowed() = MethodNotAllowed;

  const factory NetworkException.notAcceptable() = NotAcceptable;

  const factory NetworkException.requestTimeout() = RequestTimeout;

  const factory NetworkException.sendTimeout() = SendTimeout;

  const factory NetworkException.conflict() = Conflict;

  const factory NetworkException.internalServerError() = InternalServerError;

  const factory NetworkException.notImplemented() = NotImplemented;

  const factory NetworkException.serviceUnavailable() = ServiceUnavailable;

  const factory NetworkException.noInternetConnection() = NoInternetConnection;

  const factory NetworkException.formatException() = FormatException;

  const factory NetworkException.unableToProcess() = UnableToProcess;

  const factory NetworkException.defaultError(String error) = DefaultError;

  const factory NetworkException.unexpectedError() = UnexpectedError;

  static NetworkException handleResponse(
      {required int statusCode, dynamic data, required String message}) {
    switch (statusCode) {
      case 400:
        return NetworkException.badRequest(message, data);
      case 401:
        return NetworkException.unauthorizedRequest(message);
      case 403:
        return NetworkException.tokenExpired(message);
      case 404:
        return NetworkException.notFound('404 path not found');
      case 409:
        return NetworkException.conflict();
      case 408:
        return NetworkException.requestTimeout();
      case 500:
        return NetworkException.internalServerError();
      case 503:
        return NetworkException.serviceUnavailable();
      default:
        var responseCode = statusCode;
        return NetworkException.defaultError(
          "Received invalid status code: $responseCode",
        );
    }
  }

  static NetworkException getDioException(error) {
    if (error is Exception) {
      try {
        NetworkException networkException;
        if (error is DioError) {
          switch (error.type) {
            case DioErrorType.cancel:
              networkException = NetworkException.requestCancelled();
              break;
            case DioErrorType.connectTimeout:
              networkException = NetworkException.requestTimeout();
              break;
            case DioErrorType.other:
              networkException = NetworkException.noInternetConnection();
              break;
            case DioErrorType.receiveTimeout:
              networkException = NetworkException.sendTimeout();
              break;
            case DioErrorType.response:
              networkException = NetworkException.handleResponse(
                  statusCode: error.response?.statusCode ?? 0,
                  data: error.response,
                  message: error.message);
              break;
            case DioErrorType.sendTimeout:
              networkException = NetworkException.sendTimeout();
              break;
          }
        } else if (error is SocketException) {
          networkException = NetworkException.noInternetConnection();
        } else {
          networkException = NetworkException.unexpectedError();
        }
        return networkException;
      } on FormatException catch (e) {
        return NetworkException.formatException();
      } catch (_) {
        return NetworkException.unexpectedError();
      }
    } else {
      if (error.toString().contains("is not a subtype of")) {
        return NetworkException.unableToProcess();
      } else {
        return NetworkException.unexpectedError();
      }
    }
  }

  static String getErrorMessage(NetworkException networkException) {
    var errorMessage = "An Unknown Error Occurred";
    networkException.when(notImplemented: () {
      errorMessage = "Not Implemented";
    }, requestCancelled: () {
      errorMessage = "Request Cancelled";
    }, internalServerError: () {
      errorMessage = "Internal Server Error";
    }, notFound: (String reason) {
      errorMessage = reason;
    }, serviceUnavailable: () {
      errorMessage = "Service unavailable";
    }, methodNotAllowed: () {
      errorMessage = "Method Allowed";
    }, badRequest: (message, errors) {
      errorMessage = message;
    }, unauthorizedRequest: (String error) {
      errorMessage = error;
    }, unexpectedError: () {
      errorMessage = "Unexpected error occurred";
    }, requestTimeout: () {
      errorMessage = "Connection request timeout";
    }, noInternetConnection: () {
      errorMessage = "No internet connection";
    }, conflict: () {
      errorMessage = "Error due to a conflict";
    }, sendTimeout: () {
      errorMessage = "Send timeout in connection with API server";
    }, unableToProcess: () {
      errorMessage = "Unable to process the data";
    }, defaultError: (String error) {
      errorMessage = error;
    }, formatException: () {
      errorMessage = "Unexpected error occurred";
    }, notAcceptable: () {
      errorMessage = "Not acceptable";
    }, tokenExpired: (String reason) {
      errorMessage = reason;
    });
    return errorMessage;
  }
}
