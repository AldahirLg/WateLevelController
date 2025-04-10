import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BuildButtons extends StatelessWidget {
  final double containerHeigth;
  final String tank;
  final ValueChanged<double> onChanged;
  final double valuePercent;
  final double porcentaje;

  final double valuemax;
  final bool stateRele;

  const BuildButtons({
    super.key,
    required this.tank,
    required this.containerHeigth,
    required this.onChanged,
    required this.valuePercent,
    required this.valuemax,
    required this.porcentaje,
    required this.stateRele,
  });

  @override
  Widget build(BuildContext context) {
    Color azulClaro = const Color(0xFF30A4BA);
    Color azulObscuro = const Color(0xFF134874);
    Color azulMasClaro = const Color.fromARGB(255, 190, 247, 255);
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Text(tank,
              style: TextStyle(
                  fontSize: containerHeigth * 0.08, color: azulObscuro)),
        ),
        Expanded(
            flex: 1,
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              double containerWidth = constraints.maxWidth;
              double containerHeight = constraints.maxHeight;
              return Text('${(porcentaje * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                      fontSize: containerHeight * 0.3, color: azulClaro));
            })),
        RotatingFan(
          isActive: stateRele,
        ),
        Expanded(
          flex: 2,
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            double containerWidth = constraints.maxWidth;
            double containerHeight = constraints.maxHeight;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Altura(cm)',
                    style: TextStyle(
                        fontSize: containerHeight * 0.1, color: azulClaro)),
                Text('$valuePercent',
                    style: TextStyle(
                        fontSize: containerHeight * 0.1, color: azulClaro))
              ],
            );
          }),
        )
      ],
    );
  }
}

class RotatingFan extends StatefulWidget {
  final bool isActive; // Variable para controlar la animación

  const RotatingFan({Key? key, required this.isActive}) : super(key: key);

  @override
  _RotatingFanState createState() => _RotatingFanState();
}

class _RotatingFanState extends State<RotatingFan>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Color azulClaro = const Color(0xFF30A4BA);
  Color azulObscuro = const Color(0xFF134874);
  Color azulMasClaro = const Color.fromARGB(255, 190, 247, 255);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _updateAnimationState(); // Iniciar o detener animación según el estado inicial
  }

  @override
  void didUpdateWidget(covariant RotatingFan oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Verificar cambios en la variable `isActive` y actualizar la animación
    if (oldWidget.isActive != widget.isActive) {
      _updateAnimationState();
    }
  }

  void _updateAnimationState() {
    if (widget.isActive) {
      _controller.repeat(); // Inicia la animación
    } else {
      _controller.stop(); // Detiene la animación
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double containerWidth = constraints.maxWidth;
          double containerHeight = constraints.maxHeight;

          return Container(
            width: containerWidth / 4,
            height: containerHeight / 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: azulClaro,
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 2.0,
              ),
              gradient: RadialGradient(
                colors: [
                  azulClaro,
                  azulClaro.withOpacity(0.7),
                  Colors.black.withOpacity(0.3),
                ],
                center: Alignment.center,
                radius: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: azulClaro.withOpacity(0.6),
                  blurRadius: 20.0,
                  spreadRadius: 5.0,
                ),
              ],
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _controller.value * 2 * 3.1416, // Rota en radianes
                    child: child,
                  );
                },
                child: Icon(
                  FontAwesomeIcons.fan,
                  size: containerWidth / 8,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
