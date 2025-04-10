import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_level_controller/provider/Tankprovider.dart';
import 'package:water_level_controller/provider/configProvider.dart';

class LoadingDialogWidget extends StatelessWidget {
  const LoadingDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Color azulObscuro = const Color(0xFF134874);
    Color azulMasClaro = const Color.fromARGB(255, 190, 247, 255);
    final provider = Provider.of<ConfigProvider>(context);
    return AlertDialog(
      backgroundColor: azulMasClaro,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 14),
            child: !provider.succesConnection
                ? CircularProgressIndicator(
                    color: azulObscuro,
                  )
                : Text(
                    provider.messageConnection,
                    style: TextStyle(color: azulObscuro),
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cerrar',
            style: TextStyle(color: azulObscuro),
          ),
        ),
      ],
    );
  }
}
