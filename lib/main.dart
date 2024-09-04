import 'package:flutter/material.dart';
import 'package:water_level_controller/provider/Tankprovider.dart';
import 'package:water_level_controller/provider/configProvider.dart';
import 'package:water_level_controller/shared/sharedPreferences.dart';
import 'package:water_level_controller/views/config.dart';
import 'package:water_level_controller/views/levelController.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<String?>(
        future: getIp('ip'),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            // Si `ip` no es nulo, proveemos `TankProvider` solo a `WaterLevelController`
            return ChangeNotifierProvider(
              create: (_) => TankProvider(),
              child: const WaterLevelController(),
            );
          } else {
            // Si `ip` es nulo, proveemos `ConfigProvider` solo a `ConfigView`
            return ChangeNotifierProvider(
              create: (_) => ConfigProvider(),
              child: const ConfigView(),
            );
          }
        },
      ),
    );
  }
}
