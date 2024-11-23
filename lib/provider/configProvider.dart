import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:water_level_controller/shared/sharedPreferences.dart';

class ConfigProvider extends ChangeNotifier {
  String _ssidText = '';
  String _passText = '';
  final String _ipStation = 'http://192.168.4.1/config';
  String _textTittle = 'Configura la cisterna';
  bool _changePage = false;

  final String _pruebaDeNavegacion = '';

  final TextEditingController ssidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String get textTittle => _textTittle;
  String get purebaNavegacion => _pruebaDeNavegacion;
  bool get changePage => _changePage;

  Future<void> sendRequest(String url, String ssid, String pass) async {
    if (ssid.isEmpty || pass.isEmpty) {
      //print('SSID or password cannot be empty');
      return;
    }

    try {
      final response = await post(
        Uri.parse(url),
        body: {"SSID": ssid, "PASS": pass},
      );

      if (response.statusCode == 200) {
        handleResponse(response.body);
        print(response.body);
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Request error: $e');
    }
  }

  void handleResponse(String responseBody) {
    if (responseBody == 'Tinaco') {
      changePageHandle(true);
    } else if (responseBody != 'Tinaco') {
      _textTittle = 'Configura el tinaco';
      savedIp('ip', responseBody);
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
    //print('SSID:$_ssidText');
    //print('PASS:$_passText');
    sendRequest(_ipStation, _ssidText, _passText);
    notifyListeners();
  }

  void removeConfig() {
    removeSavedIp();
    notifyListeners();
  }

  @override
  void dispose() {
    ssidController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
