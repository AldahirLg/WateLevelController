import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_level_controller/shared/sharedPreferences.dart';

class ConfigProvider extends ChangeNotifier {
  String _ssidText = '';
  String _passText = '';
  final String _ipStation = 'http://192.168.4.1/config';
  String _textTittle = 'Configura la cisterna';
  bool _changePage = false;
  bool _checkCisterna = false;
  bool _checkTinaco = false;
  String _ssidSaved = '';
  String _passSaved = '';
  bool _succesConnection = false;
  String _messageConnection = '';

  final String _pruebaDeNavegacion = '';

  final TextEditingController ssidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String get textTittle => _textTittle;
  String get purebaNavegacion => _pruebaDeNavegacion;
  bool get changePage => _changePage;
  bool get checkCisterna => _checkCisterna;
  bool get checkTinaco => _checkTinaco;
  String get ssidSaved => _ssidSaved;
  String get passSaved => _passSaved;
  bool get succesConnection => _succesConnection;
  String get messageConnection => _messageConnection;

  void setSuccesConnection(bool value) {
    _succesConnection = value;
    notifyListeners();
  }

  Future<void> sendRequest(String ssid, String pass) async {
    if (ssid.isEmpty || pass.isEmpty) {
      //print('SSID or password cannot be empty');
      return;
    }

    try {
      final response = await post(
        Uri.parse(_ipStation),
        body: {"SSID": ssid, "PASS": pass},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        _messageConnection = 'Configurado Correctamente';
        _succesConnection = true;
        print(response.body);
      } else if (response.statusCode == 400) {
        _messageConnection = response.body;
        _succesConnection = true;
        print('Error: ${response.statusCode}');
      } else if (response.statusCode == 500) {
        _messageConnection = response.body;
        _succesConnection = true;
      }

      notifyListeners();
    } catch (e) {
      _succesConnection = true;
      _messageConnection = 'Dispositivo No Encontrado';
      print('Request error: $e');
      notifyListeners();
    }
  }

  void changeCisternaCheck(bool value) {
    _checkCisterna = value;
    notifyListeners();
  }

  void changeTinacoCheck(bool value) {
    _checkTinaco = value;
    notifyListeners();
  }

  void handleResponse(String responseBody) {
    if (responseBody == 'Tinaco') {
      changePageHandle(true);
    } else if (responseBody != 'Tinaco') {
      _textTittle = 'Configura el tinaco';
      //savedIp('ip', responseBody);
      _checkCisterna = true;
      print(responseBody);
      notifyListeners();
    }
  }

  void changePageHandle(bool value) {
    _changePage = value;
    notifyListeners();
  }

  void prueba() async {
    _textTittle = 'Configura el tinaco';
    //String? ip = await getIp('ip');
    //String direction = 'ws://${ip}:81';
    //print(direction);
    notifyListeners();
  }

  void updateTextFields() {
    _ssidText = ssidController.text;
    _passText = passwordController.text;
    saveWiFi(ssidController.text, passwordController.text);
    //_passSaved = passwordController.text;
    //_ssidSaved = ssidController.text;
    notifyListeners();
  }

  void removeConfig() {
    removeSavedIp();
    notifyListeners();
  }

  Future<void> saveWiFi(String ssid, String pass) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ssid', ssid);
    await prefs.setString('pass', pass);
    print('SSID:$ssid');
    print('Pass: $pass');
    _passSaved = ssid;
    _ssidSaved = pass;
    notifyListeners();
  }

  Future<Map<String, String?>> getSavedWiFi() async {
    final prefs = await SharedPreferences.getInstance();

    String? ssid = prefs.getString('ssid');
    String? pass = prefs.getString('pass');
    notifyListeners();
    return {'ssid': ssid, 'pass': pass};
  }

  Future<void> saveMac(String mac) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mac', mac);
    notifyListeners();
  }

  Future<String?> getSavedMac() async {
    final prefs = await SharedPreferences.getInstance();

    String? mac = prefs.getString('mac');
    notifyListeners();
    return mac;
  }

  Future<void> loadWiFi() async {
    Map<String, String?> credentials = await getSavedWiFi();
    _ssidSaved = credentials['ssid'] != null ? credentials['ssid']! : '';
    _passSaved = credentials['pass'] != null ? credentials['pass']! : '';
    notifyListeners();
    //print('ssid Recuperado: $_ssidSaved');
    //print('Pass recuperado: $_passSaved');
  }

  ConfigProvider() {
    loadWiFi();
  }

  @override
  void dispose() {
    ssidController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
