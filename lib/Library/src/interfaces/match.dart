import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:valorant_companion/Utils/helpers.dart';

import '../models/match.dart';
import '../models/match_history.dart';

import '../../valorant_client.dart';
import '../url_manager.dart';

class MatchInterface {
  final ValorantClient _client;

  MatchInterface(this._client);

  Future<Match?> getMatch(String matchPuuid) async {
    final requestUri = Uri.parse(UrlManager.getMatchInfoBaseUrlForRegion(
        stringToRegion(
            await const FlutterSecureStorage().read(key: 'userRegion') ??
                "AP")!,
        matchPuuid));

    return _client.executeGenericRequest<Match>(
      typeResolver: Match(),
      method: HttpMethod.get,
      uri: requestUri,
    );
  }

  Future<MatchHistory?> getHistory(
      {int startIndex = 0, int endIndex = 10}) async {
    final requestUri = Uri.parse(
        '${UrlManager.getBaseUrlForRegion(stringToRegion(await const FlutterSecureStorage().read(key: 'userRegion') ?? "AP")!)}/match-history/v1/history/${await const FlutterSecureStorage().read(key: 'userPuuid')}?startIndex=$startIndex&endIndex=$endIndex');

    return _client.executeGenericRequest<MatchHistory>(
      typeResolver: MatchHistory(),
      method: HttpMethod.get,
      uri: requestUri,
    );
  }
}
