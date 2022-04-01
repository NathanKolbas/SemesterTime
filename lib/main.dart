import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Semester Time',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
        backgroundColor: Color(0xffd00000),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Duration animDur = Duration(seconds: 2);
  DateTime now = DateTime.now();
  DateTime startOfSemester = DateTime(2022, 1, 18);
  DateTime endOfSemester = DateTime(2022, 5, 13);
  late Duration remaining;
  late ConfettiController _confettiController;
  late Timer timer;

  bool semesterComplete() {
    return endOfSemester.difference(now).isNegative;
  }

  void timeRemaining() {
    remaining = endOfSemester.difference(now);
  }

  double percentRemaining() {
    int endDur = endOfSemester.difference(now).inSeconds;
    int startDur = endOfSemester.difference(startOfSemester).inSeconds;
    double percent = min(100, 100 - (endDur / startDur * 100));
    return double.tryParse(percent.toStringAsFixed(2)) ?? 0; // 2 sig figs
  }

  String twoSigFigs(double v) {
    return v.toStringAsFixed(2);
  }

  double minWH(BuildContext context) {
    return min(MediaQuery.of(context).size.height, MediaQuery.of(context).size.width);
  }

  @override
  void initState() {
    timeRemaining();
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
    if (semesterComplete()) _confettiController.play();
    // This is just a simple timer to refresh the data.
    timer = Timer.periodic(Duration(hours: 1), (Timer t) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: SizedBox(
          height: minWH(context) * 0.9,
          width: minWH(context) * 0.9,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  numberOfParticles: 20, // number of particles to emit
                  particleDrag: 0.05, // apply drag to the confetti
                  emissionFrequency: 0.05, // how often it should emit
                  gravity: 0.05, // gravity - or fall speed
                  blastDirectionality: BlastDirectionality.explosive, // don't specify a direction, blast randomly
                  shouldLoop: true, // start again as soon as the animation is finished
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple
                  ], // manually specify the colors to be used
                ),
              ),
              TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.00, end: percentRemaining()),
                  duration: animDur,
                  curve: Curves.easeInOut,
                  builder: (BuildContext context, double percent, Widget? child) {
                    return SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: CircularProgressIndicator(
                        value: percent / 100,
                        color: Color(0xFFF5F1E7),
                        strokeWidth: 10.0,
                        backgroundColor: Color(0x40FFFFFF),
                      ),
                    );
                  }),
              SizedBox(
                height: minWH(context) * 0.8,
                width: minWH(context) * 0.8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.00, end: percentRemaining()),
                        duration: animDur,
                        curve: Curves.easeInOut,
                        builder: (BuildContext context, double percent, Widget? child) {
                          return FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              '${twoSigFigs(percent)}% Complete',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF5F1E7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }),
                    SizedBox(
                      height: 18,
                    ),
                    FittedBox(
                      fit: BoxFit.fitWidth,
                      child: semesterComplete() ?
                        Icon(
                          Icons.check,
                          size: 100,
                          color: Color(0xFFF5F1E7),
                        )
                            :
                        Text(
                          '${remaining.inDays} Days Left',
                          style: Theme.of(context).textTheme.headline4!.apply(color: Color(0xFFF5F1E7)),
                          textAlign: TextAlign.center,
                        ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }
}
