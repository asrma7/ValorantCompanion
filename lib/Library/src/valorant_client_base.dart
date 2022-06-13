import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:valorant_companion/Library/src/enums.dart';
import 'package:valorant_companion/Library/src/extensions.dart';
import 'constants.dart';

import 'models/serializable.dart';
import 'url_manager.dart';
import 'user_details.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'authentication/rso_handler.dart';

class ValorantClient {
  ValorantClient._privateConstructor();
  static final instance = ValorantClient._privateConstructor();
  static Dio? _client;
  static final Map<String, String> _headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    ClientConstants.clientPlatformHeaderKey:
        ClientConstants.clientPlatformHeaderValue,
    'User-Agent':
        'RiotClient/44.0.1.4223069.4190634 rso-auth (Windows;10;;Professional, x64)',
  };

  Future<Dio> get client async {
    _client ??= await _createClient();
    return _client!;
  }

  Future<Dio> _createClient() async {
    final client = Dio();
    client.options.headers = _headers;
    Directory appDocDir = await getExternalStorageDirectory() as Directory;
    String cookiePath = appDocDir.path;
    final cookieJar = PersistCookieJar(
      storage: FileStorage('$cookiePath/valocompanion/.cookies'),
      persistSession: true,
      ignoreExpires: true,
    );
    await cookieJar.loadForRequest(Uri.parse('https://auth.riotgames.com'));
    client.interceptors.add(CookieManager(cookieJar));
    try {
      await client.post(
        UrlManager.authUrl,
        data: {},
      );
    } on DioError {
      if (kDebugMode) {
        print("First auth request failed");
      }
    }
    return client;
  }

  Future<bool> authenticate(
      String username, String password, Region region) async {
    final client = await instance.client;
    RSOHandler rsoHandler = RSOHandler(
      client: client,
      userDetails: UserDetails(
        userName: username,
        password: password,
        region: region,
      ),
    );
    try {
      return rsoHandler.authenticate();
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  Future<dynamic> executeRawRequest(
      {required HttpMethod method, required Uri uri, dynamic body}) async {
    final client = await instance.client;
    client.options.headers.addAll({
      "Authorization":
          "Bearer ${await const FlutterSecureStorage().read(key: 'accessToken')}",
      "X-Riot-Entitlements-JWT":
          await const FlutterSecureStorage().read(key: 'entitlementsToken'),
      "X-Riot-ClientVersion":
          await const FlutterSecureStorage().read(key: 'clientVersion'),
    });
    Response<dynamic> response;

    if (body == null) {
      response = await client.requestUri(
        uri,
        options: Options(
          contentType: ContentType.json.value,
          responseType: ResponseType.json,
          method: method.humanized.toUpperCase(),
        ),
      );
    } else {
      response = await client.requestUri(
        uri,
        data: body,
        options: Options(
          contentType: ContentType.json.value,
          responseType: ResponseType.json,
          method: method.humanized.toUpperCase(),
        ),
      );
    }

    if (response.statusCode != 200) {
      return null;
    }

    return response.data is String ? jsonDecode(response.data) : response.data;
  }

  Future<T?> executeGenericRequest<T extends ISerializable<T>>(
      {required T typeResolver,
      required HttpMethod method,
      required Uri uri,
      dynamic body}) async {
    final client = await instance.client;
    String? accessToken =
        await const FlutterSecureStorage().read(key: 'accessToken');
    client.options.headers.addAll({
      "Authorization": "Bearer $accessToken",
      "X-Riot-Entitlements-JWT":
          await const FlutterSecureStorage().read(key: 'entitlementsToken'),
      "X-Riot-ClientVersion":
          await const FlutterSecureStorage().read(key: 'clientVersion'),
    });
    Response<dynamic> response;
    try {
      response = await client.requestUri(
        uri,
        data: body,
        options: Options(
          contentType: ContentType.json.value,
          responseType: ResponseType.json,
          method: method.humanized.toUpperCase(),
        ),
      );
    } on DioError catch (e) {
      if (e.response?.statusCode == 400 &&
          e.response?.data['errorCode'] == "BAD_CLAIMS") {
        bool renewSuccess = await RSOHandler(client: client).renewAccessToken();
        if (renewSuccess) {
          String? newAccessToken =
              await const FlutterSecureStorage().read(key: 'accessToken');
          client.options.headers
              .update('Authorization', (value) => "Bearer $newAccessToken");
          response = await client.requestUri(
            uri,
            data: body,
            options: Options(
              contentType: ContentType.json.value,
              responseType: ResponseType.json,
              method: method.humanized.toUpperCase(),
            ),
          );
        } else {
          throw Exception("Failed to renew access token");
        }
      } else {
        rethrow;
      }
    }

    if (response.statusCode != 200) {
      return null;
    }

    return typeResolver.fromJson(
        response.data is String ? jsonDecode(response.data) : response.data);
  }
}
