import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:confetti/confetti.dart';
import '../models/game_config.dart';
import '../widgets/game_painter.dart';

class GameplayScreen extends StatefulWidget {
  final String difficulty;
  final bool windEnabled;
  final GameConfig config;
  final bool isPaused;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final Function(int score, bool timeUp) onGameEnd;

  const GameplayScreen({
    super.key,
    required this.difficulty,
    required this.windEnabled,
    required this.config,
    required this.isPaused,
    required this.onPause,
    required this.onResume,
    required this.onGameEnd,
  });

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ConfettiController _confettiController;

  Offset _ballPosition = Offset.zero;
  Offset _ballVelocity = Offset.zero;

  int _score = 0;
  late int _remainingTime;
  bool _gameEnded = false;

  StreamSubscription<GyroscopeEvent>? _gyroSubscription;

  late DifficultyConfig _diffConfig;
  final double _ballRadius = 15.0;
  final double _friction = 0.95;
  final double _sensitivity = 8.0;

  bool _windActive = false;
  Timer? _windTimer;
  Timer? _gameTimer;

  final double _innerRingRatio = 0.15;
  final double _middleRingRatio = 0.35;
  final double _outerRingRatio = 0.55;

  @override
  void initState() {
    super.initState();

    _diffConfig = widget.config.difficulties[widget.difficulty]!;
    _remainingTime = _diffConfig.duration;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updatePhysics);

    _confettiController = ConfettiController(
      duration: Duration(milliseconds: widget.config.celebration.durationMs),
    );

    _initSensors();
    _startGameTimer();
    _setupWindEvents();

    if (!widget.isPaused) {
      _controller.repeat();
    }
  }

  void _initSensors() {
    _gyroSubscription = gyroscopeEventStream().listen((GyroscopeEvent event) {
      if (!widget.isPaused && !_gameEnded) {
        setState(() {
          _ballVelocity += Offset(event.y * _sensitivity, -event.x * _sensitivity);
        });
      }
    });

    RawKeyboard.instance.addListener(_handleKeyPress);
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent && !widget.isPaused && !_gameEnded) {
      const keyForce = 3.0;
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.keyA) {
        _ballVelocity += const Offset(-keyForce, 0);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        _ballVelocity += const Offset(keyForce, 0);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.keyW) {
        _ballVelocity += const Offset(0, -keyForce);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey == LogicalKeyboardKey.keyS) {
        _ballVelocity += const Offset(0, keyForce);
      }
    }
  }

  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameEnded || widget.isPaused) return;

      setState(() {
        _remainingTime--;
        _updateScore();

        if (_remainingTime <= 0) {
          _endGame(true);
          timer.cancel();
        }
      });
    });
  }

  void _setupWindEvents() {
    if (!widget.windEnabled || _diffConfig.windEvents.isEmpty) return;

    for (var event in _diffConfig.windEvents) {
      final startTime = event[0];
      final duration = event[1];

      Future.delayed(Duration(seconds: startTime), () {
        if (!_gameEnded && mounted) {
          setState(() {
            _windActive = true;
          });

          _windTimer?.cancel();
          _windTimer = Timer(Duration(seconds: duration), () {
            if (mounted) {
              setState(() {
                _windActive = false;
              });
            }
          });
        }
      });
    }
  }

  void _updatePhysics() {
    if (_gameEnded || widget.isPaused) return;

    setState(() {
      if (_windActive) {
        final windDirection = _ballPosition == Offset.zero
            ? const Offset(1, 0)
            : Offset(_ballPosition.dx, _ballPosition.dy);
        final normalizedWind = windDirection / windDirection.distance;
        _ballVelocity += normalizedWind * (_diffConfig.windForce / 100);
      }

      _ballPosition += _ballVelocity;
      _ballVelocity *= _friction;

      _checkBoundaries();
    });
  }

  void _checkBoundaries() {
    final size = MediaQuery.of(context).size;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final maxRadius = min(centerX, centerY) * 0.9;

    final distanceFromCenter = _ballPosition.distance;
    final outerBoundary = maxRadius * _outerRingRatio;

    if (distanceFromCenter > outerBoundary) {
      _endGame(false);
    }
  }

  void _updateScore() {
    final size = MediaQuery.of(context).size;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final maxRadius = min(centerX, centerY) * 0.9;

    final distanceFromCenter = _ballPosition.distance;
    final innerBoundary = maxRadius * _innerRingRatio;
    final middleBoundary = maxRadius * _middleRingRatio;

    int pointsPerSecond = 0;
    if (distanceFromCenter <= innerBoundary) {
      pointsPerSecond = widget.config.scoring['inner']!;
    } else if (distanceFromCenter <= middleBoundary) {
      pointsPerSecond = widget.config.scoring['middle']!;
    } else {
      pointsPerSecond = widget.config.scoring['outer']!;
    }

    _score += pointsPerSecond;
  }

  void _endGame(bool timeUp) {
    if (_gameEnded) return;

    setState(() {
      _gameEnded = true;
    });

    _controller.stop();
    _windTimer?.cancel();
    _gameTimer?.cancel();

    if (timeUp && widget.config.celebration.enabled) {
      _confettiController.play();
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onGameEnd(_score, timeUp);
      });
    } else {
      widget.onGameEnd(_score, timeUp);
    }
  }

  @override
  void didUpdateWidget(GameplayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPaused && !oldWidget.isPaused) {
      _controller.stop();
    } else if (!widget.isPaused && oldWidget.isPaused) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    _gyroSubscription?.cancel();
    _windTimer?.cancel();
    _gameTimer?.cancel();
    RawKeyboard.instance.removeListener(_handleKeyPress);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: widget.config.celebration.particles ~/ 10,
            gravity: 0.1,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ),

        CustomPaint(
          size: size,
          painter: GamePainter(
            ballPosition: _ballPosition,
            ballRadius: _ballRadius,
            innerRingRatio: _innerRingRatio,
            middleRingRatio: _middleRingRatio,
            outerRingRatio: _outerRingRatio,
            windActive: _windActive,
          ),
        ),

        _buildHUD(),

        if (widget.isPaused) _buildPauseOverlay(),
      ],
    );
  }

  Widget _buildHUD() {
    final minutes = _remainingTime ~/ 60;
    final seconds = _remainingTime % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.pause, size: 28),
              onPressed: widget.onPause,
              color: Colors.green[700],
            ),
          ),

          Text(
            timeString,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Score:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                '$_score',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PAUSED',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: widget.onResume,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'RESUME',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}