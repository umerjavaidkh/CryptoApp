import 'dart:async';
import 'dart:convert';

import 'package:cryptotracker/alert_user_class.dart';
import 'package:cryptotracker/blocs/crypto/crypto_bloc.dart';
import 'package:cryptotracker/data/local_data_source.dart';
import 'package:cryptotracker/repositories/crypto_repository.dart';
import 'package:cryptotracker/widgets/form_widget.dart';
import 'package:cryptotracker/widgets/line_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/coin_model.dart';
import '../injection_container.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  List<double> coinsList = [];


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver{
  String text = "Stop Service";
  final List<Coin> currentCoinsList = [];
  late final AlertUserOnLimit alertUserOnLimit;



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    getIt.get<CryptoRepository>().setAppStatus(true);
    alertUserOnLimit = AlertUserOnLimit(cryptoRepository: getIt.get<CryptoRepository>());
    try {
      listenData();
    } catch (e) {
      print(e);
    }

  }

  void listenData() async {
    final service = FlutterBackgroundService();

    if (await service.isServiceRunning()) {
      service.onDataReceived.listen((event) {
        var currentDataCoint = Coin.fromMap(event!);
        LocalDataSource localDataSource = getIt.get<LocalDataSource>();
        localDataSource.cachedBitCoinData(currentDataCoint);
        CryptoBloc cryptoBloc = BlocProvider.of<CryptoBloc>(context);
        if (cryptoBloc != null) {
          cryptoBloc.add(RefreshCoins());
        }
        alertUserOnLimit.notifyUserIfLimitReached(currentValue:currentDataCoint.rate_float);
          });
    }
  }


  @override
  void dispose() {

    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    if(state==AppLifecycleState.inactive){
      getIt.get<CryptoRepository>().setAppStatus(false);
    }else if(state==AppLifecycleState.resumed){
      getIt.get<CryptoRepository>().setAppStatus(true);
    }

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xFF222531),
        appBar: AppBar(
          elevation: 2,
          backgroundColor: Color(0xFF0E0D0C),
          foregroundColor: Color(0xFF0E0D0C),
          title: const Text('BitCoin Crypto App',style: TextStyle(fontSize: 24,color:Colors.lightGreen,fontWeight: FontWeight.bold),),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              SizedBox(
                height: 20,
              ),

              Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: Center(child: BlocBuilder<CryptoBloc, CryptoState>(
                  builder: (context, state) {


                    if (state is CryptoStateLoading) {
                      return CircularProgressIndicator();
                    } else if (state is CryptoStateLoaded) {
                      if(widget.coinsList.length>30){
                        widget.coinsList.removeRange(0, 10);
                      }
                      widget.coinsList.add(state.coin.rate_float);
                      return Container(
                        width: MediaQuery.of(context).size.width,

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                        Container(
                          height: 220,
                          child: LineChartWidget(data: widget.coinsList),) ,

                        SizedBox(height: 6,),

                            FutureBuilder<String>(
                              future: getCurrentRateText(currentValue : state.coin.rate_float, cryptoRepository: getIt.get<CryptoRepository>()), // a Future<String> or null
                              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                return Text(
                                    snapshot.data??"",
                                  style: TextStyle(
                                      color: Colors.cyanAccent,
                                      fontFamily: "SFProDisplay",
                                      fontSize: 18,
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                );
                              },
                            )

                      ],),);
                    } else if (state is CryptoStateError) {
                      return CircularProgressIndicator();
                    } else
                      return Container();
                  },
                ),),
                height: 250,
              ),


              SizedBox(
                height: 20,
              ),

              HomePageForm(buildContext: context,)


            ],
          ),
        ),
        resizeToAvoidBottomInset: false,
      ),
    );
  }


  Future<String> getCurrentRateText({required  double currentValue,required CryptoRepository cryptoRepository})async{

    var minLimit = await cryptoRepository.getMinRateLimit();
    var maxLimit = await cryptoRepository.getMaxRateLimit();

    String toReturn = "Current rate = $currentValue";
    if(currentValue<=minLimit){
       toReturn="Min Limit Reached = $currentValue";
    }
    if(currentValue>=maxLimit){
      toReturn="Max Limit Reached = $currentValue";
    }
     return toReturn;
  }
}

