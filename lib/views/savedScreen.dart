import 'dart:async';

import 'package:flutter/material.dart';

class RandomImages extends StatefulWidget {
  const RandomImages({super.key});

  @override
  State<RandomImages> createState() => _RandomImagesState();
}

class _RandomImagesState extends State<RandomImages> {
  @override
  void initState() {
    starTimer();
    super.initState();
  }

  int id = 1;
  Timer? timer;
  bool incrementing = true;

  void starTimer() {
    timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      setState(() {
        if (incrementing) {
          increment();
        } else {
          decrement();
        }
      });
    });
  }

  void increment() {
    if (id < 8) {
      id++;
    } else {
      incrementing = false;
    }
  }

  void decrement() {
    if (id > 1) {
      id--;
    } else {
      incrementing = true;
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: AnimatedSwitcher(
          duration: Duration(seconds: 15),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: Stack(
            key: ValueKey<int>(id),
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/$id.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
