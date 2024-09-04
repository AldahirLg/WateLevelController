import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

class BuildSpinBox extends StatelessWidget {
  final int rotate;
  final String text;
  final double containerHeight;
  final double valuePercent;
  final double valueMax;
  final ValueChanged<double> onchaganed;

  const BuildSpinBox(
      {super.key,
      required this.containerHeight,
      required this.text,
      required this.rotate,
      required this.valuePercent,
      required this.onchaganed,
      required this.valueMax});

  @override
  Widget build(BuildContext context) {
    Color azulMasClaro = Color.fromARGB(255, 190, 247, 255);
    return Expanded(
        child: RotatedBox(
      quarterTurns: rotate,
      child: SpinBox(
        decoration: InputDecoration(
            labelText: text,
            labelStyle: TextStyle(color: azulMasClaro),
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.transparent),
        incrementIcon: Icon(
          Icons.keyboard_arrow_right,
          size: containerHeight * 0.1,
          color: azulMasClaro,
        ),
        decrementIcon: Icon(
          Icons.keyboard_arrow_left,
          size: containerHeight * 0.1,
          color: azulMasClaro,
        ),
        textStyle:
            TextStyle(color: azulMasClaro, fontSize: containerHeight * 0.05),
        step: 5,
        min: 0,
        max: valueMax,
        value: valuePercent,
        onSubmitted: onchaganed,
      ),
    ));
  }
}
