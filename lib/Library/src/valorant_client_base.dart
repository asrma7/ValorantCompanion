import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'constants.dart';
import 'interfaces/match.dart';

import 'callback.dart';
import 'enums.dart';
import 'extensions.dart';
import 'interfaces/asset.dart';
import 'interfaces/player.dart';
import 'models/serializable.dart';
import 'url_manager.dart';
import 'user_details.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'authentication/rso_handler.dart';

class ValorantClient {
  late final Dio _client = Dio();
  late CookieJar _cookieJar = CookieJar();
  late final RSOHandler _rsoHandler = RSOHandler(_client, _userDetails);

  final UserDetails _userDetails;
  final bool shouldPersistSession;

  /// [Callback]'s are containers for functions which are called on an event such as on an error during a request process etc. They help to know what error occured and where it occured.
  ///
  /// To register a callback, simply pass [Callback] instance with required parameters to this instance constructor.
  final Callback callback;

  bool _isInitialized = false;

  /// PUUID of the logged in User
  String get userPuuid => _rsoHandler._userPuuid;

  /// Region of logged in User
  Region get userRegion => _userDetails.region;

  /// Returns true only if this instance is authorized and completed its startup process
  bool get isInitialized => _isInitialized;

  /// The validity period of this authenticated session.
  ///
  /// After [sessionValidityInHours] period, current authorized session will be invalid and you will need to authorize with riot api again.
  ///

  /// Gets the headers which helps to authorize a request to RIOT Valorant API.
  ///
  /// Use this to send custom requests with authorization.
  ///
  /// You will get Empty Map if [isInitialized] is false or authorization failed internally.
  Map<String, dynamic> get getAuthorizationHeaders => _rsoHandler._authHeaders;

  /// This interface wraps over all player specific requests.
  ///
  /// Endpoints are loaded lazily. That means, they are only initilized when they are referenced the first time of their usage.
  ///
  /// ie, If you never reference [assetInterface] in your project, it won't be loaded onto memory and as a matter of fact, memory will be saved.
  late PlayerInterface playerInterface = PlayerInterface(this);

  /// This interface wraps over all riot asset specific requests.
  ///
  /// Endpoints are loaded lazily. That means, they are only initilized when they are referenced the first time of their usage.
  ///
  /// ie, If you never reference [assetInterface] in your project, it won't be loaded onto memory and as a matter of fact, memory will be saved.
  late AssetInterface assetInterface = AssetInterface(this);

  /// This interface wraps over all match specific requests.
  ///
  /// Endpoints are loaded lazily. That means, they are only initilized when they are referenced the first time of their usage.
  ///
  /// ie, If you never reference [assetInterface] in your project, it won't be loaded onto memory and as a matter of fact, memory will be saved.
  late MatchInterface matchInterface = MatchInterface(this);

  /// Default constructor of [ValorantClient]
  ///
  /// [_userDetails] parameter must contain a valid Username and Password else login will fail.
  ///
  /// [callback] is optional. Pass a Callback instance to this for events on request error or internal error.
  ///
  ValorantClient(this._userDetails,
      {this.callback = const Callback(), this.shouldPersistSession = false});

  /// Initializes the client by authorizing the user with the constructor supplied [UserDetails]
  ///
  /// Must be called on every instance of [ValorantClient] to send authorized requests from the instance.
  Future<bool> init() async {
    _cookieJar = shouldPersistSession ? PersistCookieJar() : CookieJar();
    _client.interceptors.add(CookieManager(_cookieJar));
    if (await _isLoggedIn() && await _isTokenValid()) {
      Map<String, dynamic> _authHeaders = {
        "Content-Type": "application/json",
        "authorization":
            "Bearer ${await const FlutterSecureStorage().read(key: 'accessToken')}",
        "X-Riot-Entitlements-JWT":
            await const FlutterSecureStorage().read(key: 'entitlementsToken'),
        "X-Riot-ClientVersion":
            await const FlutterSecureStorage().read(key: 'clientVersion'),
        ClientConstants.clientPlatformHeaderKey:
            ClientConstants.clientPlatformHeaderValue,
      };
      _client.options.headers.addAll(_authHeaders);
      String? puuid = await const FlutterSecureStorage().read(key: 'userPuuid');
      if (puuid != null) {
        _rsoHandler._userPuuid = puuid;
      }
      _isInitialized = true;
      return true;
    }

    if (!await _rsoHandler.authenticate()) {
      callback.invokeErrorCallback('Authentication Failed.');
      return false;
    }

    return _isInitialized = true;
  }

  /// Executes a raw request with authentication to the specified [Uri] with specified [HttpMethod] and with the specified body (if any)
  ///
  /// returns a [Map] of response data if the request is a success.
  Future<dynamic> executeRawRequest(
      {required HttpMethod method, required Uri uri, dynamic body}) async {
    if (!_isInitialized) {
      callback.invokeErrorCallback(
          'Client is not initialized yet. Try calling init()');
      return null;
    }

    try {
      Response<dynamic> response;

      if (body == null) {
        response = await _client.requestUri(
          uri,
          options: Options(
            contentType: ContentType.json.value,
            responseType: ResponseType.json,
            method: method.humanized.toUpperCase(),
          ),
        );
      } else {
        response = await _client.requestUri(
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

      return response.data is String
          ? jsonDecode(response.data)
          : response.data;
    } on DioError catch (e) {
      callback.invokeRequestErrorCallback(e);
      return null;
    }
  }

  /// Executes a generic request with authentication to the specified [Uri] with specified [HttpMethod] and with the specified body (if any)
  ///
  /// returns response data as [T] type which is specified as a generic type parameter to the function.
  Future<T?> executeGenericRequest<T extends ISerializable<T>>(
      {required T typeResolver,
      required HttpMethod method,
      required Uri uri,
      dynamic body}) async {
    if (!_isInitialized) {
      callback.invokeErrorCallback(
          'Client is not initialized yet. Try calling init()');
      return null;
    }

    try {
      Response<dynamic> response;

      if (body == null) {
        response = await _client.requestUri(
          uri,
          options: Options(
            contentType: ContentType.json.value,
            responseType: ResponseType.json,
            method: method.humanized.toUpperCase(),
          ),
        );
      } else {
        response = await _client.requestUri(
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

      return typeResolver.fromJson(
          response.data is String ? jsonDecode(response.data) : response.data);
    } on DioError catch (e) {
      callback.invokeRequestErrorCallback(e);
      return null;
    }
  }

  Future<bool> _isLoggedIn() async {
    return await const FlutterSecureStorage().containsKey(key: "accessToken");
  }

  Future<bool> _isTokenValid() async {
    String? expiry =
        await const FlutterSecureStorage().read(key: 'tokenExpiry');
    if (expiry == null) {
      return false;
    }
    if (DateTime.parse(expiry).isBefore(DateTime.now())) {
      return false;
    }
    return true;
  }
}
