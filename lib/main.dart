import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cryptotracker/blocs/crypto/crypto_bloc.dart';
import 'package:cryptotracker/data/local_data_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ui_screens/home_page.dart';
import 'models/coin_model.dart';
import 'injection_container.dart';
import 'package:http/http.dart' as http;

import 'repositories/crypto_repository.dart';


late final sharedPreferences;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Crypto notifications',
          enableLights: true,
          playSound: false,
          enableVibration: true,
          channelDescription: 'Crypto notifications test',
        )
      ],
      debug: false);
  sharedPreferences = await SharedPreferences.getInstance();
  await init(sharedPreferences);
  initializeService();
  runApp(MyApp());

}



class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Tracker',
      theme: ThemeData.light(),
      home: BlocProvider<CryptoBloc>(
        create: (buidcontext) =>
            CryptoBloc(cryptoRepository: getIt.get<CryptoRepository>(),initialState:CryptoStateInitial()),
        child: MyHomePage(title: 'Crypto Tracker'),
      ),
    );
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
}

// to ensure this executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch
void onIosBackground() {
  WidgetsFlutterBinding.ensureInitialized();
  backgroundTask();
}

Future<void> onStart() async {
  WidgetsFlutterBinding.ensureInitialized();
  backgroundTask();
}


void backgroundTask() async{
  final service = FlutterBackgroundService();

  // bring to foreground
  service.setForegroundMode(true);

  const String _baseUrl = 'https://api.coindesk.com/';
  http.Client client = http.Client();
  Timer.periodic(Duration(seconds: 1), (timer) async {
    if (!(await service.isServiceRunning())) timer.cancel();
    fetchData(_baseUrl, client, service);

  });

}



void fetchData(String _baseUrl, http.Client client,
    FlutterBackgroundService service) async {
  final requestUrl = '${_baseUrl}v1/bpi/currentprice.json';
  try {
    final response = await client.get(Uri.parse(requestUrl));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = await json.decode(response.body);
      Future.delayed(const Duration(milliseconds: 1000), () async{
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.toString();
      });
      var result = Coin.fromJson(data);
      service.sendData(
        {
          "dateTime": result.dateTime,
          "chartName": result.chartName,
          "code": result.code,
          "symbol": result.symbol,
          "rate": result.rate,
          "description": result.description,
          "rate_float": result.rate_float,
        },
      );

    }
  } catch (err) {
    print(err);
  }


}



