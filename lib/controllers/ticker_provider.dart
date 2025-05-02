import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class CustomTickerProvider extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}