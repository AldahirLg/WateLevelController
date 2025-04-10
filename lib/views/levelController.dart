import 'dart:async';
import 'dart:convert';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:network_tools_flutter/network_tools_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:water_level_controller/provider/Tankprovider.dart';
import 'package:water_level_controller/shared/sharedPreferences.dart';
import 'package:water_level_controller/views/savedScreen.dart';
import 'package:water_level_controller/views/setting_%20view.dart';
import 'package:water_level_controller/widgets/buildButons.dart';
import 'package:water_level_controller/widgets/buildTank.dart';

class WaterLevelController extends StatefulWidget {
  const WaterLevelController({super.key});

  @override
  State<WaterLevelController> createState() => _WaterLevelControllerState();
}

class _WaterLevelControllerState extends State<WaterLevelController> {
  Color azulClaro = const Color(0xFF30A4BA);
  Color azulObscuro = const Color(0xFF134874);
  Color azulMasClaro = const Color.fromARGB(255, 190, 247, 255);

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  String? ipGet;
  int currentPage = 0;
  Timer? _timer;

  voidGetIpMethod() async {
    //ipGet = await getIp('ip');
  }

  Future<void> _handleRefresh(TankProvider provider) async {
    _refreshIndicatorKey.currentState?.show();

    bool conectado = false;

    if (provider.isSocketConnected()) {
      print('Conexión WebSocket abierta - Enviando estado');
      try {
        // Verificar nuevamente si la conexión está abierta antes de enviar
        if (provider.isSocketConnected()) {
          updateState(provider);
          conectado = true;
        } else {
          print('Conexión cerrada antes de enviar el mensaje');
        }
      } catch (e) {
        print('Error al enviar mensaje: $e');
      }
    } else {
      print('Intentando conectar...');
      conectado = await provider.connectClientDNS();

      // Si la conexión se estableció correctamente, enviar el estado
      if (conectado) {
        try {
          updateState(provider);
        } catch (e) {
          print('Error al enviar mensaje después de conectar: $e');
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(conectado
            ? 'Conexión exitosa al dispositivo'
            : 'No se pudo conectar'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void updateState(TankProvider provider) {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      provider.sendMessage(jsonEncode({'state': true}));
    });
  }

  @override
  void initState() {
    super.initState();
    // Opcional: cargar datos iniciales
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState?.show();
    });*/
  }

  @override
  void dispose() {
    _timer!.cancel();
    Provider.of<TankProvider>(context, listen: false).closeConnectionToServer();
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tankProvider = context.watch<TankProvider>();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    if (tankProvider.stateWs) {
      //Future.microtask(() => _showConnectionErrorDialog(context, tankProvider));
    }

    if (tankProvider.alert == 1 && !tankProvider.alertShow) {
      //Future.microtask(() => alertShow(context, tankProvider));
      tankProvider.changeAlertShow(true);
    } else if (tankProvider.alert != 1) {
      //tankProvider.changeAlertShow(false);
    }

    if (!tankProvider.stateWs) {}

    return GestureDetector(
      onTap: () {
        tankProvider.starInactive();
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: /* tankProvider.inactive
              ? null
              : */
              PreferredSize(
            preferredSize: Size.fromHeight(
              MediaQuery.of(context).orientation == Orientation.portrait
                  ? MediaQuery.of(context).size.height *
                      0.05 // 7% de altura en vertical
                  : MediaQuery.of(context).size.height *
                      0.08, // 12% en horizontal
            ),
            child: AppBar(
              elevation: 10,
              iconTheme: IconThemeData(
                  color: azulObscuro,
                  size:
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? MediaQuery.of(context).size.width * 0.07
                          : MediaQuery.of(context).size.width * 0.025),
              shadowColor: azulClaro,
              centerTitle: true,
              backgroundColor: azulClaro,
              title: Text(
                'Water Level Controller',
                style: TextStyle(
                  fontSize:
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? MediaQuery.of(context).size.width *
                              0.045 // Tamaño para vertical
                          : MediaQuery.of(context).size.width *
                              0.025, // Tamaño para horizontal
                  color: azulObscuro,
                ),
              ),
            ),
          ),
          bottomNavigationBar: PreferredSize(
            preferredSize: Size.fromHeight(
              MediaQuery.of(context).orientation == Orientation.portrait
                  ? MediaQuery.of(context).size.height * 0.07
                  : MediaQuery.of(context).size.height * 0.10,
            ),
            child: NavigationBar(
              shadowColor: azulObscuro,
              selectedIndex: currentPage,
              height: MediaQuery.of(context).orientation == Orientation.portrait
                  ? MediaQuery.of(context).size.height * 0.07
                  : MediaQuery.of(context).size.height * 0.10,
              backgroundColor: azulClaro,
              elevation: 10,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              indicatorColor: Colors.transparent,
              destinations: <Widget>[
                NavigationDestination(
                  icon: Icon(
                    color: azulObscuro,
                    Icons.home,
                    size: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? MediaQuery.of(context).size.height * 0.03
                        : MediaQuery.of(context).size.height * 0.05,
                  ),
                  selectedIcon: Icon(
                    Icons.home_filled,
                    size: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? MediaQuery.of(context).size.height * 0.03
                        : MediaQuery.of(context).size.height * 0.05,
                    color: azulMasClaro,
                  ),
                  label: 'Inicio',
                ),
                NavigationDestination(
                  icon: Icon(
                    color: azulObscuro,
                    Icons.settings,
                    size: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? MediaQuery.of(context).size.height * 0.03
                        : MediaQuery.of(context).size.height * 0.05,
                  ),
                  selectedIcon: Icon(
                    Icons.settings,
                    size: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? MediaQuery.of(context).size.height * 0.03
                        : MediaQuery.of(context).size.height * 0.05,
                    color: azulMasClaro,
                  ),
                  label: 'Ajustes',
                ),
              ],
              onDestinationSelected: (int index) {
                setState(() {
                  currentPage = index;
                });
              },
            ),
          ),
          drawer: Drawer(
            backgroundColor: azulMasClaro,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final screenHeight = constraints.maxHeight;
                final isPortrait = screenHeight > screenWidth;

                return SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: screenHeight * 0.03),

                        // Botón WiFi
                        _buildResponsiveButton(
                          context,
                          icon: Icons.wifi,
                          label: 'WiFi',
                          onPressed: () =>
                              Navigator.pushNamed(context, '/config'),
                          screenSize: Size(screenWidth, screenHeight),
                        ),

                        SizedBox(height: screenHeight * 0.02),

                        // Botón Conectar
                        /*_buildResponsiveButton(
                          context,
                          icon: Icons.cast_connected,
                          label: 'Conectar',
                          onPressed: () {
                            _timer?.cancel();
                            //tankProvider.setStateWS(false);
                            //tankProvider.discoverESP32();
                          },
                          screenSize: Size(screenWidth, screenHeight),
                        ),*/
                        /*_buildResponsiveButton(
                          context,
                          icon: Icons.cast_connected,
                          label: 'Cerrar',
                          onPressed: () {
                            //tankProvider.setStateWS(true);
                            tankProvider.closeConnectionToServer();
                          },
                          screenSize: Size(screenWidth, screenHeight),
                        ),

                        SizedBox(height: screenHeight * 0.02),

                        // Botón Configuración
                        _buildResponsiveButton(
                          context,
                          icon: Icons.settings,
                          label: 'Configuración',
                          onPressed: () =>
                              Navigator.pushNamed(context, '/setting'),
                          screenSize: Size(screenWidth, screenHeight),
                        ),*/

                        SizedBox(height: screenHeight * 0.02),

                        // Botón Restaurar
                        _buildResponsiveButton(
                          context,
                          icon: Icons.restore,
                          label: 'Restaurar',
                          onPressed: () => confirmRemove(context, tankProvider),
                          screenSize: Size(screenWidth, screenHeight),
                        ),

                        //SizedBox(height: screenHeight * 0.04),

                        // Indicador de conexión
                        /*tankProvider.stateWs
                            ? Container(
                                width: screenWidth * 0.7,
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.05),
                                child: Text(
                                  tankProvider.indicator,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    color: azulObscuro,
                                  ),
                                ),
                              )
                            : CircularProgressIndicator(color: azulClaro),*/
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          backgroundColor: azulMasClaro,
          body: <Widget>[
            SizedBox.expand(
              child: RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: () => _handleRefresh(tankProvider),
                color: azulClaro,
                backgroundColor: azulMasClaro,
                strokeWidth: 3.0,
                displacement: 40.0,
                edgeOffset: 20.0,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        children: [_containerCentral(tankProvider)],
                      )

                      /*IndexedStack(
                  index: tankProvider.inde,
                  children: [
                    Column(children: [_containerCentral(tankProvider)]),
                    Container(
                      color: azulClaro,
                      child: RandomImages(),
                    )
                  ],
                ),*/
                      ),
                ),
              ),
            ),
            SizedBox.expand(child: confValueSistem(tankProvider))
          ][currentPage]),
    );
  }

  Expanded _containerCentral(TankProvider tankProvider) {
    final orientation = MediaQuery.of(context).orientation;

    return Expanded(
      flex: 9,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: azulClaro,
            borderRadius: BorderRadius.circular(15),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (orientation == Orientation.portrait) {
                return Column(
                  children: [
                    spaceTinaco(tankProvider),
                    spaceCisterna(tankProvider),
                  ],
                );
              } else {
                return Row(
                  children: [
                    spaceTinaco(tankProvider),
                    spaceCisterna(tankProvider),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget spaceTinaco(TankProvider tankProvider) {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: azulMasClaro, borderRadius: BorderRadius.circular(15)),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          double containerWidth = constraints.maxWidth;
          double containerHeight = constraints.maxHeight;
          return Row(
            children: [
              BuildTank(
                containerHeight: containerHeight,
                containerWidth: containerWidth,
                porcentaje: tankProvider.porcentajeTin < 100
                    ? tankProvider.porcentajeTin / 100
                    : 0.0,
                onChanged: (double value) {
                  tankProvider.levelOnTin(value);
                },
                valuePercent: tankProvider.limMinTin,
                valueMax: 100.0,
                onChangedOff: (double value) {
                  tankProvider.levelOffTin(value);
                },
                tinacoOrCist: true,
                valueMin: tankProvider.alturaCisterna,
                valuePercentMax: tankProvider.limMinCis,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(0.8),
                  child: BuildButtons(
                    stateRele: tankProvider.rele,
                    tank: 'Tinaco',
                    containerHeigth: containerHeight,
                    onChanged: (double value) {
                      tankProvider.heightTin(value);
                    },
                    valuePercent: tankProvider.alturaTinaco,
                    valuemax: 400.0,
                    porcentaje: tankProvider.porcentajeTin < 100
                        ? tankProvider.porcentajeTin / 100
                        : 0.0,
                  ),
                ),
              )
            ],
          );
        }),
      ),
    ));
  }

  Widget confValueSistem(TankProvider tankProvider) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Título Tinaco
              Text(
                'Tinaco',
                style: TextStyle(
                  color: azulObscuro,
                  fontWeight: FontWeight.w500,
                  fontSize: screenWidth * 0.03,
                ),
              ),
              const SizedBox(height: 10),
              SpinBoxBuild(
                name: 'Altura del Tinaco (cm)',
                screenWidth: screenWidth,
                azulObscuro: azulObscuro,
                value: tankProvider.alturaTinaco,
                onChanged: (value) {
                  //if (!tankProvider.channel) {
                  tankProvider.heightTin(value);
                  //} else {
                  print('Canal Cerrado');
                  // }
                },
              ),

              const SizedBox(height: 20),
              SpinBoxBuild(
                  name: 'Iniciar en %',
                  screenWidth: screenWidth,
                  azulObscuro: azulObscuro,
                  value: tankProvider.limMinTin,
                  onChanged: (value) {
                    tankProvider.levelOnTin(value);
                  }),

              const SizedBox(height: 20),
              SpinBoxBuild(
                  name: 'Detener en %',
                  screenWidth: screenWidth,
                  azulObscuro: azulObscuro,
                  value: tankProvider.limMinCis,
                  onChanged: (value) {
                    tankProvider.levelOffTin(value);
                  }),
              // Detener en %
              const SizedBox(height: 20),

              // Título Cisterna
              Text(
                'Cisterna',
                style: TextStyle(
                  color: azulObscuro,
                  fontWeight: FontWeight.w500,
                  fontSize: screenWidth * 0.03,
                ),
              ),
              const SizedBox(height: 10),
              SpinBoxBuild(
                  name: 'Altura de la Cisterna (cm)',
                  screenWidth: screenWidth,
                  azulObscuro: azulObscuro,
                  value: tankProvider.alturaCisterna,
                  onChanged: (value) {
                    tankProvider.heightCis(value);
                  }),
              // Altura de la Cisterna

              const SizedBox(height: 20),
              SpinBoxBuild(
                  name: 'Iniciar en %',
                  screenWidth: screenWidth,
                  azulObscuro: azulObscuro,
                  value: tankProvider.limMinCisterna,
                  onChanged: (value) {
                    tankProvider.limMinC(value);
                  }),
              // Iniciar en % (Cisterna)

              const SizedBox(height: 20),

              // Título Iniciar Proceso

              SizedBox(
                height:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? screenWidth * 0.06
                        : screenWidth * 0.10,
                width:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? screenWidth * 0.2
                        : screenWidth * 0.40,
                child: ElevatedButton.icon(
                  onLongPress: () {
                    tankProvider.iniciar
                        ? tankProvider.startApp(false)
                        : tankProvider.startApp(true);
                  },
                  style: ElevatedButton.styleFrom(
                      foregroundColor: azulObscuro,
                      backgroundColor: azulClaro,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: azulObscuro),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(12),
                          ))),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(tankProvider.iniciar ? 'Detener' : 'Iniciar'),
                  onPressed: () {},
                ),
              ),

              // Aquí puedes agregar el AnimatedToggleSwitch si lo necesitas*/
            ],
          )),
    );
  }

  Widget spaceCisterna(TankProvider tankProvider) {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: azulMasClaro, borderRadius: BorderRadius.circular(15)),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          double containerWidth = constraints.maxWidth;
          double containerHeight = constraints.maxHeight;
          return Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(0.8),
                  child: BuildButtons(
                    stateRele: tankProvider.rele,
                    tank: 'Cisterna',
                    containerHeigth: containerHeight,
                    onChanged: (double value) {
                      tankProvider.heightCis(value);
                    },
                    valuePercent: tankProvider.alturaCisterna,
                    valuemax: 400.0,
                    porcentaje: tankProvider.porcentajeCis < 100
                        ? tankProvider.porcentajeCis / 100
                        : 0.0,
                  ),
                ),
              ),
              BuildTank(
                containerHeight: containerHeight,
                containerWidth: containerWidth,
                porcentaje: tankProvider.porcentajeCis < 100
                    ? tankProvider.porcentajeCis / 100
                    : 0.0,
                onChanged: (double value) {
                  tankProvider.limMinC(value);
                },
                valuePercent: tankProvider.limMinCisterna,
                valueMax: 100.0,
                onChangedOff: (double value) {},
                tinacoOrCist: false,
                valueMin: tankProvider.limMinCisterna,
                valuePercentMax: 100,
              )
            ],
          );
        }),
      ),
    ));
  }

  void _showConnectionErrorDialog(BuildContext context, TankProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: azulMasClaro,
          title: Text(
            'Connection Error',
            style: TextStyle(color: azulObscuro),
          ),
          content: Text(
            'Press "Connect" to connect or Press "Cancel" to close',
            style: TextStyle(color: azulObscuro),
          ),
          actions: [
            TextButton(
              child: Text('Connect', style: TextStyle(color: azulObscuro)),
              onPressed: () {
                Navigator.of(context).pop();
                provider.discoverESP32();
              },
            ),
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: azulObscuro),
              ),
              onPressed: () {
                provider.hideDialog();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void confirmRemove(BuildContext context, TankProvider provider) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: azulMasClaro,
            content: Text(
              'Confirma si quieres eliminar esta infromacion',
              style: TextStyle(color: azulObscuro),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: azulObscuro),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    provider.resetWiFi(true);
                  },
                  child: Text(
                    'Confirmar',
                    style: TextStyle(color: azulObscuro),
                  ))
            ],
          );
        });
  }

  void alertShow(BuildContext context, TankProvider provider) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Advertencia!'),
            backgroundColor: azulMasClaro,
            content: Text(
              'Advertencia! No esta aumentanto el nivel de agua, revisa tu cisterna y vuelve a activar la bomba',
              style: TextStyle(color: azulObscuro),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    provider.alertState(0);
                  },
                  child: Text(
                    'Desactivar',
                    style: TextStyle(color: azulObscuro),
                  ))
            ],
          );
        });
  }

  Widget _buildResponsiveButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Size screenSize,
  }) {
    final buttonWidth = screenSize.width * 0.65; // 65% del ancho disponible
    final buttonHeight = screenSize.height * 0.07; // 7% de la altura

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight.clamp(40, 70), // Límites mínimos/máximos
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: azulClaro,
          foregroundColor: azulMasClaro,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(screenSize.width * 0.03),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: screenSize.width * 0.06),
        label: Text(
          label,
          style: TextStyle(
            fontSize: screenSize.width * 0.04,
          ),
        ),
      ),
    );
  }
}
