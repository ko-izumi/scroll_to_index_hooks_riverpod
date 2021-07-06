// Copyright (C) Kosuke Izumi. All Rights Reserved.
// History: Tue July 07 08:48 JST 2021
// Author: Kosuke Izumi

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

final counterProvider = StateNotifierProvider((_) => Counter());

void main() => runApp(ProviderScope(child: MyApp()));

class Counter extends StateNotifier<int> {
  Counter() : super(0);
  void increment() => state++;
  void init() => state = 0;
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scroll To Index Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

// ignore: must_be_immutable
class MyHomePage extends HookWidget {
  MyHomePage({Key? key}) : super(key: key);

  static const maxCount = 100;
  final random = math.Random();
  final scrollDirection = Axis.vertical;

  late AutoScrollController controller;
  List<List<int>> randomList = [];

  @override
  Widget build(BuildContext context) {

    final state = useProvider(counterProvider);

    useEffect(() {
      // print('useEffect is called.');
      // print('randomList size is ${randomList.length}');

      if(randomList.length == 0) {
        controller = AutoScrollController(
            viewportBoundaryGetter: () =>
                Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom), axis: scrollDirection);
        randomList = List.generate(maxCount, (index) => <int>[index, (1000 * random.nextDouble()).toInt()]
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Demo of Scroll to index'),
      ),
      body: ListView(
        scrollDirection: scrollDirection,
        controller: controller,
        children: randomList.map<Widget>((data) {
          return Padding(
            padding: EdgeInsets.all(8),
            child: _getRow(data[0], math.max(data[1].toDouble(), 50.0)),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (state >= maxCount) context.read(counterProvider.notifier).init();
          context.read(counterProvider.notifier).increment();

          await controller.scrollToIndex(state,
              preferPosition: AutoScrollPosition.begin);
          controller.highlight(state);
        },
        tooltip: 'Increment',
        child: Text((state - 1).toString()),
      ),
    );
  }

  Widget _getRow(int index, double height) {
    return _wrapScrollTag(
        index: index,
        child: Container(
          padding: EdgeInsets.all(8),
          alignment: Alignment.topCenter,
          height: height,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.lightBlue, width: 4),
              borderRadius: BorderRadius.circular(12)),
          child: Text('index: $index, height: $height'),
        ));
  }

  Widget _wrapScrollTag({required int index, required Widget child}) =>
      AutoScrollTag(
        key: ValueKey(index),
        controller: controller,
        index: index,
        child: child,
        highlightColor: Colors.black.withOpacity(0.5),
      );
}