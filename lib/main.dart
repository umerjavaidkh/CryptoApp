import 'dart:async';

import 'package:cryptotracker/data/local_data_source.dart';
import 'package:cryptotracker/data/remote_data_source.dart';
import 'package:cryptotracker/network/network_info.dart';
import 'package:cryptotracker/repositories/crypto_repository_imp.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart' as intl;
import 'models/coin_model.dart';
import 'injection_container.dart' ;
import 'package:http/http.dart' as http;




void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  initializeService();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Crypto Tracker'),
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
  print('FLUTTER BACKGROUND FETCH');


  Fluttertoast.showToast(
      msg: "This is Center Short Toast",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0
  );

}

Future<void> onStart() async{
  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();
  service.onDataReceived.listen((event) {
    if (event!["action"] == "setAsForeground") {
      service.setForegroundMode(true);
      return;
    }

    if (event["action"] == "setAsBackground") {
      service.setForegroundMode(false);
    }

    if (event["action"] == "stopService") {
      service.stopBackgroundService();
    }

  });


  final sharedPreferences =await  SharedPreferences.getInstance();


  final  cryptoRepositoryServiceObject = CryptoRepositoryImp(
      localDataSource: LocalDataSourceImpl(sharedPreferences: sharedPreferences),
      remoteDataSource: RemoteDataSourceImpl(client: http.Client()),
      networkInfo: NetworkInfoImpl(DataConnectionChecker())
  );


  // bring to foreground
  service.setForegroundMode(true);
  Timer.periodic(Duration(seconds: 3), (timer) async {
    if (!(await service.isServiceRunning())) timer.cancel();


    var result = await cryptoRepositoryServiceObject.getCoinDesk();

    print(result.toString());
    await sharedPreferences.reload();
    var tempMinLimit =await cryptoRepositoryServiceObject.getMinRateLimit();
    var tempMaxLimit =await cryptoRepositoryServiceObject.getMaxRateLimit();

    if(result.rate_float<=tempMinLimit){

      service.setNotificationInfo(
        title: "Crypto Tracker Service",
        content: "Min Limit Reached ${result.rate}",
      );

    }else if(result.rate_float >= tempMaxLimit){

      service.setNotificationInfo(
        title: "Crypto Tracker Service",
        content: "Max Limit Reached ${result.rate}",
      );

    }
    else{

      service.setNotificationInfo(
        title: "Crypto Tracker Service",
        content: "Rate Updated ${result.rate}",
      );

    }


    service.sendData(
      {
        "dateTime": result.dateTime,
        "chartName": result.chartName,
        "code": result.code,
        "symbol": result.symbol,
        "rate":result.rate,
        "description": result.description,
        "rate_float": result.rate_float,
      },
    );
  });
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String text = "Stop Service";
  double minRate = 43200.1255;
  double maxRate = 43500.3422;
  final TextEditingController minTextEditingController = TextEditingController();
  final TextEditingController maxTextEditingController = TextEditingController();
  final List<Coin> currentCoinsList = [];
  final formGlobalKey = GlobalKey < FormState > ();


  @override
  void initState() {

    getRateLimits();

    super.initState();
  }

  void getRateLimits()async{

    var tempMinLimit =await cryptoRepository.getMinRateLimit();
    if(tempMinLimit>0) minRate=tempMinLimit;
    var tempMaxLimit =await cryptoRepository.getMaxRateLimit();
    if(tempMaxLimit>0) maxRate=tempMaxLimit;

  }


  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title:
          const Text('Service App'),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Form(
                  key: formGlobalKey,
                  child:
                  Column(children: [


                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Text(
                          "Min Accepted Rate $minRate",
                          style: TextStyle(
                              fontFamily: "SFProDisplay",
                              fontSize: 18,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),

                      ],),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [

                        Container(
                          width: 150,
                          child:  TextFormField(
                            key: Key("12345"),
                            controller: minTextEditingController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "min rate",
                              counterText: '',
                              hintStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
                            ),
                            validator: (rate){


                              if (rate!.isNotEmpty) return null;
                              else
                                return 'Please Enter Min Limit';

                            },
                            autofocus: true,
                            autocorrect: false,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.numberWithOptions(signed:true,decimal: true),
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
                            textInputAction: TextInputAction.done,
                            maxLength: 12,
                            inputFormatters: [
                            ],
                          ),),

                        ElevatedButton(
                          child: Text("Add"),
                          onPressed: ()async{
                            if(minTextEditingController.text.isNotEmpty){
                              minRate = double.tryParse(minTextEditingController.text)??minRate;
                              cryptoRepository.saveMinRateLimit(minRate);
                            }else{

                              Fluttertoast.showToast(
                                  msg: "MIN LIMIT SHOULD NOT BE EMPTY",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );

                            }
                            setState(() {});
                            minTextEditingController.text="";
                          },
                        ),

                      ],),

                    SizedBox(height: 10,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Text(
                          "Max Accepted Rate $maxRate",
                          style: TextStyle(
                              fontFamily: "SFProDisplay",
                              fontSize: 18,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),

                      ],),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [

                        Container(
                          width: 150,
                          child:  TextFormField(
                            key: Key("54321"),
                            controller: maxTextEditingController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "max rate",
                              counterText: '',
                              hintStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
                            ),
                            validator: (rate){

                              if (rate!.isNotEmpty) return null;
                              else
                                return 'Please Enter Max Limit';

                            },
                            autofocus: true,
                            autocorrect: false,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.numberWithOptions(signed:true,decimal: true),
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
                            textInputAction: TextInputAction.done,
                            maxLength: 12,
                            inputFormatters: [
                            ],
                          ),),

                        ElevatedButton(
                          child: Text("Add"),
                          onPressed: () async{

                            if(maxTextEditingController.text.isNotEmpty){
                              maxRate = double.tryParse(maxTextEditingController.text)??maxRate;
                              cryptoRepository.saveMaxRateLimit(maxRate);
                            }else{
                              Fluttertoast.showToast(
                                  msg: "MAX LIMIT SHOULD NOT BE EMPTY",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );
                            }
                            setState(() {});
                            maxTextEditingController.text="";
                          },
                        ),

                      ],),


                  ],)),

              Divider(thickness: 10,),

              StreamBuilder<Map<String, dynamic>?>(
                stream: FlutterBackgroundService().onDataReceived,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final data = snapshot.data!;
                  Coin? coinData = Coin.fromMap(data);
                  //DateTime? date = DateTime.tryParse(data["coin_data"]);
                  currentCoinsList.add(coinData);
                  return
                    Container(

                        child:
                        Center(
                          child: Column(children: [
                            Text(
                              coinData.rate,
                              style: TextStyle(
                                  fontFamily: "SFProDisplay",
                                  fontSize: 24,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10,),
                            SfCartesianChart(
                              enableAxisAnimation: true,
                              primaryXAxis: DateTimeAxis(
                                dateFormat: intl.DateFormat.Hms(),
                                intervalType: DateTimeIntervalType.minutes,
                                desiredIntervals: 5,
                                axisLine: AxisLine(width: 2, color: Colors.white),
                                majorTickLines: MajorTickLines(color: Colors.transparent),
                              ),
                              primaryYAxis: NumericAxis(
                                numberFormat: intl.NumberFormat('##,###.0000'),
                                desiredIntervals: 2,
                                decimalPlaces: 4,
                                axisLine: AxisLine(width: 2, color: Colors.white),
                                majorTickLines: MajorTickLines(color: Colors.transparent),
                              ),
                              plotAreaBorderColor: Colors.white.withOpacity(0.2),
                              plotAreaBorderWidth: 0.2,
                              series: <LineSeries<Coin, DateTime>>[
                                LineSeries<Coin, DateTime>(
                                  animationDuration: 0.0,
                                  width: 2,
                                  color: Theme.of(context).primaryColor,
                                  dataSource: currentCoinsList,
                                  xValueMapper: (Coin coin, _) => DateTime.tryParse(coin.dateTime)??DateTime.now(),
                                  yValueMapper: (Coin coin, _) => coin.rate_float,
                                )
                              ],
                            )
                          ],),)
                    );
                },
              ),

              SizedBox(height: 30,),




              /* ElevatedButton(
              child: Text("Foreground Mode"),
              onPressed: () {
                FlutterBackgroundService()
                    .sendData({"action": "setAsForeground"});
              },
            ),
            ElevatedButton(
              child: Text("Background Mode"),
              onPressed: () {
                FlutterBackgroundService()
                    .sendData({"action": "setAsBackground"});
              },
            ),
            ElevatedButton(
              child: Text(text),
              onPressed: () async {
                final service = FlutterBackgroundService();
                var isRunning = await service.isServiceRunning();
                if (isRunning) {
                  service.sendData(
                    {"action": "stopService"},
                  );
                } else {
                  service.start();
                }

                if (!isRunning) {
                  text = 'Stop Service';
                } else {
                  text = 'Start Service';
                }
                setState(() {});
              },
            ),*/
            ],
          ),),
        resizeToAvoidBottomInset: false,
      ),
    )

      ;
  }
}
