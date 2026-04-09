import 'package:flutter/material.dart';

class AppColor {
  static  Color cAppPrimaryColor = HexColor.fromHex("#97C09E");
  static const Color cAppBackgroundColor = Color(0xffE0F5E7);
  static  Color cPrimaryButtonColor = HexColor.fromHex("#106E25");


  static const Color blackColor = Color(0xff000000);
  static const Color whiteColor = Color(0xffffffff);
  static const Color greyColor = Color(0xffBDBDBD);
  static const Color lightGreyColor = Color(0xffF5F5F5);
  static const Color colorAccent = Color(0xFF38686A);
  static const Color primaryColor = Color(0xff01B1C9);
  static const Color redColor = Color(0xffFC3F5B);
  static const Color primaryButtonColor = Color(0xff01B1C9);
  static const Color secondaryButtonColor = Color(0xffFC3F5B);
  static const Color primaryTextColor = Color(0xff000000);
  static const Color secondaryTextColor = Color(0xff444648);
  static Color cardBgColor = HexColor.fromHex("#FFFFFF");
  static Color scaffoldBackgroundColor = Colors.grey[300]!;

  // Main_view
  static Color bottomNavBarBackground = HexColor.fromHex("#97C09E");
  static Color selectedItemColor = HexColor.fromHex("#FFFFFF");
  static Color unselectedItemColor = HexColor.fromHex("#FAFAFA");

  static Color profilePageProfessionColor = HexColor.fromHex("#6C6C6C");
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
