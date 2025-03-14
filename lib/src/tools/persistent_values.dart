import 'package:shared_preferences/shared_preferences.dart';

class PersistentValues {
  final String prefix;

  const PersistentValues({required this.prefix});

  Future<void> setInt({required String name, required int value}) async {
    await SharedPreferencesAsync().setInt('$prefix.$name', value);
  }

  Future<void> setBool({required String name, required bool value}) async {
    await SharedPreferencesAsync().setBool('$prefix.$name', value);
  }

  Future<void> setDouble({required String name, required double value}) async {
    await SharedPreferencesAsync().setDouble('$prefix.$name', value);
  }

  Future<void> setString({required String name, required String value}) async {
    await SharedPreferencesAsync().setString('$prefix.$name', value);
  }

  Future<void> setStringList({required String name, required List<String> value}) async {
    await SharedPreferencesAsync().setStringList('$prefix.$name', value);
  }

  Future<int> getInt({required String name, required int defaultValue}) async {
    final result = await SharedPreferencesAsync().getInt('$prefix.$name');
    if (result == null) {
      await SharedPreferencesAsync().setInt('$prefix.$name', defaultValue);
      return defaultValue;
    } else {
      return result;
    }
  }

  Future<bool> getBool({required String name, required bool defaultValue}) async {
    final result = await SharedPreferencesAsync().getBool('$prefix.$name');
    if (result == null) {
      await SharedPreferencesAsync().setBool('$prefix.$name', defaultValue);
      return defaultValue;
    } else {
      return result;
    }
  }

  Future<double> getDouble({required String name, required double defaultValue}) async {
    final result = await SharedPreferencesAsync().getDouble('$prefix.$name');
    if (result == null) {
      await SharedPreferencesAsync().setDouble('$prefix.$name', defaultValue);
      return defaultValue;
    } else {
      return result;
    }
  }

  Future<String> getString({required String name, required String defaultValue}) async {
    final result = await SharedPreferencesAsync().getString('$prefix.$name');
    if (result == null) {
      await SharedPreferencesAsync().setString('$prefix.$name', defaultValue);
      return defaultValue;
    } else {
      return result;
    }
  }

  Future<List<String>> getStringList({required String name, required List<String> defaultValue}) async {
    final result = await SharedPreferencesAsync().getStringList('$prefix.$name');
    if (result == null) {
      await SharedPreferencesAsync().setStringList('$prefix.$name', defaultValue);
      return defaultValue;
    } else {
      return result;
    }
  }

  Future<void> clearAllKeys() async {
    for (final item in (await SharedPreferencesAsync().getAll()).entries.toList(growable: false)) {
      if (item.key.startsWith('$prefix.')) {
        await SharedPreferencesAsync().remove(item.key);
      }
    }
  }
}
