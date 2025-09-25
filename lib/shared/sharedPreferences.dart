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
  print('Borrado');
  return null;
}

Future<void> savedMac(String id, String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(id, value);
}

Future<String?> getMac(String id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(id);
}

Future<String?> removeSavedMac() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('mac');
  print('Borrado');
  return null;
}
