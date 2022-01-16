

import 'dart:convert';

import 'package:cryptotracker/models/coin_model.dart';
import 'package:cryptotracker/models/failure_model.dart';
import 'package:http/http.dart' as http;

abstract class RemoteDataSource {

  Future<Coin> getRemoteBitCoinData();
}

const CACHED_BITCOIN= 'CACHED_BITCOIN';


class RemoteDataSourceImpl implements RemoteDataSource {

  static const String _baseUrl = 'https://api.coindesk.com/';
  final http.Client client;

  RemoteDataSourceImpl({required this.client});

  @override
  Future<Coin> getRemoteBitCoinData() async{

    final requestUrl =
        '${_baseUrl}v1/bpi/currentprice.json';
    try {
      final response = await client.get(Uri.parse(requestUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = await json.decode(response.body);
        var coinData = Coin.fromJson(data);
        return coinData;
      }
      return throw Failure(message: "api error");
    } catch (err) {
      print(err);
      throw Failure(message: err.toString());
    }

  }


}
