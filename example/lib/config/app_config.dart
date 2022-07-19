import 'package:injectable/injectable.dart';

@LazySingleton()
class AppConfig {
  late String appName;
  late String baseUrl;
  late String flavorName;

  void initialize(
      {required String appName,
      required String baseUrl,
      required String flavorName}) {
    this.appName = appName;
    this.baseUrl = baseUrl;
    this.flavorName = flavorName;
  }

  String getBaseUrl() => baseUrl;

  String getFlavorName() => flavorName;

  String getAppName() => appName;
}
