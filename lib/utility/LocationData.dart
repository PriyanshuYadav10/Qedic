import 'package:country_state_city/country_state_city.dart';

class LocationData {
  static List<String>? _rajasthanCache;

  static Future<List<String>> rajasthanCities() async {
    if (_rajasthanCache != null) return _rajasthanCache!;
    final cities = await getStateCities('IN', 'RJ');
    _rajasthanCache = cities.map((c) => c.name).toList()..sort();
    return _rajasthanCache!;
  }
}
