// ignore: depend_on_referenced_packages
import 'package:get_it/get_it.dart';

import '../Service/MQTTManager.dart';

GetIt service_locator = GetIt.instance;
void setupLocator() {
  service_locator.registerLazySingleton(() => MQTTManager());
}
