part of '../valorant_client_base.dart';

class RSOHandler {
  final Dio _client;
  final UserDetails _userDetails;

  String _tokenType = '';
  String _accessToken = '';
  String _userPuuid = '';
  int _tokenExpiry = 3600;

  RSOHandler({required Dio client, UserDetails? userDetails})
      : _client = client,
        _userDetails = userDetails ??
            UserDetails(
              userName: '',
              password: '',
              region: Region.ap,
            );

  Future<bool> authenticate() async {
    _tokenType = '';
    _userPuuid = '';
    await setSession();
    return tryAuthenticate();
  }

  setSession() async {
    CookieManager cookies = _client.interceptors.firstWhere(
      (interceptor) => interceptor is CookieManager,
    ) as CookieManager;

    cookies.cookieJar.delete(Uri(host: 'auth.riotgames.com'));
    await _client.post(
      UrlManager.authUrl,
      data: {
        "client_id": "play-valorant-web-prod",
        "nonce": 1,
        "redirect_uri": "https://playvalorant.com/opt_in",
        "response_type": "token id_token",
      },
    );
  }

  Future<bool> tryAuthenticate() async {
    if (await _fetchAccessToken() &&
        await _fetchEntitlements() &&
        await _fetchClientVersion()) {
      return true;
    }
    return false;
  }

  Future<bool> _fetchAccessToken() async {
    if (!_userDetails.isValid) {
      return false;
    }

    final payload = jsonEncode(
      {
        'type': 'auth',
        'username': _userDetails.userName,
        'password': _userDetails.password,
      },
    );
    Response? response;
    response = await _client.put(
      UrlManager.authUrl,
      data: payload,
    );
    if (response.statusCode != 200) {
      return false;
    }

    if (response.data['error'] != null &&
        response.data['error'] == 'auth_failure') {
      return false;
    }

    final authUrl =
        (response.data['response']?['parameters']?['uri'] ?? '') as String;
    final parsedUri = Uri.tryParse(authUrl.replaceFirst('#', '?'));

    if (parsedUri == null || !parsedUri.hasQuery) {
      return false;
    }

    _tokenType = parsedUri.queryParameters['token_type'] as String;
    _tokenExpiry =
        (int.tryParse(parsedUri.queryParameters['expires_in'] ?? '3600') ??
            3600);
    _accessToken = parsedUri.queryParameters['access_token'] as String;
    const FlutterSecureStorage().write(
      key: "userRegion",
      value: _userDetails.region.humanized.toUpperCase(),
    );
    const FlutterSecureStorage().write(
      key: "tokenExpiry",
      value: DateTime.now()
          .add(
            Duration(seconds: _tokenExpiry - 10),
          )
          .toString(),
    );
    _userPuuid = response.headers['set-cookie']!
        .singleWhere(
          (cookie) => cookie.startsWith('sub='),
        )
        .split(';')[0]
        .split('=')[1];
    if (parsedUri.queryParameters['access_token'] != null) {
      const FlutterSecureStorage().write(
        key: "accessToken",
        value: _accessToken,
      );
      const FlutterSecureStorage().write(
        key: "userPuuid",
        value: _userPuuid,
      );
      return true;
    }
    return false;
  }

  Future<bool> _fetchEntitlements() async {
    final response = await _client.post(
      UrlManager.entitlementsUrl,
      data: {},
      options: Options(
        headers: {
          HttpHeaders.authorizationHeader: '$_tokenType $_accessToken',
        },
      ),
    );

    if (response.statusCode != 200) {
      return false;
    }
    if (response.data['entitlements_token'] != null) {
      const FlutterSecureStorage().write(
        key: "entitlementsToken",
        value: response.data['entitlements_token'] as String,
      );
      return true;
    }
    return false;
  }

  Future<bool> _fetchClientVersion() async {
    final response = await _client.get(UrlManager.versionUrl);

    if (response.statusCode != 200) {
      return false;
    }

    if (response.data['data']['riotClientVersion'] != null) {
      const FlutterSecureStorage().write(
        key: "clientVersion",
        value: response.data['data']['riotClientVersion'] as String,
      );
      return true;
    }
    return false;
  }

  Future<bool> renewAccessToken() async {
    Response? response;
    response = await _client.post(
      UrlManager.authUrl,
      data: {
        "client_id": "play-valorant-web-prod",
        "nonce": "1",
        "redirect_uri": "https://playvalorant.com/opt_in",
        "response_type": "token id_token",
      },
    );
    if (response.statusCode != 200) {
      return false;
    }

    if (response.data['error'] != null &&
        response.data['error'] == 'auth_failure') {
      return false;
    }

    final authUrl =
        (response.data['response']?['parameters']?['uri'] ?? '') as String;
    final parsedUri = Uri.tryParse(authUrl.replaceFirst('#', '?'));

    if (parsedUri == null || !parsedUri.hasQuery) {
      return false;
    }

    _tokenType = parsedUri.queryParameters['token_type'] as String;
    _tokenExpiry =
        (int.tryParse(parsedUri.queryParameters['expires_in'] ?? '3600') ??
            3600);
    _accessToken = parsedUri.queryParameters['access_token'] as String;
    const FlutterSecureStorage().write(
      key: "tokenExpiry",
      value: DateTime.now()
          .add(
            Duration(seconds: _tokenExpiry - 10),
          )
          .toString(),
    );
    if (parsedUri.queryParameters['access_token'] != null) {
      const FlutterSecureStorage().write(
        key: "accessToken",
        value: _accessToken,
      );
      return true;
    }
    return false;
  }
}
