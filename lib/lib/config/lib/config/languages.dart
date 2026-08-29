import 'package:flutter/material.dart';

class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final Locale locale;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.locale,
  });
}

/// Supported languages – Global + strong Asia coverage
const List<AppLanguage> supportedLanguages = [
  AppLanguage(code: 'en', name: 'English', nativeName: 'English', locale: Locale('en')),
  AppLanguage(code: 'zh', name: 'Chinese', nativeName: '中文', locale: Locale('zh')),
  AppLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', locale: Locale('hi')),
  AppLanguage(code: 'id', name: 'Indonesian', nativeName: 'Bahasa Indonesia', locale: Locale('id')),
  AppLanguage(code: 'ja', name: 'Japanese', nativeName: '日本語', locale: Locale('ja')),
  AppLanguage(code: 'ko', name: 'Korean', nativeName: '한국어', locale: Locale('ko')),
  AppLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية', locale: Locale('ar')),
  AppLanguage(code: 'es', name: 'Spanish', nativeName: 'Español', locale: Locale('es')),
  AppLanguage(code: 'fr', name: 'French', nativeName: 'Français', locale: Locale('fr')),
  AppLanguage(code: 'pt', name: 'Portuguese', nativeName: 'Português', locale: Locale('pt')),
  AppLanguage(code: 'ru', name: 'Russian', nativeName: 'Русский', locale: Locale('ru')),
  AppLanguage(code: 'th', name: 'Thai', nativeName: 'ไทย', locale: Locale('th')),
  AppLanguage(code: 'vi', name: 'Vietnamese', nativeName: 'Tiếng Việt', locale: Locale('vi')),
  AppLanguage(code: 'tr', name: 'Turkish', nativeName: 'Türkçe', locale: Locale('tr')),
  AppLanguage(code: 'de', name: 'German', nativeName: 'Deutsch', locale: Locale('de')),
];
