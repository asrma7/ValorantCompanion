import 'dart:async';

import 'package:flutter/material.dart';

Timer? _timer;

class TimerComponent extends StatefulWidget {
  final int time;
  const TimerComponent({Key? key, required this.time}) : super(key: key);

  @override
  State<TimerComponent> createState() => _TimerComponentState();
}

class _TimerComponentState extends State<TimerComponent> {
  late int time;
  @override
  void initState() {
    time = widget.time;
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Time Remaining: ${timeFormatter(time)}',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String timeFormatter(int time) {
    int days = time ~/ (24 * 60 * 60);
    int hours = (time - days * 24 * 60 * 60) ~/ (60 * 60);
    int minutes = (time % 3600) ~/ 60;
    int seconds = (time % 3600) % 60;
    if (days > 0) {
      return '${twoDigits(days)}:${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        time -= 1;
        if (time == 0) {
          timer.cancel();
        }
      });
    });
  }

  String twoDigits(int num) {
    return (num < 10 ? '0' : '') + num.toString();
  }
}
