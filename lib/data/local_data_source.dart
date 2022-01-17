import 'dart:convert';

import 'package:cryptotracker/models/coin_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalDataSource {
  Future<Coin> getCachedBitCoinData();
  Future<void> cachedBitCoinData(Coin coinToCache);
  Future<void> saveMinRateLimit(double minRateToCache);
  Future<void> saveMaxRateLimit(double minRateToCache);
  Future<double> getMaxRateLimit();
  Future<double> getMinRateLimit();

}

const CACHED_BITCOIN= 'CACHED_BITCOIN';
const CACHED_MIN_LIMIT_BITCOIN= 'MIN_LIMIT_CACHED_BITCOIN';
const CACHED_MAX_LIMIT_BITCOIN= 'MAX_LIMIT_CACHED_BITCOIN';
const double MIN_LIMIT_RARE_DEFAULT = 43200.1255;
const double MAX_LIMIT_RATE_DEFAULT = 43500.3422;

class LocalDataSourceImpl implements LocalDataSource {
 late final SharedPreferences  sharedPreferences;

  LocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<Coin> getCachedBitCoinData() async{

      final jsonString = sharedPreferences.getString(CACHED_BITCOIN);
      if (jsonString != null) {
        return Future.value(Coin.fromMap(json.decode(jsonString)));
      } else {
        throw Exception();
      }


  }

  @override
  Future<void> cachedBitCoinData(Coin coinToCache) async{
    var jsonObj = coinToCache.toJson();


        sharedPreferences.setString(
          CACHED_BITCOIN,
          json.encode(jsonObj),
        );

  }

  @override
  Future<double> getMaxRateLimit() async {

      return sharedPreferences.getDouble(
        CACHED_MAX_LIMIT_BITCOIN,
      )??MAX_LIMIT_RATE_DEFAULT;


  }

  @override
  Future<double> getMinRateLimit() async{

      var tempValue = sharedPreferences.getDouble(
        CACHED_MIN_LIMIT_BITCOIN,
      );
      return tempValue??MIN_LIMIT_RARE_DEFAULT;


  }

  @override
  Future<void> saveMaxRateLimit(double maxRateToCache) async {

      sharedPreferences.setDouble(
        CACHED_MAX_LIMIT_BITCOIN,
        maxRateToCache,
      );

  }

  @override
  Future<void> saveMinRateLimit(double minRateToCache) async {

      sharedPreferences.setDouble(
        CACHED_MIN_LIMIT_BITCOIN,
        minRateToCache,
      );


  }
}
