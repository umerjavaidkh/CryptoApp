part of 'crypto_bloc.dart';

/*enum CryptoStatus { initial, loading, loaded, error }

class CryptoState extends Equatable {
  final Coin coin;
  final CryptoStatus status;
  final Failure failure;

  const CryptoState({
    required this.coin,
    required this.status,
    required this.failure,
  });

  factory CryptoState.initial() => const CryptoState(
        coin:  Coin(dateTime: "", chartName: "chartName", code: "USD", symbol: "", rate: "", description: "description", rate_float: 0.0),
        status: CryptoStatus.initial,
        failure: Failure(),
      );

  @override
  List<Object> get props => [coin, status, failure];

  CryptoState copyWith({
    Coin? coins,
    CryptoStatus? status,
    Failure? failure,
  }) {
    return CryptoState(
      coin: coin,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}*/


abstract class CryptoState extends Equatable {
  const CryptoState();
}

class CryptoStateInitial extends CryptoState {
  const CryptoStateInitial();
  @override
  List<Object> get props => [];
}

class CryptoStateLoading extends CryptoState {
  const CryptoStateLoading();
  @override
  List<Object> get props => [];
}

class CryptoStateLoaded extends CryptoState {
  final Coin coin;
  CryptoStateLoaded(this.coin);
  @override
  List<Object> get props => [coin];
}

class CryptoStateError extends CryptoState {
  final String message;
  const CryptoStateError(this.message);
  @override
  List<Object> get props => [message];
}
