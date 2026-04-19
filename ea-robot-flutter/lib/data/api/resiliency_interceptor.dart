import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/network_status_provider.dart';
import './command_queue.dart';

typedef ReadNetworkStatusNotifier = NetworkStatusNotifier Function();

class ResiliencyInterceptor extends Interceptor {
  final ReadNetworkStatusNotifier readNotifier;
  final Dio? retryDio;
  final Random _random = Random();

  ResiliencyInterceptor(this.readNotifier, {this.retryDio});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Log all robot actions clearly
    print('[ACTION] Sending ${options.method} request to ${options.path}...');

    // Simulate intermittent connection lag
    if (_random.nextDouble() < 0.2) { // 20% chance of extra lag
      final lag = _random.nextInt(2000) + 1000; // 1-3 seconds
      await Future.delayed(Duration(milliseconds: lag));
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // On any success, clear this specific path from the failure list
    readNotifier().reset(response.requestOptions.path);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    int retries = err.requestOptions.extra['retries'] ?? 0;

    if (_shouldRetry(err) && retries < 3) {
      retries++;
      err.requestOptions.extra['retries'] = retries;
      
      final delay = pow(2, retries) * 500; // Exponential backoff
      print('[RESILIENCY] Retrying request (${retries}/3) in ${delay}ms: ${err.requestOptions.path}');
      
      readNotifier().setRetrying(err.requestOptions.path);

      await Future.delayed(Duration(milliseconds: delay.toInt()));
      
      try {
        final dio = retryDio ?? Dio(err.requestOptions.baseUrl != '' ? BaseOptions(baseUrl: err.requestOptions.baseUrl) : null);
        final response = await dio.fetch(err.requestOptions);
        
        // Success! Clear this path
        readNotifier().reset(err.requestOptions.path);
        return handler.resolve(response);
      } catch (e) {
        print('[RESILIENCY] Retry exactly failed because: $e');
        if (e is DioException) {
          return onError(e, handler);
        }
        return handler.next(err);
      }
    } else if (retries >= 3) {
      print('[RESILIENCY] Request failed permanently after 3 retries.');
      readNotifier().setFailed(err.requestOptions.path);
    }

    super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError ||
           err.type == DioExceptionType.unknown ||
           (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}
