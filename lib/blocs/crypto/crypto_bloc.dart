import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cryptotracker/models/coin_model.dart';
import 'package:cryptotracker/models/failure_model.dart';
import 'package:cryptotracker/repositories/crypto_repository.dart';
import 'package:equatable/equatable.dart';

part 'crypto_event.dart';
part 'crypto_state.dart';

class CryptoBloc extends Bloc<CryptoEvent, CryptoState> {
  final CryptoRepository _cryptoRepository;

  CryptoBloc({required CryptoRepository cryptoRepository})
      : _cryptoRepository = cryptoRepository,
        super(CryptoState.initial());

  @override
  Stream<CryptoState> mapEventToState(
    CryptoEvent event,
  ) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    } else if (event is RefreshCoins) {
      yield* _getCoinDesk();
    }
  }

  Stream<CryptoState> _getCoinDesk( ) async* {
    try {
      final coin = await _cryptoRepository.getCoinDesk();
      yield state.copyWith(coins: coin, status: CryptoStatus.loaded);
    } on Failure catch (err) {
      yield state.copyWith(
        failure: err,
        status: CryptoStatus.error,
      );
    }
  }

  Stream<CryptoState> _mapAppStartedToState() async* {
    yield state.copyWith(status: CryptoStatus.loading);
    yield* _getCoinDesk();
  }


}
