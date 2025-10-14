// lib/screens/language_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeismoney/providers/locale_provider.dart';
import 'package:timeismoney/l10n/app_localizations.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = AppLocalizations.of(context);

    final languages = [
      {'code': null, 'name': l10n.systemDefault, 'flag': '🌍'},
      {'code': 'fr', 'name': l10n.french, 'flag': '🇫🇷'},
      {'code': 'en', 'name': l10n.english, 'flag': '🇬🇧'},
      {'code': 'es', 'name': l10n.spanish, 'flag': '🇪🇸'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language),
        backgroundColor: const Color(0xFF060608),
      ),
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final language = languages[index];
          final languageCode = language['code'];
          final isSelected = (languageCode == null && localeProvider.locale == null) ||
              (localeProvider.locale?.languageCode == languageCode);

          return ListTile(
            leading: Text(
              language['flag'] as String,
              style: const TextStyle(fontSize: 32),
            ),
            title: Text(
              language['name'] as String,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check, color: Color(0xFFFFD700))
                : null,
            onTap: () {
              final newLocale = languageCode != null ? Locale(languageCode) : null;
              localeProvider.setLocale(newLocale);
              
              // Affiche un message de confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    languageCode == null
                        ? l10n.systemDefault
                        : '${language['name']}',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
