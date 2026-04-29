import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../../domain/entities/robot.dart';

class RobotIllustration extends ConsumerWidget {
  final AsyncValue<Robot> telemetry;
  final AsyncValue<Robot> status;

  const RobotIllustration({
    super.key,
    required this.telemetry,
    required this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = telemetry.value ?? status.value;
    final connected = current?.connected ?? false;
    final moving = current?.moving ?? false;

    return Container(
      height: 300,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Glow Pulse
            if (connected)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: moving ? 1.2 : 1.0),
                duration: Duration(milliseconds: moving ? 800 : 2000),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Container(
                    width: 200 * value,
                    height: 200 * value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (moving ? Colors.blueAccent : Colors.greenAccent)
                              .withValues(alpha: 0.15),
                          blurRadius: 40 * value,
                          spreadRadius: 20 * value,
                        ),
                      ],
                    ),
                  );
                },
              ),

            // Main Robot Animation
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: Lottie.asset(
                !connected
                    ? 'assets/animations/RobotWelcome.json'
                    : (moving
                        ? 'assets/animations/Robot-Animation-Moving.json'
                        : 'assets/animations/Robot-Animation-Idle.json'),
                key: ValueKey(!connected ? 'welcome' : (moving ? 'moving' : 'idle')),
                width: !connected ? 280 : 250,
                height: !connected ? 280 : 250,
                fit: BoxFit.contain,
                animate: true,
                repeat: true,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.android_rounded,
                  size: 100,
                  color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withValues(alpha: 0.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
