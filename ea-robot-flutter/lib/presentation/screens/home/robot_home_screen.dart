import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/robot_provider.dart';
import '../../providers/network_status_provider.dart';
import '../../../data/api/command_processor.dart';
import 'widgets/robot_header.dart';
import 'widgets/robot_illustration.dart';
import 'widgets/telemetry_card.dart';
import 'widgets/control_panel.dart';

class RobotHomeScreen extends ConsumerWidget {
  const RobotHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure the background command processor is active
    ref.read(commandProcessorProvider);

    final status = ref.watch(robotStatusProvider);
    final telemetry = ref.watch(robotTelemetryProvider);
    final connected = status.value?.connected ?? false;

    ref.listen(networkStatusProvider, (previous, next) {
      if (next.status == NetworkStatus.retrying) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Intermittent Signal... Retrying command on route ${next.lastPath}'),
            backgroundColor: Colors.orangeAccent,
            duration: const Duration(seconds: 1),
          ),
        );
      } else if (next.status == NetworkStatus.failed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Critical Error: Connectivity lost on route ${next.lastPath} after multiple retries.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              RobotHeader(status: status),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      RobotIllustration(telemetry: telemetry, status: status),
                      if (connected) ...[
                        TelemetryCard(telemetry: telemetry, status: status),
                        const SizedBox(height: 20),
                      ],
                      ControlPanel(status: status),
                      const SizedBox(height: 40),
                    ],
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
