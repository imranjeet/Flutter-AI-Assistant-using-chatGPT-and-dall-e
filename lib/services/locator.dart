import 'package:get_it/get_it.dart';
import 'package:myassistant/services/db_services.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => DBService());
}
