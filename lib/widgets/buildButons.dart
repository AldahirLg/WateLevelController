import 'package:flutter/widgets.dart';
import 'package:water_level_controller/widgets/spinBox.dart';

class BuildButtons extends StatelessWidget {
  final double containerHeigth;
  final String tank;
  final ValueChanged<double> onChanged;
  final double valuePercent;
  final double valuemax;

  const BuildButtons(
      {super.key,
      required this.tank,
      required this.containerHeigth,
      required this.onChanged,
      required this.valuePercent,
      required this.valuemax});

  @override
  Widget build(BuildContext context) {
    Color azulClaro = const Color(0xFF30A4BA);
    Color azulObscuro = const Color(0xFF134874);
    Color azulMasClaro = const Color.fromARGB(255, 190, 247, 255);
    return Column(
      children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(tank,
              style: TextStyle(
                  fontSize: containerHeigth * 0.08, color: azulObscuro)),
        )),
        const Expanded(child: SizedBox()),
        Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: azulClaro,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  double containerWidth = constraints.maxWidth;
                  double containerHeight = constraints.maxHeight;
                  return Column(
                    children: [
                      Expanded(
                        child: Text(
                          'Altura(cm)',
                          style: TextStyle(
                              color: azulMasClaro,
                              fontSize: containerWidth * 0.09),
                        ),
                      ),
                      BuildSpinBox(
                        containerHeight: containerHeight * 2,
                        text: '',
                        rotate: 4,
                        valuePercent: valuePercent,
                        onchaganed: onChanged,
                        valueMax: valuemax,
                      )
                    ],
                  );
                }),
              ),
            ))
      ],
    );
  }
}
