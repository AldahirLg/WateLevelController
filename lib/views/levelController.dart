import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_level_controller/provider/inactiveProvider.dart';
import 'package:water_level_controller/provider/Tankprovider.dart';
import 'package:water_level_controller/shared/sharedPreferences.dart';
import 'package:water_level_controller/views/savedScreen.dart';
import 'package:water_level_controller/widgets/buildButons.dart';
import 'package:water_level_controller/widgets/buildTank.dart';

class WaterLevelController extends StatefulWidget {
  const WaterLevelController({super.key});

  @override
  State<WaterLevelController> createState() => _WaterLevelControllerState();
}

class _WaterLevelControllerState extends State<WaterLevelController> {
  Color azulClaro = const Color(0xFF30A4BA);
  Color azulObscuro = Color(0xFF134874);
  Color azulMasClaro = Color.fromARGB(255, 190, 247, 255);

  String? ipGet;

  voidGetIpMethod() async {
    ipGet = await getIp('ip');
  }

  @override
  void initState() {
    voidGetIpMethod();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tankProvider = context.watch<TankProvider>();

    if (tankProvider.stateWs) {
      Future.microtask(() => _showConnectionErrorDialog(context, tankProvider));
    }

    if (tankProvider.alert == 1 && !tankProvider.alertShow) {
      Future.microtask(() => alertShow(context, tankProvider));
      tankProvider.changeAlertShow(true);
    } else if (tankProvider.alert != 1) {
      tankProvider.changeAlertShow(false);
    }

    return GestureDetector(
      onTap: () {
        tankProvider.starInactive();
      },
      child: Scaffold(
          appBar: tankProvider.inactive
              ? null
              : AppBar(
                  elevation: 10,
                  shadowColor: azulClaro,
                  centerTitle: true,
                  backgroundColor: azulClaro,
                  title: Text(
                    'Water Level Controller',
                    style: TextStyle(fontSize: 25, color: azulObscuro),
                  ),
                ),
          drawer: Drawer(
            backgroundColor: azulMasClaro,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Material(
                    color: azulClaro,
                    child: InkWell(
                      child: Container(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Estado de la bomba',
                    style: TextStyle(
                        color: azulClaro, fontWeight: FontWeight.w500),
                  ),
                  AnimatedToggleSwitch<bool>.size(
                    current: tankProvider.isSwitchOn,
                    values: const [false, true],
                    iconOpacity: 0.2,
                    indicatorSize: const Size.fromWidth(100),
                    customIconBuilder: (context, local, global) => Text(
                      local.value ? 'Activar' : 'Apagar',
                      style: TextStyle(
                          color: Color.lerp(Colors.black, Colors.white,
                              local.animationValue)),
                    ),
                    borderWidth: 5.0,
                    iconAnimationType: AnimationType.onHover,
                    style: ToggleStyle(
                        indicatorColor: azulClaro,
                        borderColor: Colors.transparent),
                    selectedIconScale: 1.0,
                    onChanged: (value) {
                      tankProvider.setSwitch(value);
                    },
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Estado de la Aplicacion',
                    style: TextStyle(
                        color: azulClaro, fontWeight: FontWeight.w500),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                        elevation: MaterialStatePropertyAll(0.0),
                        backgroundColor: MaterialStatePropertyAll(Colors.white),
                        foregroundColor: MaterialStatePropertyAll(azulClaro)),
                    onPressed: () {
                      confirmRemove(context, tankProvider);
                    },
                    child: Text('Restaurar App'),
                  ),
                  Text(
                    'Informacion',
                    style: TextStyle(
                        color: azulClaro, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'ip: $ipGet',
                    style: TextStyle(
                        color: azulClaro, fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
          ),
          backgroundColor: azulMasClaro,
          body: IndexedStack(
            index: tankProvider.inde,
            children: [
              Column(children: [_containerCentral(tankProvider)]),
              Container(
                color: azulClaro,
                child: RandomImages(),
              )
            ],
          )),
    );
  }

  Expanded _containerCentral(TankProvider tankProvider) {
    return Expanded(
        flex: 9,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: azulClaro,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                spaceTinaco(tankProvider),
                spaceCisterna(tankProvider)
              ],
            ),
          ),
        ));
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
                porcentaje: tankProvider.porcentajeTin / 100,
                onChanged: (double value) {
                  tankProvider.levelOnTin(value);
                },
                valuePercent: tankProvider.limMinTin,
                valueMax: 100.0,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(0.8),
                  child: BuildButtons(
                    tank: 'Tinaco',
                    containerHeigth: containerHeight,
                    onChanged: (double value) {
                      tankProvider.heightTin(value);
                    },
                    valuePercent: tankProvider.alturaTinaco,
                    valuemax: 400.0,
                  ),
                ),
              )
            ],
          );
        }),
      ),
    ));
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
                    tank: 'Cisterna',
                    containerHeigth: containerHeight,
                    onChanged: (double value) {
                      tankProvider.heightCis(value);
                    },
                    valuePercent: tankProvider.alturaCisterna,
                    valuemax: 400.0,
                  ),
                ),
              ),
              BuildTank(
                containerHeight: containerHeight,
                containerWidth: containerWidth,
                porcentaje: tankProvider.porcentajeCis / 100,
                onChanged: (double value) {
                  tankProvider.levelOnCis(value);
                },
                valuePercent: tankProvider.limMinCis,
                valueMax: 100.0,
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
                provider.connectToWS();
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
                    provider.removeConfig();
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
                  },
                  child: Text(
                    'ignorar',
                    style: TextStyle(color: azulObscuro),
                  )),
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
}
