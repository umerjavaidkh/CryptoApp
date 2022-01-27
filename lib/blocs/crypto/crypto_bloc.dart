import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cryptotracker/models/coin_model.dart';
import 'package:cryptotracker/models/failure_model.dart';
import 'package:cryptotracker/repositories/crypto_repository.dart';
import 'package:equatable/equatable.dart';

part 'crypto_event.dart';
part 'crypto_state.dart';

class CryptoBloc extends Bloc<CryptoEvent, CryptoState> {

  late final CryptoRepository _cryptoRepository;

  CryptoBloc({required CryptoRepository cryptoRepository,required CryptoState initialState}) : super(initialState){

    _cryptoRepository = cryptoRepository;
  }


  @override
  Stream<CryptoState> mapEventToState(
    CryptoEvent event,
  ) async* {

    if (event is AppStarted) {

      try {

        final coin = await _cryptoRepository.getCoinDesk();
        var result = CryptoStateLoaded(coin);
        yield result;
      } on Failure catch (err) {
        yield CryptoStateError(err.message);
      }

    } else if (event is RefreshCoins) {

      try {

        final coin = await _cryptoRepository.getCoinDesk();
        var result = CryptoStateLoaded(coin);
        yield result;
      } on Failure catch (err) {
        yield CryptoStateError(err.message);
      }
    }
  }




}
