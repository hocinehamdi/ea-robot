import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/robot_provider.dart';
import '../../../../domain/entities/robot.dart';

class ControlPanel extends ConsumerWidget {
  final AsyncValue<Robot> status;

  const ControlPanel({super.key, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connected = status.value?.connected ?? false;

    return Column(
      children: [
        if (!connected)
          ElevatedButton(
            onPressed: () => ref.read(robotStatusProvider.notifier).connect(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: Colors.blueAccent.withValues(alpha: 0.5),
            ),
            child: const Text(
              'CONNECT',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          )
        else
          _buildDirectionalGrid(context, ref),
      ],
    );
  }

  Widget _buildDirectionalGrid(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_buildDirectionButton(context, ref, 'forward', Icons.arrow_upward)],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDirectionButton(context, ref, 'left', Icons.arrow_back),
            const SizedBox(width: 10),
            _buildDirectionButton(context, ref, 'stop', Icons.stop, isStop: true),
            const SizedBox(width: 10),
            _buildDirectionButton(context, ref, 'right', Icons.arrow_forward),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDirectionButton(context, ref, 'backward', Icons.arrow_downward),
          ],
        ),
      ],
    );
  }

  Widget _buildDirectionButton(
    BuildContext context,
    WidgetRef ref,
    String direction,
    IconData icon, {
    bool isStop = false,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        if (isStop) {
          ref.read(robotStatusProvider.notifier).stop();
        } else {
          ref.read(robotStatusProvider.notifier).move();
        }
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isStop
              ? Colors.redAccent.withValues(alpha: 0.1)
              : (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isStop ? Colors.redAccent.withValues(alpha: 0.5) : (isDarkMode ? Colors.white24 : Colors.black26),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: isStop ? Colors.redAccent : (isDarkMode ? Colors.white : Colors.black),
          size: 30,
        ),
      ),
    );
  }
}
