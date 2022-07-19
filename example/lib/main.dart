import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'config/app_config.dart';
import 'package:flutter_rest_client/flutter_rest_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  GetIt.I<AppConfig>().initialize(
      appName: 'Flutter Rest Client',
      baseUrl: 'https://beta.worldstory.life/api/v1/',
      flavorName: Environment.dev);
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IHttpHelper httpHelper;
    return Center(child: MaterialButton(onPressed: ()async {

    },child: Text('Load Data'),),);
  }
}
