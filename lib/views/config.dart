import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:water_level_controller/provider/Tankprovider.dart'; // Asegúrate de que esta sea la ruta correcta
import 'package:water_level_controller/provider/configProvider.dart';
import 'package:water_level_controller/views/levelController.dart';
import 'package:water_level_controller/widgets/loding_dialog.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class ConfigView extends StatefulWidget {
  const ConfigView({super.key});

  @override
  State<ConfigView> createState() => _ConfigViewState();
}

class _ConfigViewState extends State<ConfigView> {
  final _formKey = GlobalKey<FormState>();
  Color azulClaro = const Color(0xFF30A4BA);
  Color azulObscuro = const Color(0xFF134874);
  Color azulMasClaro = const Color.fromARGB(255, 190, 247, 255);
  List<WifiNetwork> accesPoint = [];
  StreamSubscription<List<WiFiAccessPoint>>? subscription;
  bool shouldCheckCan = true;
  bool selecetedWifi = false;
  int currentPage = 0;
  bool isScanning = false;

  bool checkCirterna = false;
  bool checkTinaco = false;

  String ssidSaved = '';
  String passSaved = '';

  String? wifiScanResult;

  Future<bool> _canGetScannedResults(BuildContext context) async {
    if (shouldCheckCan) {
      final can = await WiFiScan.instance.canGetScannedResults();

      if (can != CanGetScannedResults.yes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text('No se puede obtner los resultados escaneados: $can')));
        }
        //accesPoint = <WiFiAccessPoint>[];
        return false;
      }
    }
    return true;
  }

  Future<void> _getScannedResult(BuildContext context) async {
    if (!await _canGetScannedResults(context)) return;

    try {
      final results = await WiFiForIoTPlugin.loadWifiList();
      if (results != null && mounted) {
        setState(() {
          accesPoint = results;
          print('Escaneo completado. Redes encontradas: ${accesPoint.length}');
        });
      }
    } catch (e) {
      print('Error al escanear WiFi: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al escanear: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _connectToWiFi(String ssid, ConfigProvider provider) async {
    bool isConnected =
        await WiFiForIoTPlugin.connect(ssid, security: NetworkSecurity.NONE);

    if (isConnected) {
      debugPrint('Conectando a: $ssid...');
      provider.setSuccesConnection(false);
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => const LoadingDialogWidget());

      int attemps = 0;

      while (attemps < 10) {
        bool stillConnected = await WiFiForIoTPlugin.isConnected();
        if (stillConnected) {
          debugPrint('Conexion Establecida a $ssid');
          break;
        }
        await Future.delayed(const Duration(seconds: 1));
        debugPrint('Inetentando Conectar...');
        attemps++;
      }

      if (attemps == 10) {
        debugPrint('No se pudo conectar completamente a $ssid');
        return;
      }

      WiFiForIoTPlugin.forceWifiUsage(true);

      await Future.delayed(const Duration(seconds: 5));

      try {
        Map<String, String?> credentials = await provider.getSavedWiFi();
        print(credentials['ssid']);
        print(credentials['pass']);
        await provider
            .sendRequest(
                credentials['ssid'].toString(), credentials['pass'].toString())
            .timeout(Duration(seconds: 15));

        debugPrint('Crdenciales enviadas Correctamente');

        await Future.delayed(const Duration(seconds: 5));

        await WiFiForIoTPlugin.disconnect();
        debugPrint('Conexion Wifi Cerrada');
      } catch (e) {
        await WiFiForIoTPlugin.disconnect();
        debugPrint('Error al enviar credenciales: ${e.toString()}');
      } finally {
        WiFiForIoTPlugin.forceWifiUsage(false);
      }
    } else {
      debugPrint('Falló la conexión a $ssid');
    }
  }

  Future<void> scanQr(ConfigProvider provider) async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      return;
    }

    try {
      String? cameraScanResult = await scanner.scan();
      if (cameraScanResult != null) {
        print('Resultado Escaneado : $cameraScanResult');

        setState(() {
          wifiScanResult = cameraScanResult;
          Map<String, String> wifiInfo = extraerDatosWifi(cameraScanResult);
          provider.saveWiFi(wifiInfo['ssid']!, wifiInfo['password']!);
        });
      }
    } on PlatformException catch (e) {
      print('Error de plataforma: ${e.message}');
    } catch (e) {
      print('Error Inesperado: $e');
    }
  }

  Map<String, String> extraerDatosWifi(String cadenaWifi) {
    final Map<String, String> datos = {};

    try {
      // Elimina espacios y "WIFI:" si está presente al inicio
      cadenaWifi = cadenaWifi.trim().replaceFirst('WIFI:', '');

      // Usa una expresión regular para buscar SSID (S) y contraseña (P)
      final RegExp regex = RegExp(
        r'(?:^|;)(?:S|s):([^;]+).*?(?:T|t):[^;]*.*?(?:P|p):([^;]+)',
        caseSensitive: false,
      );

      final Match? match = regex.firstMatch(cadenaWifi);

      if (match != null) {
        datos['ssid'] = match.group(1) ?? '';
        datos['password'] = match.group(2) ?? '';
      } else {
        // Fallback: Si la regex falla, busca campos manualmente
        final List<String> partes = cadenaWifi.split(';');
        for (String parte in partes) {
          if (parte.startsWith('S:') || parte.startsWith('s:')) {
            datos['ssid'] = parte.substring(2);
          } else if (parte.startsWith('P:') || parte.startsWith('p:')) {
            datos['password'] = parte.substring(2);
          }
        }
      }
    } catch (e) {
      print('Error al analizar datos WiFi: $e');
    }

    return datos;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    //Provider.of<TankProvider>(context, listen: false).closeConnectionToServer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;
    return Consumer<ConfigProvider>(
      builder: (context, configProvider, child) {
        if (configProvider.changePage) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) {
                  return MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(value: configProvider),
                      ChangeNotifierProvider(create: (_) => TankProvider()),
                    ],
                    child: WaterLevelController(),
                  );
                },
              ),
            );
          });
        }
        return Scaffold(
          resizeToAvoidBottomInset:
              false, // Evita que la pantalla se redimensione
          backgroundColor: Colors.white,
          appBar: AppBar(
            iconTheme: IconThemeData(color: azulObscuro),
            scrolledUnderElevation: 0,
            backgroundColor: Colors.white,
            centerTitle: true,
            toolbarHeight: isPortrait
                ? screenSize.height * 0.08
                : screenSize.height * 0.12, // Altura responsiva del AppBar
            title: Text(
              'C O N F I G U R A C I O N',
              style: TextStyle(
                color: azulObscuro,
                fontSize: isPortrait
                    ? screenSize.width * 0.045
                    : screenSize.width * 0.03, // Tamaño responsivo del texto
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          bottomNavigationBar: Container(
            height: isPortrait
                ? screenSize.height * 0.07
                : screenSize.height * 0.12,
            child: NavigationBar(
              height: screenSize.width * 0.06,
              elevation: 0,
              backgroundColor: Colors.white,
              onDestinationSelected: (int index) {
                currentPage = index;
                setState(() {
                  if (currentPage == 1) {
                    _getScannedResult(context);
                  }
                });
              },
              indicatorColor: Colors.transparent,
              selectedIndex: currentPage,
              destinations: <Widget>[
                NavigationDestination(
                    icon: Icon(
                      Icons.home_outlined,
                      color: azulObscuro,
                    ),
                    selectedIcon: Icon(
                      Icons.home,
                      color: azulObscuro,
                    ),
                    label: 'Home'),
                NavigationDestination(
                    icon: Icon(
                      Icons.perm_scan_wifi_outlined,
                      color: azulObscuro,
                    ),
                    selectedIcon: Icon(
                      Icons.perm_scan_wifi,
                      color: azulObscuro,
                    ),
                    label: 'WiFi')
              ],
            ),
          ),
          body: <Widget>[
            // Página 1: Configuración de red
            SizedBox.expand(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    // Permite el desplazamiento vertical
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: screenSize.height * 0.05),
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Introduce el nombre de tu red';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: azulClaro,
                                          style: BorderStyle.solid)),
                                  errorStyle: TextStyle(color: azulClaro),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: azulClaro,
                                          style: BorderStyle.solid)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: azulObscuro,
                                          style: BorderStyle.solid)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          style: BorderStyle.solid,
                                          color: azulObscuro)),
                                  labelText: 'SSID (Network name)',
                                  labelStyle: TextStyle(color: azulObscuro)),
                              controller: configProvider.ssidController,
                            ),
                            SizedBox(height: screenSize.height * 0.05),
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Introduce la contraseña';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: azulClaro,
                                          style: BorderStyle.solid)),
                                  errorStyle: TextStyle(color: azulClaro),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: azulClaro,
                                          style: BorderStyle.solid)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: azulObscuro,
                                          style: BorderStyle.solid)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          style: BorderStyle.solid,
                                          color: azulObscuro)),
                                  labelText: 'Password',
                                  labelStyle: TextStyle(color: azulObscuro)),
                              obscureText:
                                  false, // Cambia a true para ocultar la contraseña
                              controller: configProvider.passwordController,
                            ),
                            SizedBox(height: screenSize.height * 0.05),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12)),
                                  side: BorderSide(color: azulObscuro),
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  configProvider.updateTextFields();
                                  print(configProvider.ssidController.text);
                                  print(configProvider.passwordController.text);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Credenciales guardadas')),
                                  );
                                  //configProvider.loadWiFi();
                                  FocusScopeNode currentFocus =
                                      FocusScope.of(context);
                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }
                                }
                              },
                              icon: Icon(
                                Icons.save,
                                color: azulObscuro,
                              ),
                              label: Text(
                                'Guardar',
                                style: TextStyle(color: azulObscuro),
                              ),
                            ),
                            SizedBox(height: screenSize.height * 0.02),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: azulObscuro),
                                  borderRadius: BorderRadius.circular(12)),
                              height: screenSize.height * 0.15,
                              width: screenSize.width * 0.7,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'RESUMEN',
                                    style: TextStyle(
                                        color: azulObscuro,
                                        fontSize: screenSize.height * 0.02,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: screenSize.height * 0.01,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'SSID: ',
                                        style: TextStyle(
                                            color: azulObscuro,
                                            fontSize: screenSize.width * 0.03),
                                      ),
                                      Text(configProvider.ssidSaved,
                                          style: TextStyle(
                                              color: azulObscuro,
                                              fontSize:
                                                  screenSize.width * 0.03))
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('PASSWORD:',
                                          style: TextStyle(
                                              color: azulObscuro,
                                              fontSize:
                                                  screenSize.width * 0.03)),
                                      Text(configProvider.passSaved,
                                          style: TextStyle(
                                              color: azulObscuro,
                                              fontSize:
                                                  screenSize.width * 0.03))
                                    ],
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: screenSize.height * 0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 24,
                      right: 24,
                      child: FloatingActionButton(
                          backgroundColor: azulObscuro,
                          onPressed: () {
                            scanQr(configProvider);
                          },
                          child: const Icon(
                            Icons.qr_code,
                            color: Colors.white,
                          )))
                ],
              ),
            ),
            // Página 2: Selección de red WiFi
            SizedBox.expand(
              child: SingleChildScrollView(
                // Permite el desplazamiento vertical
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: screenSize.height * 0.05),
                        const Text('Selecciona Tinaco y Cisterna'),
                        SizedBox(height: screenSize.height * 0.05),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: accesPoint
                              .where((wifi) =>
                                  wifi.ssid == 'WiFi-Tinaco' ||
                                  wifi.ssid == 'WiFi-Cisterna')
                              .length,
                          itemBuilder: (BuildContext context, int index) {
                            final filteredWifis = accesPoint
                                .where((wifi) =>
                                    wifi.ssid == 'WiFi-Tinaco' ||
                                    wifi.ssid == 'WiFi-Cisterna')
                                .toList();
                            final wifi = filteredWifis[index];
                            return ListTile(
                              title: Text(wifi.ssid ?? 'Sin Nombre'),
                              subtitle: Text(wifi.level.toString()),
                              onLongPress: () {
                                _connectToWiFi(
                                    wifi.ssid.toString(), configProvider);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 24,
                      right: 24,
                      child: FloatingActionButton(
                        elevation: 0,
                        backgroundColor: azulObscuro,
                        onPressed: () async {
                          if (isScanning) return;
                          setState(() => isScanning = true);
                          await _getScannedResult(context);
                          setState(() => isScanning = false);
                        },
                        child: isScanning
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Icon(Icons.search, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ][currentPage],
        );
      },
    );
  }
}
