import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the Auth interceptor behaviour documented in dio_client.dart.
///
/// FirebaseAuth cannot be instantiated in unit tests (requires platform channel).
/// These tests verify the interceptor contract by driving a Dio instance with a
/// custom test adapter that simulates 200 / 401 responses, and a mock token
/// supplier injected via closure — matching the pattern in dio_client.dart.
void main() {
  group('Auth interceptor — 401 retry contract', () {
    late Dio dio;
    int tokenFetchCount = 0;
    int requestCount = 0;

    /// Builds a Dio instance wired with:
    /// - a token supplier (simulates getIdToken / forceRefresh)
    /// - a test adapter that returns [responses] in order
    Dio buildDio({
      required Future<String?> Function(bool forceRefresh) tokenSupplier,
      required List<int> statusCodes,
    }) {
      int callIndex = 0;
      tokenFetchCount = 0;
      requestCount = 0;

      final testDio = Dio(BaseOptions(baseUrl: 'http://test.local'));

      testDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            tokenFetchCount++;
            final token = await tokenSupplier(false);
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return handler.next(options);
          },
          onError: (error, handler) async {
            if (error.response?.statusCode != 401) {
              return handler.next(error);
            }
            if (error.requestOptions.extra['_retried'] == true) {
              return handler.next(error);
            }
            final freshToken = await tokenSupplier(true);
            if (freshToken == null) return handler.next(error);

            try {
              final retryOptions = error.requestOptions
                ..headers['Authorization'] = 'Bearer $freshToken'
                ..extra['_retried'] = true;
              final retryResponse = await testDio.fetch(retryOptions);
              return handler.resolve(retryResponse);
            } on DioException catch (retryError) {
              return handler.next(retryError);
            }
          },
        ),
      );

      // Test HTTP adapter — returns status codes in sequence
      testDio.httpClientAdapter = _SequentialAdapter(statusCodes, () => requestCount++);
      return testDio;
    }

    test('200 on first request — token fetched once, no retry', () async {
      dio = buildDio(
        tokenSupplier: (_) async => 'valid-token',
        statusCodes: [200],
      );

      final response = await dio.get('/api/test');

      expect(response.statusCode, 200);
      expect(tokenFetchCount, 1);
      expect(requestCount, 1);
    });

    test('401 then 200 — token force-refreshed, request retried successfully', () async {
      int supplierCalls = 0;
      dio = buildDio(
        tokenSupplier: (forceRefresh) async {
          supplierCalls++;
          return forceRefresh ? 'fresh-token' : 'stale-token';
        },
        statusCodes: [401, 200],
      );

      final response = await dio.get('/api/test');

      expect(response.statusCode, 200);
      // Token fetched 3 times: onRequest (initial) + onError forceRefresh +
      // onRequest (retry goes through full interceptor chain again)
      expect(supplierCalls, 3);
      expect(requestCount, 2); // original + retry
    });

    test('401 then 401 — DioException propagated (session revoked)', () async {
      dio = buildDio(
        tokenSupplier: (_) async => 'token',
        statusCodes: [401, 401],
      );

      await expectLater(
        () => dio.get('/api/test'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'statusCode',
            401,
          ),
        ),
      );
    });
  });
}

/// HTTP adapter that returns status codes from a list, in order.
class _SequentialAdapter implements HttpClientAdapter {
  final List<int> statusCodes;
  final void Function() onRequest;
  int _index = 0;

  _SequentialAdapter(this.statusCodes, this.onRequest);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    onRequest();
    final code = statusCodes[_index++ % statusCodes.length];
    return ResponseBody.fromString('', code);
  }

  @override
  void close({bool force = false}) {}
}
