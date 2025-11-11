import 'package:flutter/material.dart';
import 'orientation_gate_screen.dart';
import 'main_menu_screen.dart';
import 'gameplay_screen.dart';
import 'results_screen.dart';
import '../models/game_config.dart';

enum GameState {
  orientationCheck,
  mainMenu,
  countdown,
  playing,
  paused,
  results,
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameState _currentState = GameState.orientationCheck;
  String _selectedDifficulty = 'easy';
  bool _windEnabled = true;
  int _finalScore = 0;
  final GameConfig _config = GameConfig.defaultConfig();

  void _onOrientationCorrect() {
    setState(() {
      _currentState = GameState.mainMenu;
    });
  }

  void _onStartGame(String difficulty, bool windEnabled) {
    setState(() {
      _selectedDifficulty = difficulty;
      _windEnabled = windEnabled;
      _currentState = GameState.countdown;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentState = GameState.playing;
        });
      }
    });
  }

  void _onGameEnd(int score, bool timeUp) {
    setState(() {
      _finalScore = score;
      _currentState = GameState.results;
    });
  }

  void _onPause() {
    setState(() {
      _currentState = GameState.paused;
    });
  }

  void _onResume() {
    setState(() {
      _currentState = GameState.playing;
    });
  }

  void _onContinue() {
    setState(() {
      _currentState = GameState.mainMenu;
      _finalScore = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[300],
      body: SafeArea(
        child: _buildCurrentScreen(),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentState) {
      case GameState.orientationCheck:
        return OrientationGateScreen(
          onOrientationCorrect: _onOrientationCorrect,
        );

      case GameState.mainMenu:
        return MainMenuScreen(
          config: _config,
          onStartGame: _onStartGame,
        );

      case GameState.countdown:
        return _buildCountdown();

      case GameState.playing:
      case GameState.paused:
        return GameplayScreen(
          difficulty: _selectedDifficulty,
          windEnabled: _windEnabled,
          config: _config,
          isPaused: _currentState == GameState.paused,
          onPause: _onPause,
          onResume: _onResume,
          onGameEnd: _onGameEnd,
        );

      case GameState.results:
        return ResultsScreen(
          score: _finalScore,
          onContinue: _onContinue,
        );
    }
  }

  Widget _buildCountdown() {
    return Center(
      child: TweenAnimationBuilder<int>(
        tween: IntTween(begin: 3, end: 0),
        duration: const Duration(seconds: 3),
        builder: (context, value, child) {
          if (value == 0) return const SizedBox.shrink();
          return Text(
            '$value',
            style: TextStyle(
              fontSize: 120,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          );
        },
      ),
    );
  }
}
