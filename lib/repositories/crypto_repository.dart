
import 'package:cryptotracker/models/coin_model.dart';

abstract class CryptoRepository{


  Future<Coin> getCoinDesk( );

  @override
  Future<double> getMaxRateLimit();

  @override
  Future<double> getMinRateLimit();

  @override
  Future<void> saveMaxRateLimit(double maxRateToCache);

  @override
  Future<void> saveMinRateLimit(double minRateToCache);
}