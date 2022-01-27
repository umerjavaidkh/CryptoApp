import 'package:cryptotracker/repositories/crypto_repository.dart';
import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'data/local_data_source.dart';
import 'data/remote_data_source.dart';
import 'main.dart';
import 'network/network_info.dart';
import 'repositories/crypto_repository_imp.dart';

GetIt getIt = GetIt.instance;



Future<void> init(SharedPreferences sharedPreferences) async {

  getIt.registerLazySingleton<CryptoRepository>(() => CryptoRepositoryImp(
    localDataSource: getIt(),
    remoteDataSource: getIt(),
    networkInfo: getIt()
  ));


  // Data sources
  getIt.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(client: getIt()),
  );

  getIt.registerLazySingleton<LocalDataSource>(
    () => LocalDataSourceImpl(sharedPreferences: getIt()),
  );

  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()));


  getIt.registerLazySingleton(() => sharedPreferences);
  getIt.registerLazySingleton(() => http.Client());
  getIt.registerLazySingleton(() => DataConnectionChecker());


}
