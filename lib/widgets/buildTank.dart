import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:water_level_controller/widgets/spinBox.dart';

class BuildTank extends StatelessWidget {
  final double containerHeight;
  final double containerWidth;
  final double porcentaje;
  final double valueMin;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangedOff;
  final double valuePercent;
  final double valuePercentMax;
  final double valueMax;
  final bool tinacoOrCist;

  const BuildTank({
    super.key,
    required this.containerHeight,
    required this.containerWidth,
    required this.porcentaje,
    required this.onChanged,
    required this.valuePercent,
    required this.valueMax,
    required this.onChangedOff,
    required this.tinacoOrCist,
    required this.valueMin,
    required this.valuePercentMax,
  });
  @override
  Widget build(BuildContext context) {
    Color azulClaro = const Color(0xFF30A4BA);
    Color azulObscuro = const Color(0xFF134874);
    Color azulMasClaro = const Color.fromARGB(255, 190, 247, 255);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(20.0), // Ajusta el valor para el redondeo
          child: LiquidLinearProgressIndicator(
            value: porcentaje,
            valueColor: AlwaysStoppedAnimation(azulObscuro),
            backgroundColor: azulClaro,
            direction: Axis.vertical,
            borderRadius: 20.0,
            borderWidth: 1.0,
            borderColor: azulClaro,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'Iniciar: $valuePercent %',
                      style: TextStyle(
                        fontSize: containerWidth * 0.045,
                        color: azulMasClaro,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: CircularPercentIndicator(
                    radius: containerHeight * 0.14,
                    lineWidth: containerWidth * 0.025,
                    percent: porcentaje,
                    progressColor: azulMasClaro,
                    backgroundColor: Colors.white10,
                  ),
                ),
                tinacoOrCist
                    ? Expanded(
                        child: Center(
                          child: Text(
                            'Detener: $valuePercentMax %',
                            style: TextStyle(
                              fontSize: containerWidth * 0.045,
                              color: azulMasClaro,
                            ),
                          ),
                        ),
                      )
                    : const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
    //);
  }
}
