import 'dart:convert';
import 'package:cryptotracker/models/coin_model.dart';
import 'package:cryptotracker/models/failure_model.dart';
import 'package:http/http.dart' as http;

class CryptoRepository {
  static const String _baseUrl = 'https://api.coindesk.com/';
  static const int perPage = 20;

  final http.Client _httpClient;

  CryptoRepository({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  Future<List<Coin>> getCoinDesk( ) async {
    final requestUrl =
        '${_baseUrl}v1/bpi/currentprice.json';
    try {
      final response = await _httpClient.get(Uri.parse(requestUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        final List<Coin> coinList = [];
        var coinData = Coin.fromJson(data);
        coinList.add(coinData);
        return coinList;
      }
      return [];
    } catch (err) {
      print(err);
      throw Failure(message: err.toString());
    }
  }
}
