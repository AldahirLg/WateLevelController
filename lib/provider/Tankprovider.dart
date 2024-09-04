import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:water_level_controller/shared/sharedPreferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class TankProvider extends ChangeNotifier {
  bool _isSwitchOn = false;
  bool _stateWs = true;
  double _alturaCisterna = 0.0;
  double _alturaTinaco = 0.0;
  double _porcentajeCis = 0.0;
  double _porcentajeTin = 0.0;
  double _limMinCis = 0.0;
  double _limMinTin = 0.0;
  double _rele = 0.0;
  double _iniciar = 0.0;
  double _espTinaco = 0.0;
  int _alert = 0;
  int _index = 0;
  late WebSocketChannel? _channel;
  bool _inactve = false;
  Timer? _inactiveTimer;
  bool _alertShow = false;

  double get alturaCisterna => _alturaCisterna;
  bool get isSwitchOn => _isSwitchOn;
  double get alturaTinaco => _alturaTinaco;
  double get porcentajeCis => _porcentajeCis;
  double get porcentajeTin => _porcentajeTin;
  double get limMinCis => _limMinCis;
  double get limMinTin => _limMinTin;
  int get inde => _index;
  bool get stateWs => _stateWs;
  double get rele => _rele;
  double get iniciar => _iniciar;
  double get espTinaco => _espTinaco;
  int get alert => _alert;
  bool get inactive => _inactve;
  bool get alertShow => _alertShow;

  TankProvider() {
    connectToWS();
    starInactive();
  }

  void changeAlertShow(bool value) {
    _alertShow = value;
  }

  void changePage(int value) {
    _index = value;
    notifyListeners();
  }

//metodo para cambiar de vista al salvapantallas
  void starInactive() {
    _inactve = false;
    changePage(0);
    _inactiveTimer?.cancel();
    _inactiveTimer = Timer(const Duration(minutes: 4), () {
      changePage(1);
      _inactve = true;
      notifyListeners(); // Notifica a los listeners cuando el estado cambia
    });
    notifyListeners();
  }

  void active() {
    _inactve = false;
    notifyListeners();
  }

  //meotodo para mostrar alerta de no xonexion con el servidor
  void showDialog() {
    _stateWs = true;
    notifyListeners();
  }

  void hideDialog() {
    _stateWs = false;
    notifyListeners();
  }

  //metodo para activar/desactivar proceso del rele, guardar de fomra persistente el valor
  void setSwitch(bool value) {
    _isSwitchOn = value;
    sendMessage(jsonEncode({'activar': _isSwitchOn}));
    print(value);
    notifyListeners();
  }

  //metodo para conexion al servidor
  void connectToWS() async {
    try {
      hideDialog();
      String? ip = await getIp('ip');
      if (ip == null) {
        print('IP no encontrada');
        return;
      }
      String direction = 'ws://$ip:81';
      _channel = WebSocketChannel.connect(Uri.parse(direction));
      await _channel!.ready;
      _channel!.stream.listen(
        (message) {
          listenToWS(message);
        },
        onDone: () {
          print('closed');
        },
        onError: (error) {
          print('error:$error');
        },
      );
    } catch (e) {
      print('WS NO CONECTADO');
      showDialog();
    }
  }

  //metodo para recibir datos del servidor

  void listenToWS(String message) {
    try {
      var parsedMessage = jsonDecode(message) as Map<String, dynamic>;
      print(message);

      _porcentajeTin = (parsedMessage['Tinaco'] as num?)?.toDouble() ?? 0.0;
      _porcentajeCis = (parsedMessage['Cisterna'] as num?)?.toDouble() ?? 0.0;
      _limMinTin =
          (parsedMessage['PorcentejeConfT'] as num?)?.toDouble() ?? 0.0;
      _limMinCis =
          (parsedMessage['PorcentajeConfC'] as num?)?.toDouble() ?? 0.0;
      _alturaTinaco = (parsedMessage['AlturaConfT'] as num?)?.toDouble() ?? 0.0;
      _alturaCisterna =
          (parsedMessage['AlturaConfC'] as num?)?.toDouble() ?? 0.0;
      _iniciar = (parsedMessage['Iniciar'] as num?)?.toDouble() ?? 0.0;
      _rele = (parsedMessage['Rele'] as num?)?.toDouble() ?? 0.0;
      _espTinaco = (parsedMessage['esp32Tinaco'] as num?)?.toDouble() ?? 0.0;
      _alert = (parsedMessage['Advertencia'] as int?) ?? 0;
      if (_iniciar == 0) {
        _isSwitchOn = false;
      } else if (_iniciar == 1) {
        _isSwitchOn = true;
      }
    } catch (e) {
      print('error:$e');
    }
    notifyListeners();
  }

  void heightCis(double value) {
    _alturaCisterna = value;
    sendMessage(jsonEncode({'TankCisterna': _alturaCisterna}));
    print('altura cisterna:$alturaCisterna');
    notifyListeners();
  }

  void heightTin(double value) {
    _alturaTinaco = value;
    sendMessage(jsonEncode({'TankTinaco': _alturaTinaco}));
    print('altura tinaco:$alturaTinaco');
    notifyListeners();
  }

  void levelOnCis(double value) {
    _limMinCis = value;
    sendMessage(jsonEncode({'Cistern_Level_On': _limMinCis}));
    print('levelOn Cis:$limMinCis');
    notifyListeners();
  }

  void levelOnTin(double value) {
    _limMinTin = value;
    sendMessage(jsonEncode({'Tinaco_Level_On': _limMinTin}));
    print('levelOn Tin:$limMinTin');
    notifyListeners();
  }

  void sendMessage(String message) {
    _channel?.sink.add(message);
  }

  void removeConfig() {
    removeSavedIp();
    notifyListeners();
  }

  void alertState(int value) {
    print(value);
    sendMessage(jsonEncode({'Advertencia': value}));
    notifyListeners();
  }

  Future<void> closeWSChannel() async {
    _channel?.sink.close();
    print('WEBSOCKET Closed');
  }

  void timerIn() {
    _inactiveTimer?.cancel();
  }

  @override
  void dispose() {
    _inactiveTimer?.cancel();
    closeWSChannel();
    super.dispose();
  }
}
