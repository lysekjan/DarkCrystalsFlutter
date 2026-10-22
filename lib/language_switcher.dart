import 'package:flutter/material.dart';
import 'localization.dart';
import 'language_manager.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppLanguage>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            LanguageManager.currentLanguage.flagEmoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width:4),
          const Icon(Icons.arrow_drop_down, size: 20, color: Colors.white70),
        ],
      ),
      color: const Color(0xFF332A24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (AppLanguage language) async {
        await LanguageManager.setLanguage(language);
      },
      itemBuilder: (BuildContext context) {
        return AppLanguage.values.map((AppLanguage language) {
          final isSelected = LanguageManager.currentLanguage == language;
          return PopupMenuItem<AppLanguage>(
            value: language,
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Text(
                    language.flagEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    language.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  if (isSelected)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.check, color: Color(0xFFFFE38A), size: 20),
                    ),
                ],
              ),
            ),
          );
        }).toList();
      },
    );
  }
}
