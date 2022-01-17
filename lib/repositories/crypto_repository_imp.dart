import 'dart:convert';
import 'package:cryptotracker/data/local_data_source.dart';
import 'package:cryptotracker/data/remote_data_source.dart';
import 'package:cryptotracker/models/coin_model.dart';
import 'package:cryptotracker/models/failure_model.dart';
import 'package:cryptotracker/network/network_info.dart';
import 'crypto_repository.dart';

class CryptoRepositoryImp implements CryptoRepository {

  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  CryptoRepositoryImp({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Coin> getCoinDesk() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteCoin= await remoteDataSource.getRemoteBitCoinData();
        localDataSource.cachedBitCoinData(remoteCoin);
        return remoteCoin;
      } catch (err) {
        throw Failure(message: err.toString());
      }
    } else {
      try {
        final localCoin = await localDataSource.getCachedBitCoinData();
        return localCoin;
      } catch (err) {
        throw Failure(message: err.toString());
      }
    }
  }


  @override
  Future<double> getMaxRateLimit() async{
    return localDataSource.getMaxRateLimit();
  }

  @override
  Future<double> getMinRateLimit() async{
    return localDataSource.getMinRateLimit();
  }

  @override
  Future<void> saveMaxRateLimit(double maxRateToCache) async {

    localDataSource.saveMaxRateLimit(maxRateToCache);

  }

  @override
  Future<void> saveMinRateLimit(double minRateToCache) async {
    localDataSource.saveMinRateLimit(minRateToCache);
  }



}


