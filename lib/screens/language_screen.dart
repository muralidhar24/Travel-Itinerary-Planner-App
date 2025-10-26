import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../utils/constants.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          final languages = languageProvider.getSupportedLanguages();
          final currentLanguageCode = languageProvider.currentLocale.languageCode;

          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingSmall),
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final language = languages[index];
              final isSelected = language['code'] == currentLanguageCode;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingSmall,
                  vertical: 4,
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? AppConstants.primaryColor.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        language['code']!.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected 
                            ? AppConstants.primaryColor 
                            : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    language['nativeName']!,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(language['name']!),
                  trailing: isSelected
                    ? const Icon(
                        Icons.check_circle,
                        color: AppConstants.primaryColor,
                      )
                    : null,
                  onTap: () async {
                    await languageProvider.setLanguage(language['code']!);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Language changed to ${language['nativeName']}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
