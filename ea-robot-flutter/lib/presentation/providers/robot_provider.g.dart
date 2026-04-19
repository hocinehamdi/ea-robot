// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'robot_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dio)
final dioProvider = DioProvider._();

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'fa100101e3c9b9f43329ac6fd2b59e1c6d94c94a';

@ProviderFor(robotRepository)
final robotRepositoryProvider = RobotRepositoryProvider._();

final class RobotRepositoryProvider
    extends
        $FunctionalProvider<RobotRepository, RobotRepository, RobotRepository>
    with $Provider<RobotRepository> {
  RobotRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'robotRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$robotRepositoryHash();

  @$internal
  @override
  $ProviderElement<RobotRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RobotRepository create(Ref ref) {
    return robotRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RobotRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RobotRepository>(value),
    );
  }
}

String _$robotRepositoryHash() => r'288c5193ba28da2bfa42ed50e05b1afbaa438225';

@ProviderFor(robotTelemetry)
final robotTelemetryProvider = RobotTelemetryProvider._();

final class RobotTelemetryProvider
    extends $FunctionalProvider<AsyncValue<Robot>, Robot, Stream<Robot>>
    with $FutureModifier<Robot>, $StreamProvider<Robot> {
  RobotTelemetryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'robotTelemetryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$robotTelemetryHash();

  @$internal
  @override
  $StreamProviderElement<Robot> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Robot> create(Ref ref) {
    return robotTelemetry(ref);
  }
}

String _$robotTelemetryHash() => r'72be761de6e5ad589029c4f8884d92b6aeeeb34e';

@ProviderFor(RobotStatus)
final robotStatusProvider = RobotStatusProvider._();

final class RobotStatusProvider
    extends $AsyncNotifierProvider<RobotStatus, Robot> {
  RobotStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'robotStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$robotStatusHash();

  @$internal
  @override
  RobotStatus create() => RobotStatus();
}

String _$robotStatusHash() => r'7bd0907e4ce74e89ccc9337f6086af4705930cdf';

abstract class _$RobotStatus extends $AsyncNotifier<Robot> {
  FutureOr<Robot> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Robot>, Robot>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Robot>, Robot>,
              AsyncValue<Robot>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
