import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:water_level_controller/provider/Tankprovider.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  // Colores definidos
  final Color azulObscuro = Colors.blue[900]!;
  final Color azulClaro = Colors.blue[200]!;
  final Color azulMasClaro = Colors.blue[100]!;

  @override
  void dispose() {
    //Provider.of<TankProvider>(context, listen: false).closeConnectionToServer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final tankProvider = context.watch<TankProvider>();
    final screenWidth = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        actions: [],
        toolbarHeight: screenWidth * 0.1,
        title: Text(
          'Configuracion',
          style: TextStyle(),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                spinBoxBuild(
                  state: tankProvider.iniciar,
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
                spinBoxBuild(
                    state: tankProvider.iniciar,
                    name: 'Iniciar en %',
                    screenWidth: screenWidth,
                    azulObscuro: azulObscuro,
                    value: tankProvider.limMinTin,
                    onChanged: (value) {
                      tankProvider.levelOnTin(value);
                    }),

                const SizedBox(height: 20),
                spinBoxBuild(
                    state: tankProvider.iniciar,
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
                spinBoxBuild(
                    state: tankProvider.iniciar,
                    name: 'Altura de la Cisterna (cm)',
                    screenWidth: screenWidth,
                    azulObscuro: azulObscuro,
                    value: tankProvider.alturaCisterna,
                    onChanged: (value) {
                      tankProvider.heightCis(value);
                    }),
                // Altura de la Cisterna

                const SizedBox(height: 20),
                spinBoxBuild(
                    state: tankProvider.iniciar,
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
                  height: screenWidth * 0.09,
                  width: screenWidth * 0.5,
                  child: ElevatedButton.icon(
                      onPressed: () {
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
                      label:
                          Text(tankProvider.iniciar ? 'Detener' : 'Iniciar')),
                ),

                // Aquí puedes agregar el AnimatedToggleSwitch si lo necesitas*/
              ],
            )),
      ),
    );
  }
}

Widget spinBoxBuild(
    {required String name,
    required final double screenWidth,
    required final Color azulObscuro,
    required final double value,
    required final ValueChanged<double> onChanged,
    required final bool state}) {
  return SpinBox(
      decoration: InputDecoration(
        floatingLabelAlignment: FloatingLabelAlignment.center,
        labelText: name,
        labelStyle: TextStyle(color: azulObscuro),
        border: InputBorder.none,
        filled: true,
        fillColor: Colors.transparent,
      ),
      incrementIcon: Icon(
        Icons.keyboard_arrow_right,
        size: screenWidth * 0.05,
        color: azulObscuro,
      ),
      decrementIcon: Icon(
        Icons.keyboard_arrow_left,
        size: screenWidth * 0.05,
        color: azulObscuro,
      ),
      textStyle: TextStyle(
        color: azulObscuro,
        fontSize: screenWidth * 0.025,
      ),
      enabled: state ? false : true,
      step: 5,
      min: 0,
      max: 400,
      value: value,
      onSubmitted: onChanged);
}
