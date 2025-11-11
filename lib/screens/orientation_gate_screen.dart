import 'package:flutter/material.dart';

class OrientationGateScreen extends StatefulWidget {
  final VoidCallback onOrientationCorrect;

  const OrientationGateScreen({
    super.key,
    required this.onOrientationCorrect,
  });

  @override
  State<OrientationGateScreen> createState() => _OrientationGateScreenState();
}

class _OrientationGateScreenState extends State<OrientationGateScreen> {
  @override
  void initState() {
    super.initState();
    _checkOrientation();
  }

  void _checkOrientation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      if (size.width > size.height) {
        widget.onOrientationCorrect();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.lightGreen[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.screen_rotation,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 30),
            Text(
              'Please rotate your device\nto landscape',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}