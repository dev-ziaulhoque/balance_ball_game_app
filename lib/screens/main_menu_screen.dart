import 'package:flutter/material.dart';
import '../models/game_config.dart';

class MainMenuScreen extends StatefulWidget {
  final GameConfig config;
  final Function(String difficulty, bool windEnabled) onStartGame;

  const MainMenuScreen({
    super.key,
    required this.config,
    required this.onStartGame,
  });

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  String _selectedDifficulty = 'easy';
  bool _windEnabled = true;

  @override
  Widget build(BuildContext context) {
    final diffConfig = widget.config.difficulties[_selectedDifficulty]!;
    final showWindToggle = diffConfig.userCanDisableWind;

    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Balance Ball',
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.95),
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Text(
              'Select Difficulty',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDifficultyButton('easy', 'Easy'),
                const SizedBox(width: 15),
                _buildDifficultyButton('medium', 'Medium'),
                const SizedBox(width: 15),
                _buildDifficultyButton('hard', 'Hard'),
              ],
            ),

            const SizedBox(height: 40),

            if (showWindToggle)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.air, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Wind',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      value: _windEnabled,
                      onChanged: (value) {
                        setState(() {
                          _windEnabled = value;
                        });
                      },
                      activeColor: Colors.white,
                      activeTrackColor: Colors.green[700],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () => widget.onStartGame(_selectedDifficulty, _windEnabled),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
              ),
              child: const Text(
                'START',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(String value, String label) {
    final isSelected = _selectedDifficulty == value;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedDifficulty = value;
          _windEnabled = true;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
        foregroundColor: isSelected ? Colors.green[700] : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: isSelected ? 8 : 2,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 20,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }
}