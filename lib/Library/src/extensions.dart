import 'package:flutter/material.dart';

import 'models/user.dart';

extension UserExtension on User {
  String get renderedDisplayName => '$gameName#$tagLine';
}

extension EnumExtensions on Enum {
  String get humanized => toString().split('.').last;
}

extension HexColor on Color {
  static Color fromHex(String hexString, {bool endOpacity = false}) {
    final buffer = StringBuffer();
    String temp = hexString;
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    hexString = hexString.replaceFirst('#', '');
    if (endOpacity) {
      hexString = temp.substring(temp.length - 2, hexString.length) +
          hexString.substring(0, hexString.length - 2);
    }
    buffer.write(hexString);
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
