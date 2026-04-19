import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ea_robot/data/api/resiliency_interceptor.dart';
import 'package:ea_robot/presentation/providers/network_status_provider.dart';

class MockHttpClientAdapter extends Mock implements HttpClientAdapter {}
class MockNetworkStatusNotifier extends Mock implements NetworkStatusNotifier {}

class FakeRequestOptions extends Fake implements RequestOptions {}

void main() {
  late Dio dio;
  late MockHttpClientAdapter mockAdapter;
  late MockNetworkStatusNotifier mockNotifier;

  setUpAll(() {
    registerFallbackValue(FakeRequestOptions());
  });

  setUp(() {
    dio = Dio();
    mockAdapter = MockHttpClientAdapter();
    mockNotifier = MockNetworkStatusNotifier();

    // Setup default mock behaviors for the notifier
    when(() => mockNotifier.reset(any())).thenAnswer((_) async => {});
    when(() => mockNotifier.setRetrying(any())).thenAnswer((_) async => {});
    when(() => mockNotifier.setFailed(any())).thenAnswer((_) async => {});

    dio.httpClientAdapter = mockAdapter;
    // Speed up tests by setting custom dio with no real latency/delays if needed, 
    // but the interceptor has its own delays.
    dio.interceptors.add(ResiliencyInterceptor(() => mockNotifier, retryDio: dio));
  });

  group('ResiliencyInterceptor Detailed Tests', () {
    test('should retry on 500 error and eventually succeed', () async {
      int callCount = 0;

      when(() => mockAdapter.fetch(any(), any(), any())).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) return ResponseBody.fromBytes([], 500);
        return ResponseBody.fromBytes([], 200);
      });

      final response = await dio.get('/test');

      expect(response.statusCode, 200);
      expect(callCount, 2);
      verify(() => mockNotifier.setRetrying('/test')).called(1);
      // reset() is called exactly once by onResponse
      verify(() => mockNotifier.reset('/test')).called(1);
    });

    test('should fail and notify UI after 3 retries', () async {
      when(() => mockAdapter.fetch(any(), any(), any())).thenAnswer((_) async {
        return ResponseBody.fromBytes([], 500);
      });

      try {
        await dio.get('/fail-endpoint');
      } catch (_) {}

      verify(() => mockNotifier.setRetrying('/fail-endpoint')).called(3);
      // Verify it was called at least once
      verify(() => mockNotifier.setFailed('/fail-endpoint')).called(4);
    });

    test('should retry on Connection Timeout', () async {
      int callCount = 0;
      when(() => mockAdapter.fetch(any(), any(), any())).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
           throw DioException(
             requestOptions: RequestOptions(path: '/timeout'),
             type: DioExceptionType.connectionTimeout,
           );
        }
        return ResponseBody.fromBytes([], 200);
      });

      final response = await dio.get('/timeout');
      expect(response.statusCode, 200);
      expect(callCount, 2);
      verify(() => mockNotifier.reset('/timeout')).called(1);
    });

    test('should NOT retry on specialized 401 Unauthorized', () async {
      int callCount = 0;
      when(() => mockAdapter.fetch(any(), any(), any())).thenAnswer((_) async {
        callCount++;
        return ResponseBody.fromBytes([], 401);
      });

      try {
        await dio.get('/secure');
      } catch (_) {}

      expect(callCount, 1);
      verifyNever(() => mockNotifier.setRetrying(any()));
    });

    test('should reset state on direct success', () async {
      when(() => mockAdapter.fetch(any(), any(), any())).thenAnswer((_) async {
        return ResponseBody.fromBytes([], 200);
      });

      await dio.get('/smooth');
      
      verify(() => mockNotifier.reset('/smooth')).called(1);
    });
  });
}
