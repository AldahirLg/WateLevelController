import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_level_controller/provider/Tankprovider.dart'; // Asegúrate de que esta sea la ruta correcta
import 'package:water_level_controller/provider/configProvider.dart';
import 'package:water_level_controller/shared/sharedPreferences.dart';
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
                    child: WaterLevelController(),
                  );
                },
              ),
            );
          });
        }
        final size = MediaQuery.of(context).size.height;
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('C O N F I G U R A C I O N'),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
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
                        Expanded(child: SizedBox()),
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            onPressed: () {
                              configProvider.updateTextFields();
                            },
                            child: Text(
                              'SEND CREDENTIAL',
                              style: TextStyle(
                                  color: Colors.black, fontSize: size * 0.03),
                            ),
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            onPressed: () async {
                              String? ip = await getIp('ip');
                              print(ip);
                            },
                            child: Text(
                              'OPEN GESTOR WIFI',
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
                              configProvider.changePageHandle(true);
                            },
                            child: Text(
                              'RESTAR CONFIG',
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
