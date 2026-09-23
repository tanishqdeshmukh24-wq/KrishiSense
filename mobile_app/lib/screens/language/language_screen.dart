import 'package:flutter/material.dart';

import '../../core/locale_controller.dart';
import '../../l10n/app_localizations.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: localeController,
      builder: (context, child) {
        final l10n = AppLocalizations.of(context)!;
        final currentLocale = localeController.locale;

        return Scaffold(
          backgroundColor: const Color(0xFFF7FAF5),
          appBar: AppBar(
            title: Text(l10n.language),
            backgroundColor: const Color(0xFFF7FAF5),
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.chooseLanguage,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF073D32),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.selectLanguageDescription,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF526B70),
                  ),
                ),
                const SizedBox(height: 28),

                _LanguageTile(
                  language: l10n.english,
                  subtitle: 'English',
                  locale: const Locale('en'),
                  selected: currentLocale.languageCode == 'en',
                ),

                const SizedBox(height: 12),

                _LanguageTile(
                  language: l10n.hindi,
                  subtitle: 'Hindi',
                  locale: const Locale('hi'),
                  selected: currentLocale.languageCode == 'hi',
                ),

                const SizedBox(height: 12),

                _LanguageTile(
                  language: l10n.marathi,
                  subtitle: 'Marathi',
                  locale: const Locale('mr'),
                  selected: currentLocale.languageCode == 'mr',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String language;
  final String subtitle;
  final Locale locale;
  final bool selected;

  const _LanguageTile({
    required this.language,
    required this.subtitle,
    required this.locale,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        localeController.changeLocale(locale);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? const Color(0xFF239447)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.language,
              color: Color(0xFF239447),
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF073D32),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF526B70),
                    ),
                  ),
                ],
              ),
            ),
            Radio<bool>(
              value: true,
              groupValue: selected ? true : null,
              onChanged: (_) {
                localeController.changeLocale(locale);
              },
              activeColor: const Color(0xFF239447),
            ),
          ],
        ),
      ),
    );
  }
}