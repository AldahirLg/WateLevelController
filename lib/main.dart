import 'package:flutter/material.dart';
import 'package:water_level_controller/provider/Tankprovider.dart';
import 'package:water_level_controller/provider/configProvider.dart';
import 'package:water_level_controller/shared/sharedPreferences.dart';
import 'package:water_level_controller/views/config.dart';
import 'package:water_level_controller/views/levelController.dart';
import 'package:provider/provider.dart';
import 'package:water_level_controller/views/setting_%20view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TankProvider()),
        ChangeNotifierProvider(create: (_) => ConfigProvider())
      ],
      child: MaterialApp(
        title: 'WatterController',
        initialRoute: '/',
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => const WaterLevelController(),
          '/config': (context) => const ConfigView(),
          '/setting': (context) => const SettingView()
        },
      ),
    );
  }
}
