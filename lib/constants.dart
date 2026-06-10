// lib/constants.dart

import 'package:flutter/material.dart';

// ─── API ───────────────────────────────────────────────
const String kBaseUrl = 'https://freshchickennepal.infinityfreeapp.com/chicken_shop/php';
// Change to your actual domain ↑

// ─── PAYMENT ───────────────────────────────────────────
const String kKhaltiPublicKey = 'your_khalti_public_key_here';
const String kEsewaMerchantId = 'your_esewa_merchant_id_here';

// ─── SHOP INFO ─────────────────────────────────────────
const String kShopName     = 'Chiksy';
const String kShopLocation = 'Butwal, Lumbini';
const String kShopPhone    = '980-000-0000';

// ─── ORDER ─────────────────────────────────────────────
const double kMinOrderAmount   = 200;
const double kDeliveryCharge   = 0;

// ─── COLORS ────────────────────────────────────────────
const Color kRed        = Color(0xFFC0392B);
const Color kRedDark    = Color(0xFF922B21);
const Color kRedLight   = Color(0xFFFDECEA);
const Color kCream      = Color(0xFFFDF8F0);
const Color kBone       = Color(0xFFF5EFE0);
const Color kBorder     = Color(0xFFE8E0D0);
const Color kMuted      = Color(0xFF6B6B6B);
const Color kKhalti     = Color(0xFF5C2D91);
const Color kEsewa      = Color(0xFF60BB46);

// ─── THEME ─────────────────────────────────────────────
ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kRed,
      primary: kRed,
      background: kCream,
    ),
    scaffoldBackgroundColor: kCream,
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(
      backgroundColor: kRed,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kBorder, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kRed, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}