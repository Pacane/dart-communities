import 'dart:html';
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:polymer/polymer.dart';
import '../../../src/input_formatter.dart';

@CustomTag('live-date-time')
class LiveDateTime extends PolymerElement {
  @observable String formattedValue;

  @PublishedProperty(reflect: true) DateTime value;
  @observable DateTime toValue;
  @published var formatter;
  @published bool stripAgo = false;

  var subs = [];


  attached() {

    subs.clear();

    update();


//    observe(() => value, (_) {
//      update();
//    });
  }

  detached() {
    subs.forEach((sub) => sub.cancel());
  }

  update() {


    //value = DateTime.toLocal(value);
    if (value is DateTime) formattedValue = InputFormatter.formatMomentDate(value, short: true, momentsAgo: true);
    if (value is! DateTime) {
      print("""
      Not DateTime: $value
      """);
    }
    print(value.runtimeType.toString());

    if (stripAgo && formattedValue != null) formattedValue = formattedValue.replaceAll(' ago', '');

    if (value == null) return;

    var secondsUntilUpdate = 1;
    var diff = value.difference(new DateTime.now());

    var seconds = diff.inSeconds.abs();
    if (seconds >= 60) {
      secondsUntilUpdate = 60 - seconds % 60;
    }

    if (secondsUntilUpdate == 0) secondsUntilUpdate = 1;

    subs.add(new Timer(new Duration(seconds: secondsUntilUpdate), () {
      update();
    }));
  }

  LiveDateTime.created() : super.created();

}