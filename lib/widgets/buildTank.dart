import 'package:flutter/material.dart';

import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:water_level_controller/widgets/spinBox.dart';

class BuildTank extends StatelessWidget {
  final double containerHeight;
  final double containerWidth;
  final double porcentaje;
  final ValueChanged<double> onChanged;
  final double valuePercent;
  final double valueMax;

  const BuildTank({
    super.key,
    required this.containerHeight,
    required this.containerWidth,
    required this.porcentaje,
    required this.onChanged,
    required this.valuePercent,
    required this.valueMax,
  });
  @override
  Widget build(BuildContext context) {
    Color azulClaro = const Color(0xFF30A4BA);
    Color azulObscuro = const Color(0xFF134874);
    Color azulMasClaro = const Color.fromARGB(255, 190, 247, 255);
    return Expanded(
      child: RotatedBox(
        quarterTurns: 3,
        child: LinearPercentIndicator(
            barRadius: const Radius.circular(10),
            width: containerHeight * 0.99,
            lineHeight: containerWidth * 0.4,
            percent: porcentaje,
            progressColor: azulObscuro,
            backgroundColor: azulClaro,
            center: Row(
              children: [
                BuildSpinBox(
                  containerHeight: containerHeight,
                  text: 'level On',
                  rotate: 1,
                  valuePercent: valuePercent,
                  onchaganed: onChanged,
                  valueMax: valueMax,
                ),
                RotatedBox(
                  quarterTurns: 1,
                  child: Text(
                    '${(porcentaje * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                        fontSize: containerHeight * 0.065, color: azulMasClaro),
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
              ],
            )),
      ),
    );
  }
}
