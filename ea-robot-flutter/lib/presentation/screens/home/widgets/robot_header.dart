import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/robot_provider.dart';
import '../../../providers/network_status_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../../domain/entities/robot.dart';
import '../../../../data/api/command_queue.dart';
import '../../monitor/command_monitor_screen.dart';

class RobotHeader extends ConsumerWidget {
  final AsyncValue<Robot> status;
  final AsyncValue<Robot> telemetry;

  const RobotHeader({
    super.key, 
    required this.status,
    required this.telemetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connected = telemetry.value?.connected ?? status.value?.connected ?? false;
    final networkState = ref.watch(networkStatusProvider);
    final queueLength = ref.watch(commandQueueProvider).length;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
                onPressed: () {
                  ref.read(themeModeProvider.notifier).toggle();
                },
              ),
              IconButton(
                icon: Badge(
                  label: Text(queueLength.toString()),
                  isLabelVisible: queueLength > 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: (isDarkMode ? Colors.white10 : Colors.black12)),
                    ),
                    child: Icon(
                      Icons.hub_outlined,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                      size: 20,
                    ),
                  ),
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CommandMonitorScreen()),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildConnectionBadge(connected, networkState),
              const SizedBox(width: 8),
              if (connected)
                IconButton(
                  tooltip: 'Safe Disconnect',
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
                    ),
                    child: const Icon(
                      Icons.logout,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                  ),
                  onPressed: () => ref.read(robotStatusProvider.notifier).disconnect(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionBadge(bool connected, NetworkState networkState) {
    final isFailed = networkState.status == NetworkStatus.failed;
    final isRetrying = networkState.status == NetworkStatus.retrying;
    final isOnline = connected && !isFailed && !isRetrying;
    
    final Color badgeColor = isOnline 
        ? Colors.greenAccent 
        : (isRetrying ? Colors.orangeAccent : Colors.redAccent);
    final String badgeText = isOnline 
        ? 'ONLINE' 
        : (isRetrying ? 'RECONNECTING' : 'OFFLINE');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOnline ? Colors.greenAccent : (isRetrying ? Colors.orangeAccent : Colors.redAccent),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            badgeText,
            style: TextStyle(
              color: badgeColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
