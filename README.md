# flutter_rest_client

A module that uses powerful http library [dio](https://pub.dev/packages/dio) for network calls.

## Introduction
flutter_rest_client is a network module that has been created seperately for easily maintaining code for dio. The usage of this module is pretty simple,
just add the module to `pubspec.yaml` inside `dependencies` like following:
```dart

   flutter_rest_client:
     path: ./flutter_rest_client
```
 One more configuration, flutter_rest_client is wrapped with dependency injection, which uses the project's [getIt](https://pub.dev/packages/get_it) locator. Form the root of the project you must configure dependency first and then initialize with the following code:

```dart
  GetIt.I<AppConfig>().initialize(
    appName: 'appName',
    baseUrl: 'https://domain.com/v1/',
  );
```

 `AppConfig` is part of project dependency, from which we use the baseUrl in our `flutter_rest_client`.

 ## Basic Usage
```dart
response = await httpHelper.request(RequestEndpoint(), BaseRequestModel(),headers: {});
```
headers parameter is optional, basic map set is setup in request interceptor.

Besides above uses, others are the basic functionality that uses the dio features.

#### Injection that need from the application [getIt](https://pub.dev/packages/get_it) with [injectable](https://pub.dev/packages/injectable).

```dart
@Named('httpConfig')
@Singleton(as: IHttpConfig)
class HttpConfig implements IHttpConfig {
  final AppConfig _appConfig;
  final ISessionManager _iSessionManager;

  HttpConfig(this._appConfig, this._iSessionManager);

  @override
  int connectTimeout = 8000;

  @override
  String contentType = AppKeys.applicationJson;

  @override
  int receiveTimeout = 8000;

  @override
  String get baseUrl => _appConfig.baseUrl;

  @override
  int connectionTimeout = 8000;

  @override
  Future<String?> get token => _sessionManager.getToken();
}
```