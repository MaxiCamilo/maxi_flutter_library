import 'package:shared_preferences/shared_preferences.dart';

mixin PersistentValues {
  static Future<void> setInt({required String name, required int value}) async {
    await SharedPreferencesAsync().setInt(name, value);
  }

  static Future<void> setBool({required String name, required bool value}) async {
    await SharedPreferencesAsync().setBool(name, value);
  }

  static Future<void> setDouble({required String name, required double value}) async {
    await SharedPreferencesAsync().setDouble(name, value);
  }

  static Future<void> setString({required String name, required String value}) async {
    await SharedPreferencesAsync().setString(name, value);
  }

  static Future<void> setStringList({required String name, required List<String> value}) async {
    await SharedPreferencesAsync().setStringList(name, value);
  }

  static Future<int> getInt({required String name, required int defaultValue}) async {
    final result = await SharedPreferencesAsync().getInt(name);
    if (result == null) {
      await SharedPreferencesAsync().setInt(name, defaultValue);
      return defaultValue;
    } else {
      return result;
    }
  }

  static Future<bool> getBool({required String name, required bool defaultValue}) async {
    final result = await SharedPreferencesAsync().getBool(name);
    if (result == null) {
      await SharedPreferencesAsync().setBool(name, defaultValue);
      return defaultValue;
    } else {
      return result;
    }
  }

  static Future<double> getDouble({required String name, required double defaultValue}) async {
    final result = await SharedPreferencesAsync().getDouble(name);
    if (result == null) {
      await SharedPreferencesAsync().setDouble(name, defaultValue);
      return defaultValue;
    } else {
      return result;
    }
  }

  static Future<String> getString({required String name, required String defaultValue}) async {
    final result = await SharedPreferencesAsync().getString(name);
    if (result == null) {
      await SharedPreferencesAsync().setString(name, defaultValue);
      return defaultValue;
    } else {
      return result;
    }
  }

  static Future<List<String>> getStringList({required String name, required List<String> defaultValue}) async {
    final result = await SharedPreferencesAsync().getStringList(name);
    if (result == null) {
      await SharedPreferencesAsync().setStringList(name, defaultValue);
      return defaultValue;
    } else {
      return result;
    }
  }
}
