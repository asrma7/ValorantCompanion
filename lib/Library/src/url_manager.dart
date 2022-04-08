import 'enums.dart';
import 'extensions.dart';

class UrlManager {
  static const String authUrl =
      'https://auth.riotgames.com/api/v1/authorization';
  static const String entitlementsUrl =
      'https://entitlements.auth.riotgames.com/api/token/v1';
  static const String versionUrl = 'https://valorant-api.com/v1/version';
  static String getContentBaseUrl = 'https://valorant-api.com/v1';
  static String getSingleOfferUrl = 'https://assist.rumblemike.com/Offers';

  static String getBaseUrlForRegion(Region region) =>
      'https://pd.${region.humanized}.a.pvp.net';
  static String getContentBaseUrlForRegion(Region region) =>
      'https://shared.${region.humanized}.a.pvp.net';
  static String getMatchHistoryBaseUrlForRegion(Region region, String puuid) =>
      'https://pd.${region.humanized}.a.pvp.net/match-history/v1/history/$puuid?startIndex=0&endIndex=20';
  static String getMatchInfoBaseUrlForRegion(
          Region region, String matchPuuid) =>
      'https://pd.${region.humanized}.a.pvp.net/match-details/v1/matches/$matchPuuid';
}
