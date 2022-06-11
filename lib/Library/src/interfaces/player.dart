import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:valorant_companion/Library/src/models/inventory.dart';
import 'package:valorant_companion/Utils/helpers.dart';

import '../constants.dart';
import '../enums.dart';
import '../models/balance.dart';
import '../models/mmr.dart';
import '../models/offers.dart';
import '../models/storefront.dart';
import '../models/user.dart';
import '../url_manager.dart';
import '../valorant_client_base.dart';

class PlayerInterface {
  final ValorantClient _client = ValorantClient.instance;

  PlayerInterface();

  Future<User?> getPlayer() async {
    final requestUri = Uri.parse(
        '${UrlManager.getBaseUrlForRegion(stringToRegion(await const FlutterSecureStorage().read(key: 'userRegion') ?? "AP")!)}/name-service/v2/players');
    final response = await _client.executeRawRequest(
      method: HttpMethod.put,
      uri: requestUri,
      body: '["${await const FlutterSecureStorage().read(key: 'userPuuid')}"]',
    );

    if (response == null) {
      return null;
    }

    return (response as Iterable<dynamic>).map((e) => User.fromMap(e)).first;
  }

  Future<Balance?> getBalance() async {
    final requestUri = Uri.parse(
        '${UrlManager.getBaseUrlForRegion(stringToRegion(await const FlutterSecureStorage().read(key: 'userRegion') ?? "AP")!)}/store/v1/wallet/${await const FlutterSecureStorage().read(key: 'userPuuid')}');
    final response = await _client.executeRawRequest(
      method: HttpMethod.get,
      uri: requestUri,
    );

    if (response == null) {
      return null;
    }

    return Balance(
      valorantPoints:
          (response['Balances'][CurrencyConstants.valorantPointsId] ?? 0)
              as int,
      radianitePoints:
          (response['Balances'][CurrencyConstants.radianitePointsId] ?? 0)
              as int,
      unknowCurrency:
          (response['Balances'][CurrencyConstants.unknownCurrency] ?? 0) as int,
    );
  }

  Future<MMR?> getMMR() async {
    final requestUri = Uri.parse(
        '${UrlManager.getBaseUrlForRegion(stringToRegion(await const FlutterSecureStorage().read(key: 'userRegion') ?? "AP")!)}/mmr/v1/players/${await const FlutterSecureStorage().read(key: 'userPuuid')}/competitiveupdates');
    final response = await _client.executeGenericRequest<MMR>(
      typeResolver: MMR(),
      method: HttpMethod.get,
      uri: requestUri,
    );

    if (response == null) {
      return null;
    }

    return response;
  }

  Future<Storefront?> getStorefront() async {
    final requestUri = Uri.parse(
        '${UrlManager.getBaseUrlForRegion(stringToRegion(await const FlutterSecureStorage().read(key: 'userRegion') ?? "AP")!)}/store/v2/storefront/${await const FlutterSecureStorage().read(key: 'userPuuid')}');

    return await _client.executeGenericRequest<Storefront>(
      typeResolver: Storefront(),
      method: HttpMethod.get,
      uri: requestUri,
    );
  }

  Future<Offers?> getStoreOffers() async {
    final requestUri = Uri.parse(
        '${UrlManager.getBaseUrlForRegion(stringToRegion(await const FlutterSecureStorage().read(key: 'userRegion') ?? "AP")!)}/store/v1/offers/');

    return await _client.executeGenericRequest<Offers>(
      typeResolver: Offers(),
      method: HttpMethod.get,
      uri: requestUri,
    );
  }

  Future<Inventory?> getInventory() async {
    final requestUri = Uri.parse(
        '${UrlManager.getBaseUrlForRegion(stringToRegion(await const FlutterSecureStorage().read(key: 'userRegion') ?? "AP")!)}/personalization/v2/players/${await const FlutterSecureStorage().read(key: 'userPuuid')}/playerloadout');
    final response = await _client.executeRawRequest(
      method: HttpMethod.get,
      uri: requestUri,
    );

    if (response == null) {
      return null;
    }

    return Inventory.fromJson(response);
  }
}
