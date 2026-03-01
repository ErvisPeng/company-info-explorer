import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WatchlistLocalDataSource {
  final SharedPreferences prefs;
  static const String _key = 'watchlist_stock_codes';

  WatchlistLocalDataSource(this.prefs);

  List<String> getWatchlist() {
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List<dynamic> list = jsonDecode(jsonString);
    return list.cast<String>();
  }

  Future<void> saveWatchlist(List<String> stockCodes) {
    return prefs.setString(_key, jsonEncode(stockCodes));
  }
}
