import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_level_controller/provider/Tankprovider.dart'; // Asegúrate de que esta sea la ruta correcta
import 'package:water_level_controller/provider/configProvider.dart';
import 'package:water_level_controller/views/levelController.dart';

class ConfigView extends StatelessWidget {
  const ConfigView({super.key});

  @override
  Widget build(BuildContext context) {
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
                    child: const WaterLevelController(),
                  );
                },
              ),
            );
          });
        }
        final size = MediaQuery.of(context).size.height;
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Icon(
                      Icons.cell_tower,
                      size: size * 0.1,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      configProvider.textTittle,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: Colors.black, fontSize: size * 0.05),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'SSID (Network name)',
                      ),
                      controller: configProvider.ssidController,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Password',
                      ),
                      obscureText: false,
                      controller: configProvider.passwordController,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(child: SizedBox()),
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            onPressed: () {
                              configProvider.updateTextFields();
                            },
                            child: Text(
                              'Enviar Crendenciales',
                              style: TextStyle(
                                  color: Colors.black, fontSize: size * 0.03),
                            ),
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        //Expanded(flex: 3, child: SizedBox()),
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            onPressed: () {
                              const intent = AndroidIntent(
                                  action: 'android.settings.WIFI_SETTINGS');
                              intent.launch();
                            },
                            child: Text(
                              'Abir Gestor Wifi',
                              style: TextStyle(
                                  color: Colors.black, fontSize: size * 0.03),
                            ),
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            onPressed: () {
                              //configProvider.changePageHandle(true);
                              configProvider.removeConfig();
                            },
                            child: Text(
                              'Restaurar Config.',
                              style: TextStyle(
                                  color: Colors.black, fontSize: size * 0.03),
                            ),
                          ),
                        ),
                        Expanded(child: SizedBox())
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
