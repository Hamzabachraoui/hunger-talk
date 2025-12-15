import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:hunger_talk/core/config/app_config.dart';
import 'package:hunger_talk/data/services/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    AppConfig.setBaseUrlForTesting('http://example.com');
  });

  test('POST sur une route racine ajoute un trailing slash', () async {
    Uri? capturedUrl;

    final api = ApiService(
      client: MockClient((request) async {
        capturedUrl = request.url;
        return http.Response(
          '{"ok": true}',
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    await api.post('/stock', {'name': 'riz'}, requiresAuth: false);

    expect(capturedUrl, isNotNull);
    expect(
      capturedUrl.toString(),
      equals('http://example.com/api/stock/'),
    );
  });

  test('GET conserve le chemin sans doublon de slash', () async {
    Uri? capturedUrl;

    final api = ApiService(
      client: MockClient((request) async {
        capturedUrl = request.url;
        return http.Response(
          '[]',
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    await api.get('/stock/123', requiresAuth: false);

    expect(capturedUrl, isNotNull);
    expect(
      capturedUrl.toString(),
      equals('http://example.com/api/stock/123'),
    );
  });
}

