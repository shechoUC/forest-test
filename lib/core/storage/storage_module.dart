import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class StorageModule {
  /// Resolved before the app starts so repositories can read it synchronously.
  @preResolve
  Future<SharedPreferences> get preferences => SharedPreferences.getInstance();
}
