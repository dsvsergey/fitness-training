import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:auto_route/auto_route.dart';
import 'package:fitness_training/core/resources/resources.dart';
import 'package:fitness_training/core/resources/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum MetronomeState { playing, stopped, stopping }

class MetronomeControl extends StatefulWidget {
  const MetronomeControl({super.key});
  @override
  MetronomeControlState createState() => MetronomeControlState();
}

class MetronomeControlState extends State<MetronomeControl> {
  final _maxRotationAngle = 0.26;
  final _minTempo = 30;
  final _maxTempo = 220;
  //late AudioPlayer _audioCache;
  final List<int> _tapTimes = [];
  int _tempo = 60;
  bool _bobPanning = false;

  MetronomeState _metronomeState = MetronomeState.stopped;
  late int _lastFrameTime = 0;
  late Timer _tickTimer = Timer(Duration.zero, () {});
  late Timer _frameTimer = Timer(Duration.zero, () {});
  late int _lastEvenTick;
  late bool _lastTickWasEven;
  late int _tickInterval;
  late double _rotationAngle = 0;
  MetronomeControlState();

  @override
  void dispose() {
    _frameTimer.cancel();
    _tickTimer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // _audioCache = AudioPlayer();
  }

  void _start() {
    _metronomeState = MetronomeState.playing;

    double bps = _tempo / 60;
    _tickInterval = 1000 ~/ bps;
    _lastEvenTick = DateTime.now().millisecondsSinceEpoch;
    _tickTimer = Timer.periodic(Duration(milliseconds: _tickInterval), _onTick);
    _animationLoop();

    SystemSound.play(SystemSoundType.click);

    if (mounted) setState(() {});
  }

  void _animationLoop() {
    _frameTimer.cancel();
    int thisFrameTime = DateTime.now().millisecondsSinceEpoch;

    if (_metronomeState == MetronomeState.playing ||
        _metronomeState == MetronomeState.stopping) {
      int delay =
          max(0, _lastFrameTime + 17 - DateTime.now().millisecondsSinceEpoch);
      _frameTimer = Timer(Duration(milliseconds: delay), () {
        _animationLoop();
      });
    } else {
      _rotationAngle = 0;
    }
    if (mounted) setState(() {});
    _lastFrameTime = thisFrameTime;
  }

  void _onTick(Timer t) {
    _lastTickWasEven = t.tick % 2 == 0;
    if (_lastTickWasEven) _lastEvenTick = DateTime.now().millisecondsSinceEpoch;
    if (_metronomeState == MetronomeState.playing) {
      SystemSound.play(SystemSoundType.click);
      //_audioCache.play(AssetSource('assets/metronom.mp3'));

      //         .then((value) {})
      //         .catchError((error) {});
    } else if (_metronomeState == MetronomeState.stopping) {
      _tickTimer.cancel();
      _metronomeState = MetronomeState.stopped;
    }
  }

  void _stop() {
    _metronomeState = MetronomeState.stopping;
    if (mounted) setState(() {});
  }

  void _tap() {
    if (_metronomeState != MetronomeState.stopped) return;
    int now = DateTime.now().millisecondsSinceEpoch;
    _tapTimes.add(now);
    if (_tapTimes.length > 3) {
      _tapTimes.removeAt(0);
    }
    int tapCount = 0;
    int tapIntervalSum = 0;

    for (int i = _tapTimes.length - 1; i >= 1; i--) {
      int currentTapTime = _tapTimes[i];
      int previousTapTime = _tapTimes[i - 1];
      int currentInterval = currentTapTime - previousTapTime;
      if (currentInterval > 3000) break;

      tapIntervalSum += currentInterval;
      tapCount++;
    }
    if (tapCount > 0) {
      int msBetweenTicks = tapIntervalSum ~/ tapCount;
      double bps = 1000 / msBetweenTicks;
      _tempo = min(max((bps * 60).toInt(), _minTempo), _maxTempo);
    }
    if (mounted) setState(() {});
  }

  double _getRotationAngle() {
    double rotationAngle = 0;
    double segmentPercent;
    double begin;
    double end;
    Curve curve;

    int now = DateTime.now().millisecondsSinceEpoch;
    double oscillationPercent = 0;
    if (_metronomeState == MetronomeState.playing ||
        _metronomeState == MetronomeState.stopping) {
      int delta = now - _lastEvenTick;
      if (delta > _tickInterval * 2) {
        delta -= (_tickInterval * 2);
      }
      oscillationPercent = (delta).toDouble() / (_tickInterval * 2);
      if (oscillationPercent < 0 || oscillationPercent > 1) {
        oscillationPercent = min(1, max(0, oscillationPercent));
      }
    }

    if (oscillationPercent < 0.25) {
      segmentPercent = oscillationPercent * 4;
      begin = 0;
      end = _maxRotationAngle;
      curve = Curves.easeOut;
    } else if (oscillationPercent < 0.75) {
      segmentPercent = (oscillationPercent - 0.25) * 2;
      begin = _maxRotationAngle;
      end = -_maxRotationAngle;
      curve = Curves.easeInOut;
    } else {
      segmentPercent = (oscillationPercent - 0.75) * 4;
      begin = -_maxRotationAngle;
      end = 0;
      curve = Curves.easeIn;
    }

    CurveTween curveTween = CurveTween(curve: curve);
    double easedPercent = curveTween.transform(segmentPercent);

    Tween tween = Tween<double>(begin: begin, end: end);
    rotationAngle = tween.transform(easedPercent) as double;

    return rotationAngle;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    _rotationAngle = _getRotationAngle();
    Color buttonTextColor = Colors.white;
    Color tapButtonTextColor = Colors.white;
    return Scaffold(
      backgroundColor: AppColors.colorMain,
      appBar: AppBar(
        backgroundColor: AppColors.colorMain,
        leading: IconButton(
          icon: Image.asset(
            AppPngs.back,
            color: Colors.black,
            height: (screenWidth > 600) ? 400 : 150,
            width: (screenWidth > 600) ? 400 : 250,
          ),
          onPressed: () {
            AutoRouter.of(context).pop();
          },
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(height: 20),
          Expanded(child: LayoutBuilder(builder: (context, constraints) {
            double aspectRatio = 1.5; // height:width
            double width =
                (constraints.maxHeight >= constraints.maxWidth * aspectRatio)
                    ? constraints.maxWidth
                    : constraints.maxHeight / aspectRatio;
            double height =
                (constraints.maxHeight >= constraints.maxWidth * aspectRatio)
                    ? width * aspectRatio
                    : constraints.maxHeight;

            return _wand(width, height);
          })),
          Container(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
              onPressed: _metronomeState == MetronomeState.stopping
                  ? null
                  : () {
                      setState(() {
                        buttonTextColor =
                            _metronomeState == MetronomeState.stopped
                                ? Colors.green
                                : _metronomeState == MetronomeState.stopping
                                    ? Colors.yellow
                                    : Colors.red;

                        _metronomeState == MetronomeState.stopped
                            ? _start()
                            : _stop();
                      });
                    },
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: buttonTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                child: Text(
                  _metronomeState == MetronomeState.stopped
                      ? "Start"
                      : _metronomeState == MetronomeState.stopping
                          ? "Stopping"
                          : "Stop",
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
              onPressed: _metronomeState == MetronomeState.stopped
                  ? () {
                      setState(() {
                        tapButtonTextColor = Colors.blue;

                        _tap();
                      });
                    }
                  : null,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: tapButtonTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                child: const Text("Tap"),
              ),
            ),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _wand(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: GestureDetector(
        onPanDown: (dragDownDetails) {
          RenderObject? renderObject = context.findRenderObject();
          if (renderObject != null && renderObject is RenderBox) {
            Offset localPosition =
                renderObject.globalToLocal(dragDownDetails.globalPosition);
            if (_bobHitTest(width, height, localPosition)) _bobPanning = true;
          }
        },
        onPanUpdate: (dragUpdateDetails) {
          if (_bobPanning) {
            RenderObject? renderObject = context.findRenderObject();
            if (renderObject != null && renderObject is RenderBox) {
              Offset localPosition =
                  renderObject.globalToLocal(dragUpdateDetails.globalPosition);
              _bobDragTo(width, height, localPosition);
            }
          }
        },
        onPanEnd: (dragEndDetails) {
          _bobPanning = false;
        },
        onPanCancel: () {
          _bobPanning = false;
        },
        child: CustomPaint(
          foregroundPainter: MetronomeWandPainter(
              width: width,
              height: height,
              tempo: _tempo,
              minTempo: _minTempo,
              maxTempo: _maxTempo,
              rotationAngle: _rotationAngle),
          child: const InkWell(),
        ),
      ),
    );
  }

  bool _bobHitTest(double width, double height, Offset localPosition) {
    if (_metronomeState != MetronomeState.stopped) return false;

    Offset translatedLocalPos =
        localPosition.translate(-width / 2, -height * 0.75);
    WandCoords wandCoords =
        WandCoords(width, height, _tempo, _minTempo, _maxTempo);

    return ((translatedLocalPos.dy - wandCoords.bobCenter.dy).abs() <
        height / 20);
  }

  void _bobDragTo(double width, double height, Offset localPosition) {
    Offset translatedLocalPos =
        localPosition.translate(-width / 2, -height * 0.75);
    WandCoords wandCoords =
        WandCoords(width, height, _tempo, _minTempo, _maxTempo);

    double bobPercent =
        (translatedLocalPos.dy - wandCoords.bobMinY) / wandCoords.bobTravel;
    _tempo = min(
        _maxTempo,
        max(_minTempo,
            _minTempo + (bobPercent * (_maxTempo - _minTempo)).toInt()));
    double bps = _tempo / 60;
    _tickInterval = 1000 ~/ bps;

    setState(() {});
  }
}

class WandCoords {
  late Offset bobCenter;
  late Offset counterWeightCenter;
  late double counterWeightRadius;
  late Offset stickTop;
  late Offset stickBottom;
  late Offset rotationCenter;
  late double rotationCenterRadius;
  late double bobMinY;
  late double bobMaxY;
  late double bobTravel;

  // calculates all coordinates relative to the rotation center and scaled based on height and width.
  WandCoords(
      double width, double height, int tempo, int minTempo, int maxTempo) {
    rotationCenter = const Offset(0, 0);
    rotationCenterRadius = width / 40;

    counterWeightCenter = Offset(0, height * 0.175);
    counterWeightRadius = width / 12;

    stickTop = Offset(0, -height * 0.68);
    stickBottom = Offset(0, height * 0.175);

    double bobHeight = height / 15;
    bobMinY = stickTop.dy;
    bobMaxY = rotationCenter.dy - rotationCenterRadius - bobHeight / 2 - 2;
    bobTravel = bobMaxY - bobMinY;
    double tempoPercent = (tempo - minTempo) / (maxTempo - minTempo);
    double bobPercent = tempoPercent;
    bobCenter = Offset(0, bobMinY + (bobTravel * bobPercent));
  }
}

class MetronomeWandPainter extends CustomPainter {
  // props required for painting
  double width;
  double height;
  int tempo;
  int minTempo;
  int maxTempo;
  double rotationAngle;

  static ui.Picture? wandPicture;
  final Color _bobTextColor = Colors.white;
  late Map<String, Paint> paints;

  MetronomeWandPainter({
    required this.width,
    required this.height,
    required this.tempo,
    required this.minTempo,
    required this.maxTempo,
    required this.rotationAngle,
  }) {
    paints = <String, Paint>{};
  }

  _initFillsAndPaints() {
    if (paints.isEmpty) {
      paints = {
        "strokeBase": Paint()
          ..color = Colors.black
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..strokeWidth = width * 0.015,
        "fillCounterWeight": Paint()
          ..color = Colors.deepPurple
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.fill,
        "fillRotationCenter": Paint()
          ..color = Colors.black
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.fill,
        "fillBob": Paint()
          ..color = Colors.teal
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.fill,
      };
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (paints.isEmpty) _initFillsAndPaints();

    if (wandPicture == null) {
      // draw unrotated wand on to a picture canvas
      ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      Canvas pictureCanvas = Canvas(pictureRecorder);

      _drawWandOnCanvas(pictureCanvas);
      wandPicture = pictureRecorder.endRecording();
    }
    canvas.translate(width / 2, height * .75);
    canvas.rotate(rotationAngle);
    if (wandPicture != null) {
      canvas.drawPicture(wandPicture!);
    }
  }

  _drawWandOnCanvas(Canvas canvas) {
    WandCoords wandCoords =
        WandCoords(width, height, tempo, minTempo, maxTempo);

    List<Offset> bobPoints = [
      Offset(wandCoords.bobCenter.dx + width / 8,
          wandCoords.bobCenter.dy + height / 20),
      Offset(wandCoords.bobCenter.dx - width / 8,
          wandCoords.bobCenter.dy + height / 20),
      Offset(wandCoords.bobCenter.dx - width / 6,
          wandCoords.bobCenter.dy - height / 20),
      Offset(wandCoords.bobCenter.dx + width / 6,
          wandCoords.bobCenter.dy - height / 20)
    ];

    Path bobPath = Path()..addPolygon(bobPoints, true);

    ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textDirection: TextDirection.ltr,
        fontSize: width / 15,
        textAlign: TextAlign.left,
      ),
    )
      ..pushStyle(ui.TextStyle(color: _bobTextColor))
      ..addText('$tempo');

    ui.Paragraph paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: width / 4));

    Offset paragraphPos = Offset(
        wandCoords.bobCenter.dx - paragraph.maxIntrinsicWidth / 2.0,
        wandCoords.bobCenter.dy - paragraph.height / 2.0);

    canvas.drawLine(wandCoords.stickTop, wandCoords.stickBottom,
        paints["strokeBase"] ?? Paint());
    canvas.drawCircle(
        wandCoords.rotationCenter,
        wandCoords.rotationCenterRadius,
        paints["fillRotationCenter"] ?? Paint());
    canvas.drawCircle(wandCoords.counterWeightCenter,
        wandCoords.counterWeightRadius, paints["fillCounterWeight"] ?? Paint());
    canvas.drawCircle(wandCoords.counterWeightCenter,
        wandCoords.counterWeightRadius, paints["strokeBase"] ?? Paint());
    canvas.drawPath(bobPath, paints["fillBob"] ?? Paint());
    canvas.drawPath(bobPath, paints["strokeBase"] ?? Paint());
    canvas.drawParagraph(paragraph, paragraphPos);
  }

  @override
  bool shouldRepaint(MetronomeWandPainter oldDelegate) {
    if (oldDelegate.tempo != tempo) {
      wandPicture = null;
    }
    return (oldDelegate.rotationAngle != rotationAngle ||
        oldDelegate.tempo != tempo);
  }
}
