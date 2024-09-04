import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:water_level_controller/shared/sharedPreferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class InactivityProvider extends ChangeNotifier {
  int _id = 1;
  Timer? _timer;
  bool _incrementing = true;

  int get id => _id;

  void starTimer() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_incrementing) {
        increment();
      } else {
        decrement();
      }
    });
  }

  void increment() {
    if (_id < 8) {
      _id++;
    } else {
      _incrementing = false;
    }
    notifyListeners();
  }

  void decrement() {
    if (_id > 1) {
      _id--;
    } else {
      _incrementing = true;
    }
    notifyListeners();
  }

  InactivityProvider() {
    starTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
