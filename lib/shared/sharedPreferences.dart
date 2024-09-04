import 'package:shared_preferences/shared_preferences.dart';

Future<void> savedIp(String id, String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(id, value);
}

Future<String?> getIp(String id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(id);
}

Future<String?> removeSavedIp() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('ip');
  return null;
}
