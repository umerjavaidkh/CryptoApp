import 'package:equatable/equatable.dart';

class Coin extends Equatable {
  final String dateTime;
  final String chartName;
  final String code;
  final String symbol;
  final String rate;
  final String description;
  final double rate_float;

  const Coin({
    required this.dateTime,
    required this.chartName,
    required this.code,
    required this.symbol,
    required this.rate,
    required this.description,
    required this.rate_float,
  });

  @override
  List<Object?> get props => [dateTime, chartName, code,symbol,rate,description,rate_float];

  factory Coin.fromJson(Map<String, dynamic> map) {
    return Coin(
      dateTime: map['time']?['updated'] ?? '',
      chartName: map['chartName'] ?? '',
      code: map['bpi']?['USD']?['code'] ?? '',
      symbol: map['bpi']?['USD']?['symbol'] ?? '',
      rate: map['bpi']?['USD']?['rate'] ?? '',
      description: map['bpi']?['USD']?['description'] ?? '',
      rate_float: map['bpi']?['USD']?['rate_float'] ?? 0,
    );
  }

  factory Coin.fromMap(Map<String, dynamic> map) {
    return Coin(
      dateTime: map['dateTime']?? '',
      chartName: map['chartName'] ?? '',
      code: map['code'] ?? '',
      symbol: map['symbol'] ?? '',
      rate: map['rate'] ?? '',
      description: map['description'] ?? '',
      rate_float: map['rate_float'] ?? 0,
      );
  }

  Map<String,dynamic> toJson() =>
      {
      "dateTime": this.dateTime,
      "chartName": this.chartName,
      "code": this.code,
      "symbol": this.symbol,
      "rate":this.rate,
      "description": this.description,
      "rate_float": this.rate_float,

  };
}
