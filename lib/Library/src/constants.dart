import 'enums.dart';

class CurrencyConstants {
  static const String valorantPointsId = '85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741';
  static const String radianitePointsId =
      'e59aa87c-4cbf-517a-5983-6e81511be9b7';
  static const String unknownCurrency = 'f08d4ae3-939c-4576-ab26-09ce1f23bb37';

  static CurrencyType getCurrencyTypeFromId(final String id) {
    switch (id) {
      case valorantPointsId:
        return CurrencyType.valorantPoints;
      case radianitePointsId:
        return CurrencyType.radianitePoints;
      case unknownCurrency:
        return CurrencyType.freeAgent;
    }

    return CurrencyType.freeAgent;
  }
}

class ClientConstants {
  static const String clientPlatformHeaderValue =
      'ew0KCSJwbGF0Zm9ybVR5cGUiOiAiUEMiLA0KCSJwbGF0Zm9ybU9TIjogIldpbmRvd3MiLA0KCSJwbGF0Zm9ybU9TVmVyc2lvbiI6ICIxMC4wLjE5MDQyLjEuMjU2LjY0Yml0IiwNCgkicGxhdGZvcm1DaGlwc2V0IjogIlVua25vd24iDQp9';

  static const String clientPlatformHeaderKey = 'X-Riot-ClientPlatform';
}

class ItemTypeConstants {
  static const String weapon = 'e7c63390-eda7-46e0-bb7a-a6abdacd2433';
  static const String buddy = 'dd3bf334-87f3-40bd-b043-682a57a8dc3a';
  static const String playercard = '3f296c07-64c3-494c-923b-fe692a4fa1bd';
  static const String title = '';
  static const String spray = 'd5f120f8-ff8c-4aac-92ea-f2b5acbe9475';

  static ItemType getItemTypeFromId(final String id) {
    switch (id) {
      case buddy:
        return ItemType.buddy;
      case playercard:
        return ItemType.playercard;
      case spray:
        return ItemType.spray;
      case title:
        return ItemType.title;
      case weapon:
        return ItemType.weapon;
    }
    return ItemType.unknown;
  }
}
