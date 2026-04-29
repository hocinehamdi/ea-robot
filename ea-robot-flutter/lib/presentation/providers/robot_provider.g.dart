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

String _$dioHash() => r'f126317aeb3151bb42619e504333f406e28158e4';

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

String _$robotRepositoryHash() => r'0b38241ac670496f21b476544eed0112f6ab61c3';

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

String _$robotTelemetryHash() => r'cecb6594190c21b4eaa6c132f307732e14a5e268';

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

String _$robotStatusHash() => r'9337a24ca61bc274f9ca1ef46208ddef3fa844a7';

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
