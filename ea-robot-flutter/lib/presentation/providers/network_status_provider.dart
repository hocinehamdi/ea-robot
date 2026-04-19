import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NetworkStatus { idle, retrying, failed }

class NetworkState {
  final NetworkStatus status;
  final Set<String> failingPaths;
  final String? lastPath;

  const NetworkState({
    this.status = NetworkStatus.idle,
    this.failingPaths = const {},
    this.lastPath,
  });

  bool get isOffline => failingPaths.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          failingPaths.length == other.failingPaths.length &&
          lastPath == other.lastPath;

  @override
  int get hashCode => status.hashCode ^ failingPaths.hashCode ^ lastPath.hashCode;
}

class NetworkStatusNotifier extends Notifier<NetworkState> {
  @override
  NetworkState build() => const NetworkState();

  void setRetrying(String path) {
    state = NetworkState(
      status: NetworkStatus.retrying,
      failingPaths: state.failingPaths,
      lastPath: path,
    );
  }

  void setFailed(String path) {
    final newPaths = Set<String>.from(state.failingPaths)..add(path);
    state = NetworkState(
      status: NetworkStatus.failed,
      failingPaths: newPaths,
      lastPath: path,
    );
  }

  void reset(String path) {
    final newPaths = Set<String>.from(state.failingPaths)..remove(path);
    state = NetworkState(
      status: newPaths.isEmpty ? NetworkStatus.idle : NetworkStatus.failed,
      failingPaths: newPaths,
      lastPath: path,
    );
  }

  void clearAll() => state = const NetworkState();
}

final networkStatusProvider = NotifierProvider<NetworkStatusNotifier, NetworkState>(() {
  return NetworkStatusNotifier();
});
