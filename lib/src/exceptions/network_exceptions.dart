// import 'package:dio/dio.dart';
//
// class NetworkExceptions{
//   static ErrorsWithReason getErrorsWithReason(
//       NetworkExceptions networkExceptions) {
//     var errorMessage = "";
//     Map<String, dynamic> errorsMap;
//     networkExceptions.when(notImplemented: () {
//       errorMessage = "Not Implemented";
//     }, requestCancelled: () {
//       errorMessage = "Request Cancelled";
//     }, internalServerError: () {
//       errorMessage = "Internal Server Error";
//     }, notFound: (String reason) {
//       errorMessage = reason;
//     }, serviceUnavailable: () {
//       errorMessage = "Service unavailable";
//     }, methodNotAllowed: () {
//       errorMessage = "Method Allowed";
//     }, badRequest: (String reason, dynamic errors) {
//       errorMessage = reason;
//       errorsMap = errors;
//     }, tokenExpired: (String reason) {
//       errorMessage = reason;
//     }, unauthorizedRequest: (String reason) {
//       errorMessage = reason;
//     }, unexpectedError: () {
//       errorMessage = "Unexpected error occurred";
//     }, requestTimeout: () {
//       errorMessage = "Connection request timeout";
//     }, noInternetConnection: () {
//       errorMessage = "No internet connection";
//     }, conflict: () {
//       errorMessage = "Error due to a conflict";
//     }, sendTimeout: () {
//       errorMessage = "Timeout in connection with server";
//     }, unableToProcess: () {
//       errorMessage = "Unable to process the data";
//     }, defaultError: (String error) {
//       errorMessage = error;
//     }, formatException: () {
//       errorMessage = "Unexpected error occurred";
//     }, notAcceptable: () {
//       errorMessage = "Not acceptable";
//     });
//     return ErrorsWithReason(errorMessage, errors: errorsMap);
//   }
// }
