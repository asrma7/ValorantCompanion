import '../enums.dart';
import '../models/serializable.dart';
import '../url_manager.dart';
import '../valorant_client_base.dart';

class AssetInterface {
  final ValorantClient _client = ValorantClient.instance;

  Future<T?> getAssets<T extends ISerializable<T>>({
    required T typeResolver,
    required String assetType,
  }) async {
    final requestUri = Uri.parse('${UrlManager.getContentBaseUrl}/$assetType');
    final response = await _client.executeRawRequest(
      method: HttpMethod.get,
      uri: requestUri,
    );

    return response != null ? typeResolver.fromJson(response) : null;
  }

  Future<T?> getSingleAssets<T extends ISerializable<T>>({
    required T typeResolver,
    required String assetType,
    required String assetId,
  }) async {
    final requestUri =
        Uri.parse('${UrlManager.getContentBaseUrl}/$assetType/$assetId');
    final response = await _client.executeRawRequest(
      method: HttpMethod.get,
      uri: requestUri,
    );

    return response != null ? typeResolver.fromJson(response) : null;
  }
}
