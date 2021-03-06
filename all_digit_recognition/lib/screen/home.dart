import 'dart:ffi';

import 'package:all_digit_recognition/model/classifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_tts/flutter_tts.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Offset?> points = [];
  final pointMode = ui.PointMode.points;
  int? digit = -1;
   FlutterTts flutterTts= FlutterTts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digit Recognizer'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 400,
            width: 400,
            color: Colors.black12,
            child: Container(
              color: Colors.black26,
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              padding: const EdgeInsets.all(5),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black45,
                ),
                child: GestureDetector(
                  onPanUpdate: (DragUpdateDetails details) {
                    Offset _location = details.localPosition;
                    if (_location.dx >= 0 &&
                        _location.dx <= 372 &&
                        _location.dy >= 0 &&
                        _location.dy <= 372) {
                      setState(() {
                        points.add(_location);
                      });
                    }
                    if (kDebugMode) {
                      print(_location);
                    }
                  },
                  onPanEnd: (DragEndDetails details) async {
                    digit = await Classifier().classifyDrawing(points);
                    flutterTts.speak("$digit");
                    points.add(null);
                    setState(() {});
                  },
                  child: CustomPaint(
                    painter: Painter(points: points),
                  ),
                ),
              ),
            ),
          ),
          // const SizedBox(height: 50,),
          Column(
            children: [
              if(digit!=null)Text(
                digit.toString(),
                style: const TextStyle(
                  fontSize: 60,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            points.clear();
            digit = null;
          });
        },
        child: const Icon(Icons.clear),
      ),
    );
  }
}

class Painter extends CustomPainter {
  final List<Offset?> points;

  Painter({required this.points});

  final Paint _paintDetails = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5.0
    ..color = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(
            points[i] as Offset, points[i + 1] as Offset, _paintDetails);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
