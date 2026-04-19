import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ea_robot/data/api/resiliency_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    dio.httpClientAdapter = mockAdapter;
    // Pass the same dio instance (or another one with the same mock adapter) to the interceptor
    dio.interceptors.add(ResiliencyInterceptor(() => mockNotifier, retryDio: dio));
  });

  group('ResiliencyInterceptor', () {
    test('should retry on 500 error and eventually succeed', () async {
      int callCount = 0;

      when(() => mockAdapter.fetch(any(), any(), any())).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          // First call fails with 500
          return ResponseBody.fromBytes([], 500);
        }
        // Second call succeeds
        return ResponseBody.fromBytes([], 200);
      });

      final response = await dio.get('/test');

      expect(response.statusCode, 200);
      expect(callCount, 2);
    });

    test('should fail after max retries (3)', () async {
      int callCount = 0;

      when(() => mockAdapter.fetch(any(), any(), any())).thenAnswer((_) async {
        callCount++;
        return ResponseBody.fromBytes([], 500);
      });

      try {
        await dio.get('/test');
      } catch (e) {
        expect(e, isA<DioException>());
        final dioErr = e as DioException;
        expect(dioErr.response?.statusCode, 500);
      }

      // Initial call + 3 retries = 4
      expect(callCount, 4);
    });

    test('should not retry on 404 error', () async {
      int callCount = 0;

      when(() => mockAdapter.fetch(any(), any(), any())).thenAnswer((_) async {
        callCount++;
        return ResponseBody.fromBytes([], 404);
      });

      try {
        await dio.get('/test');
      } catch (e) {
        expect(e, isA<DioException>());
      }

      // Current logic: only 500+ or timeouts are retried
      expect(callCount, 1);
    });
  });
}
