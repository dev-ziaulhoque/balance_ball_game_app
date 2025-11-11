class GameConfig {
  final Map<String, int> scoring;
  final Map<String, DifficultyConfig> difficulties;
  final CelebrationConfig celebration;

  GameConfig({
    required this.scoring,
    required this.difficulties,
    required this.celebration,
  });

  factory GameConfig.defaultConfig() {
    return GameConfig(
      scoring: {
        'outer': 5,
        'middle': 10,
        'inner': 15,
      },
      difficulties: {
        'easy': DifficultyConfig(
          duration: 30,
          windForce: 0,
          windEvents: [],
          userCanDisableWind: false,
        ),
        'medium': DifficultyConfig(
          duration: 60,
          windForce: 300,
          windEvents: [
            [8, 5],
            [22, 6],
            [40, 6],
          ],
          userCanDisableWind: true,
        ),
        'hard': DifficultyConfig(
          duration: 90,
          windForce: 380,
          windEvents: [
            [6, 6],
            [18, 7],
            [36, 8],
            [58, 8],
          ],
          userCanDisableWind: true,
        ),
      },
      celebration: CelebrationConfig(
        enabled: true,
        particles: 200,
        durationMs: 1800,
      ),
    );
  }
}

class DifficultyConfig {
  final int duration;
  final double windForce;
  final List<List<int>> windEvents;
  final bool userCanDisableWind;

  DifficultyConfig({
    required this.duration,
    required this.windForce,
    required this.windEvents,
    required this.userCanDisableWind,
  });
}

class CelebrationConfig {
  final bool enabled;
  final int particles;
  final int durationMs;

  CelebrationConfig({
    required this.enabled,
    required this.particles,
    required this.durationMs,
  });
}