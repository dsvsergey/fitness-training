import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@singleton
class EmailHistoryStorage {
  static const _key = 'recent_login_emails';
  static const _maxEntries = 5;

  Future<List<String>> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? const [];
  }

  Future<void> add(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? const [];
    final next = [
      normalized,
      ...current.where((e) => e.toLowerCase() != normalized),
    ].take(_maxEntries).toList();
    await prefs.setStringList(_key, next);
  }

  Future<void> clear() => SharedPreferences.getInstance()
      .then((prefs) => prefs.remove(_key));
}
