import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'app_localizations_en.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('it'),
    Locale('pt', 'BR'),
    Locale('ru'),
    Locale('zh'),
    Locale('ja'),
    Locale('ko'),
    Locale('ar'),
    Locale('hi'),
    Locale('id'),
    Locale('tr'),
    Locale('nl'),
    Locale('ta'),
    Locale('te'),
    Locale('ml'),
  ];

  static Future<AppLocalizations> load(Locale locale) async {
    final String name = locale.countryCode == null ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    Intl.defaultLocale = localeName;
    return AppLocalizations(locale);
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? AppLocalizations(const Locale('en'));
  }

  String getString(String key) {
    final Map<String, String> strings = _localizedValues[locale.languageCode] ?? _localizedValues['en']!;
    return strings[key] ?? _localizedValues['en']![key] ?? key;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': localizedStringsEn,
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .map((supportedLocale) => supportedLocale.languageCode)
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}