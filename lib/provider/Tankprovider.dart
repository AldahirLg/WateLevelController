import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:network_tools_flutter/network_tools_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:water_level_controller/shared/sharedPreferences.dart';
import 'package:web_socket_client/web_socket_client.dart';

class TankProvider extends ChangeNotifier {
  bool _isSwitchOn = false;
  bool _stateWs = true;
  double _limMinCisterna = 0.0;
  double _alturaCisterna = 0.0;
  double _alturaTinaco = 0.0;
  double _porcentajeCis = 0.0;
  double _porcentajeTin = 0.0;
  double _limMinCis = 0.0;
  double _limMinTin = 0.0;
  bool _rele = false;
  bool _iniciar = false;
  bool _espTinaco = false;
  bool _alert = false;
  int _index = 0;
  //late WebSocketChannel? _channel;
  static const backoff = ConstantBackoff(Duration(seconds: 1));
  WebSocket? _socket;
  bool _inactve = false;
  Timer? _inactiveTimer;
  bool _alertShow = false;
  String _indicator = 'Desconectado';

  //bool get channel => _channel?.sink != null;

  double get alturaCisterna => _alturaCisterna;
  bool get isSwitchOn => _isSwitchOn;
  double get alturaTinaco => _alturaTinaco;
  double get porcentajeCis => _porcentajeCis;
  double get porcentajeTin => _porcentajeTin;
  double get limMinCis => _limMinCis;
  double get limMinTin => _limMinTin;
  int get inde => _index;
  bool get stateWs => _stateWs;
  bool get rele => _rele;
  bool get iniciar => _iniciar;
  bool get espTinaco => _espTinaco;
  bool get alert => _alert;
  bool get inactive => _inactve;
  bool get alertShow => _alertShow;
  double get limMinCisterna => _limMinCisterna;
  String get indicator => _indicator;
  TankProvider() {
    //connectToWS();
    //starInactive();
    //discoverESP32();
  }

  void changeAlertShow(bool value) {
    _alertShow = value;
  }

  void changePage(int value) {
    _index = value;
    notifyListeners();
  }

  Future<bool> connectClientDNS() async {
    final completer = Completer<bool>();

    try {
      String? getIpSaved = await getIp('ip');
      final uri = Uri.parse('ws://$getIpSaved:81');
      _socket = WebSocket(uri, backoff: backoff);

      bool connected = false;

      // Timeout de conexión
      Future.delayed(const Duration(seconds: 5), () async {
        if (!connected && !completer.isCompleted) {
          print('Tiempo agotado, ejecutando discoverESP32...');
          await discoverESP32(); // Espera a que termine
          completer.complete(false);
        }
      });

      _socket?.connection.listen((state) async {
        if (state is Connected || state is Reconnected) {
          print('Conectado exitosamente');
          connected = true;
          if (!completer.isCompleted) completer.complete(true);
        }
      }, onError: (error) async {
        print('Error de conexión: $error');
        if (!completer.isCompleted) {
          await discoverESP32();
          completer.complete(false);
        }
      });

      _socket?.messages.listen((message) {
        listenToWS(message);
      });

      return completer.future;
    } catch (e) {
      print('Excepción durante conexión: $e');
      await discoverESP32();
      return false;
    }
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
    sendMessage(jsonEncode({'activar': _isSwitchOn}));
    print(value);
    notifyListeners();
  }

  void setStateWS(bool value) {
    _stateWs = value;
    notifyListeners();
  }

  Future<void> discoverESP32() async {
    setStateWS(false);

    try {
      print('Iniciando configuración de network_tools_flutter...');
      await configureNetworkToolsFlutter(
          (await getApplicationDocumentsDirectory()).path);
      print('Configuración de network_tools_flutter completada.');

      print('Iniciando búsqueda de dispositivos mDNS...');
      final devices = await MdnsScannerService.instance.searchMdnsDevices();
      print('Dispositivos encontrados: ${devices.length}');

      for (final ActiveHost activeHost in devices) {
        //print('Analizando dispositivo: ${activeHost.address}');
        final MdnsInfo? mdnsInfo = await activeHost.mdnsInfo;

        if (mdnsInfo != null) {
          /*print('Información mDNS del dispositivo:');
          print('  - Nombre: ${mdnsInfo.getOnlyTheStartOfMdnsName()}');
          print('  - Puerto: ${mdnsInfo.mdnsPort}');
          print('  - Tipo de servicio: ${mdnsInfo.mdnsServiceType}');*/

          // Verificar si el dispositivo es el ESP32
          if (mdnsInfo.getOnlyTheStartOfMdnsName() == 'cisterna') {
            print('''
          Dispositivo ESP32 encontrado:
          Address: ${activeHost.address}
          Port: ${mdnsInfo.mdnsPort}
          ServiceType: ${mdnsInfo.mdnsServiceType}
          MdnsName: ${mdnsInfo.getOnlyTheStartOfMdnsName()}
          ''');

            // Guardar la dirección IP del ESP32

            // Conectar al WebSocket del ESP32
            //connectToWS(activeHost.address);
            savedIp('ip', activeHost.address);
            connectClientDNS();
            setStateWS(true);
            _indicator = 'Conectado';

            return; // Salir del bucle una vez encontrado el ESP32
          } else {
            print('No se encontro Cisterna');
            setStateWS(true);
            _indicator = 'No se encontro';
          }
        } else {
          print('No se pudo obtener la información mDNS del dispositivo.');
          setStateWS(true);
          _indicator = 'Fallor la busqueda';
        }
      }

      /*if (_esp32Address == null) {
      print('No se encontró ningún dispositivo ESP32 en la red.');
    }*/
    } catch (e) {
      print('Error durante el descubrimiento mDNS: $e');
      setStateWS(true);
    }
    //notifyListeners();
  }

  //metodo para conexion al servidor
  /*void connectToWS(String ip) async {
    try {
      String direction = 'ws://$ip:81';
      _channel = WebSocketChannel.connect(Uri.parse(direction));
      await _channel!.ready;
      _channel!.stream.listen(
        (message) {
          listenToWS(message);
          _indicator = 'Conectado!!';
          _stateWs = true;
        },
        onDone: () {
          print('closed');
          _indicator = 'Desconectado!!';
          _stateWs = true;
        },
        onError: (error) {
          _stateWs = true;
          print('error:$error');
        },
      );
    } catch (e) {
      print('WS NO CONECTADO');
      _indicator = 'Desconectado';
      showDialog();
      _stateWs = true;
    }
    notifyListeners();
  }*/

  //metodo para recibir datos del servidor

  void listenToWS(String message) {
    try {
      // Decodificar el mensaje JSON
      final parsedMessage = jsonDecode(message) as Map<String, dynamic>;
      print('Mensaje recibido: $parsedMessage');

      // Asignar valores a las variables
      _limMinCisterna =
          (parsedMessage['minCisterna'] as num?)?.toDouble() ?? 0.0;
      _porcentajeTin = (parsedMessage['Tinaco'] as num?)?.toDouble() ?? 0.0;
      _porcentajeCis = (parsedMessage['Cisterna'] as num?)?.toDouble() ?? 0.0;
      _limMinTin = (parsedMessage['start_bomba'] as num?)?.toDouble() ?? 0.0;
      _limMinCis = (parsedMessage['stop_bomba'] as num?)?.toDouble() ?? 0.0;
      _alturaTinaco = (parsedMessage['heigh_tin'] as num?)?.toDouble() ?? 0.0;
      _alturaCisterna = (parsedMessage['heigh_cis'] as num?)?.toDouble() ?? 0.0;

      // Asignar valores booleanos
      _iniciar = parsedMessage['start'] as bool? ?? false;
      _rele = parsedMessage['bomba'] as bool? ?? false;
      _espTinaco = parsedMessage['esp32Tinaco'] as bool? ?? false;
      _alert = parsedMessage['alert'] as bool? ?? false;

      // Actualizar el estado del switch
      _isSwitchOn = !_iniciar;

      // Notificar a los listeners
      notifyListeners();
    } catch (e) {
      print('Error al procesar el mensaje: $e');
    }
  }

  void limMinC(double value) {
    _limMinCisterna = value;
    sendMessage(jsonEncode({'levelOnCisterna': _limMinCisterna}));
    print('Limite minimo cisterna:$limMinCisterna');
    notifyListeners();
  }

  void heightCis(double value) {
    _alturaCisterna = value;
    sendMessage(jsonEncode({'heighCisterna': _alturaCisterna}));
    print('altura cisterna:$alturaCisterna');
    notifyListeners();
  }

  void heightTin(double value) {
    _alturaTinaco = value;
    sendMessage(jsonEncode({'heighTinaco': _alturaTinaco}));
    print('altura tinaco:$alturaTinaco');
    notifyListeners();
  }

  void levelOffTin(double value) {
    _limMinCis = value;
    sendMessage(jsonEncode({'TinacoLevelOff': _limMinCis}));
    print('levelOff Tin:$limMinCis');
    notifyListeners();
  }

  void levelOnTin(double value) {
    _limMinTin = value;
    sendMessage(jsonEncode({'TinacoLevelOn': _limMinTin}));
    print('levelOn Tin:$limMinTin');
    notifyListeners();
  }

  void startApp(bool value) {
    _iniciar = value;
    sendMessage(jsonEncode({'start': _iniciar}));
    print('Iniciar:$_iniciar');
    notifyListeners();
  }

  void sendMessage(String message) {
    if (!isSocketConnected()) {
      print('No se puede enviar el mensaje, WebSocket no está conectado.');
      return;
    }
    try {
      _socket?.send(message);
      print('Mensaje enviado: $message');
    } catch (e) {
      print('Error al enviar mensaje: $e');
    }
  }

  bool isSocketConnected() {
    if (_socket?.connection.state is Connected ||
        _socket?.connection.state is Reconnected) {
      return true;
    }
    return false;
  }

  void closeConnectionToServer() {
    //(isSocketConnected()) {
    _socket?.close();
    print('Conexión cerrada correctamente.');
    _indicator = 'Desconectado';
    //}; //else {
    //print('No hay conexión activa para cerrar.');
    //}
    notifyListeners();
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

  void resetWiFi(bool value) {
    sendMessage(jsonEncode({'reset': value}));
    //print('altura cisterna:$alturaCisterna');
    notifyListeners();
  }

  void timerIn() {
    _inactiveTimer?.cancel();
  }

  @override
  void dispose() {
    _inactiveTimer?.cancel();
    closeConnectionToServer();
    super.dispose();
  }
}
