import '../Library/src/enums.dart';

Region? stringToRegion(String region) {
  switch (region) {
    case 'NA':
      return Region.na;
    case 'EU':
      return Region.eu;
    case 'AP':
      return Region.ap;
    case 'KR':
      return Region.kr;
    default:
      return null;
  }
}
