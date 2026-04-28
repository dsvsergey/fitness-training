import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

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
  }

  void _start() {
    _metronomeState = MetronomeState.playing;
    double bps = _tempo / 60;
    _tickInterval = 1000 ~/ bps;
    _lastEvenTick = DateTime.now().millisecondsSinceEpoch;
    _tickTimer =
        Timer.periodic(Duration(milliseconds: _tickInterval), _onTick);
    _animationLoop();
    SystemSound.play(SystemSoundType.click);
    if (mounted) setState(() {});
  }

  void _animationLoop() {
    _frameTimer.cancel();
    int thisFrameTime = DateTime.now().millisecondsSinceEpoch;
    if (_metronomeState == MetronomeState.playing ||
        _metronomeState == MetronomeState.stopping) {
      int delay = max(
          0, _lastFrameTime + 17 - DateTime.now().millisecondsSinceEpoch);
      _frameTimer =
          Timer(Duration(milliseconds: delay), () => _animationLoop());
    } else {
      _rotationAngle = 0;
    }
    if (mounted) setState(() {});
    _lastFrameTime = thisFrameTime;
  }

  void _onTick(Timer t) {
    _lastTickWasEven = t.tick % 2 == 0;
    if (_lastTickWasEven) {
      _lastEvenTick = DateTime.now().millisecondsSinceEpoch;
    }
    if (_metronomeState == MetronomeState.playing) {
      SystemSound.play(SystemSoundType.click);
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
    if (_tapTimes.length > 3) _tapTimes.removeAt(0);

    int tapCount = 0;
    int tapIntervalSum = 0;
    for (int i = _tapTimes.length - 1; i >= 1; i--) {
      int interval = _tapTimes[i] - _tapTimes[i - 1];
      if (interval > 3000) break;
      tapIntervalSum += interval;
      tapCount++;
    }
    if (tapCount > 0) {
      double bps = 1000 / (tapIntervalSum ~/ tapCount);
      _tempo = min(max((bps * 60).toInt(), _minTempo), _maxTempo);
    }
    if (mounted) setState(() {});
  }

  double _getRotationAngle() {
    double rotationAngle = 0;
    double segmentPercent, begin, end;
    Curve curve;

    int now = DateTime.now().millisecondsSinceEpoch;
    double oscillationPercent = 0;
    if (_metronomeState == MetronomeState.playing ||
        _metronomeState == MetronomeState.stopping) {
      int delta = now - _lastEvenTick;
      if (delta > _tickInterval * 2) delta -= _tickInterval * 2;
      oscillationPercent =
          min(1, max(0, delta.toDouble() / (_tickInterval * 2)));
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

    rotationAngle = Tween<double>(begin: begin, end: end)
        .transform(CurveTween(curve: curve).transform(segmentPercent));
    return rotationAngle;
  }

  @override
  Widget build(BuildContext context) {
    _rotationAngle = _getRotationAngle();
    final isPlaying = _metronomeState == MetronomeState.playing;
    final isStopping = _metronomeState == MetronomeState.stopping;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Metronome',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E1E1E),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FIcons.arrowLeft, color: Color(0xFF1E1E1E)),
          onPressed: () => AutoRouter.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // ── Tempo readout ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Column(
                  children: [
                    Text(
                      '$_tempo',
                      style: const TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 56,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E1E1E),
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'BPM',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
              // ── Wand ───────────────────────────────────────────────────
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  const aspectRatio = 1.5;
                  final width = constraints.maxHeight >=
                          constraints.maxWidth * aspectRatio
                      ? constraints.maxWidth
                      : constraints.maxHeight / aspectRatio;
                  final height = constraints.maxHeight >=
                          constraints.maxWidth * aspectRatio
                      ? width * aspectRatio
                      : constraints.maxHeight;
                  return _wand(width, height);
                }),
              ),
              const SizedBox(height: 12),
              // ── Hint ───────────────────────────────────────────────────
              const Text(
                'Drag the bob to change tempo, or tap the button below',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
              ),
              const SizedBox(height: 12),
              // ── Controls ──────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: FButton(
                      onPress: _metronomeState == MetronomeState.stopped
                          ? () => setState(() => _tap())
                          : null,
                      variant: FButtonVariant.outline,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          'Tap',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FButton(
                      onPress: isStopping
                          ? null
                          : () => setState(() {
                                isPlaying ? _stop() : _start();
                              }),
                      variant: FButtonVariant.primary,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          isStopping
                              ? 'Stopping…'
                              : isPlaying
                                  ? 'Stop'
                                  : 'Start',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wand(double width, double height) {
    return SizedBox(
      width: width,
      height: height,
      child: GestureDetector(
        onPanDown: (details) {
          final rb = context.findRenderObject() as RenderBox?;
          if (rb != null) {
            final local = rb.globalToLocal(details.globalPosition);
            if (_bobHitTest(width, height, local)) _bobPanning = true;
          }
        },
        onPanUpdate: (details) {
          if (_bobPanning) {
            final rb = context.findRenderObject() as RenderBox?;
            if (rb != null) {
              final local = rb.globalToLocal(details.globalPosition);
              _bobDragTo(width, height, local);
            }
          }
        },
        onPanEnd: (_) => _bobPanning = false,
        onPanCancel: () => _bobPanning = false,
        child: CustomPaint(
          foregroundPainter: MetronomeWandPainter(
            width: width,
            height: height,
            tempo: _tempo,
            minTempo: _minTempo,
            maxTempo: _maxTempo,
            rotationAngle: _rotationAngle,
          ),
          child: const InkWell(),
        ),
      ),
    );
  }

  bool _bobHitTest(double width, double height, Offset localPosition) {
    if (_metronomeState != MetronomeState.stopped) return false;
    final translated = localPosition.translate(-width / 2, -height * 0.75);
    final wc = WandCoords(width, height, _tempo, _minTempo, _maxTempo);
    return (translated.dy - wc.bobCenter.dy).abs() < height / 20;
  }

  void _bobDragTo(double width, double height, Offset localPosition) {
    final translated = localPosition.translate(-width / 2, -height * 0.75);
    final wc = WandCoords(width, height, _tempo, _minTempo, _maxTempo);
    final bobPercent = (translated.dy - wc.bobMinY) / wc.bobTravel;
    _tempo = min(_maxTempo,
        max(_minTempo, _minTempo + (bobPercent * (_maxTempo - _minTempo)).toInt()));
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

  WandCoords(double width, double height, int tempo, int minTempo, int maxTempo) {
    rotationCenter = const Offset(0, 0);
    rotationCenterRadius = width / 40;
    counterWeightCenter = Offset(0, height * 0.175);
    counterWeightRadius = width / 12;
    stickTop = Offset(0, -height * 0.68);
    stickBottom = Offset(0, height * 0.175);
    final bobHeight = height / 15;
    bobMinY = stickTop.dy;
    bobMaxY = rotationCenter.dy - rotationCenterRadius - bobHeight / 2 - 2;
    bobTravel = bobMaxY - bobMinY;
    final bobPercent = (tempo - minTempo) / (maxTempo - minTempo);
    bobCenter = Offset(0, bobMinY + (bobTravel * bobPercent));
  }
}

class MetronomeWandPainter extends CustomPainter {
  final double width;
  final double height;
  final int tempo;
  final int minTempo;
  final int maxTempo;
  final double rotationAngle;

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
    paints = {};
  }

  void _initPaints() {
    const ink = Color(0xFF1E1E1E);
    paints = {
      'strokeBase': Paint()
        ..color = ink
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * 0.012,
      'fillCounterWeight': Paint()
        ..color = ink
        ..style = PaintingStyle.fill,
      'fillRotationCenter': Paint()
        ..color = ink
        ..style = PaintingStyle.fill,
      'fillBob': Paint()
        ..color = ink
        ..style = PaintingStyle.fill,
    };
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (paints.isEmpty) _initPaints();
    if (wandPicture == null) {
      final recorder = ui.PictureRecorder();
      _drawWandOnCanvas(Canvas(recorder));
      wandPicture = recorder.endRecording();
    }
    canvas.translate(width / 2, height * .75);
    canvas.rotate(rotationAngle);
    if (wandPicture != null) canvas.drawPicture(wandPicture!);
  }

  void _drawWandOnCanvas(Canvas canvas) {
    final wc = WandCoords(width, height, tempo, minTempo, maxTempo);
    final bobPoints = [
      Offset(wc.bobCenter.dx + width / 8, wc.bobCenter.dy + height / 20),
      Offset(wc.bobCenter.dx - width / 8, wc.bobCenter.dy + height / 20),
      Offset(wc.bobCenter.dx - width / 6, wc.bobCenter.dy - height / 20),
      Offset(wc.bobCenter.dx + width / 6, wc.bobCenter.dy - height / 20),
    ];
    final bobPath = Path()..addPolygon(bobPoints, true);

    final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
      textDirection: TextDirection.ltr,
      fontSize: width / 15,
      textAlign: TextAlign.left,
    ))
      ..pushStyle(ui.TextStyle(color: _bobTextColor))
      ..addText('$tempo');
    final paragraph = pb.build()
      ..layout(ui.ParagraphConstraints(width: width / 4));
    final paragraphPos = Offset(
      wc.bobCenter.dx - paragraph.maxIntrinsicWidth / 2,
      wc.bobCenter.dy - paragraph.height / 2,
    );

    canvas.drawLine(wc.stickTop, wc.stickBottom, paints['strokeBase']!);
    canvas.drawCircle(
        wc.rotationCenter, wc.rotationCenterRadius, paints['fillRotationCenter']!);
    canvas.drawCircle(
        wc.counterWeightCenter, wc.counterWeightRadius, paints['fillCounterWeight']!);
    canvas.drawCircle(
        wc.counterWeightCenter, wc.counterWeightRadius, paints['strokeBase']!);
    canvas.drawPath(bobPath, paints['fillBob']!);
    canvas.drawPath(bobPath, paints['strokeBase']!);
    canvas.drawParagraph(paragraph, paragraphPos);
  }

  @override
  bool shouldRepaint(MetronomeWandPainter old) {
    if (old.tempo != tempo) wandPicture = null;
    return old.rotationAngle != rotationAngle || old.tempo != tempo;
  }
}
