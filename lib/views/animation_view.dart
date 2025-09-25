import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

class PruebaView extends StatefulWidget {
  const PruebaView({super.key});

  @override
  State<PruebaView> createState() => _PruebaViewState();
}

class _PruebaViewState extends State<PruebaView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba View'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
              width: 100,
              child: LiquidLinearProgressIndicator(
                value: 1,
                valueColor: AlwaysStoppedAnimation(Colors.blue),
                backgroundColor: Colors.grey[300],
                borderColor: Colors.blue,
                borderWidth: 4.0,
                direction: Axis.vertical,
                center: const Text('50%'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
