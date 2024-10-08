import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/core/utils/widgets/generic_button.dart';
import 'package:my_app/src/features/settings/cubit/settings_cubit.dart';

class ChangeLanguageDialog extends StatefulWidget {
  const ChangeLanguageDialog({super.key});

  @override
  _ChangeLanguageDialogState createState() => _ChangeLanguageDialogState();
}

class _ChangeLanguageDialogState extends State<ChangeLanguageDialog> {
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    final settingsCubit = context.read<SettingsCubit>();
    _selectedLanguage = settingsCubit.state.locale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final settingsCubit = context.read<SettingsCubit>();

    return AlertDialog(
      title: Text(context.l10n.changeLanguage),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(context.l10n.english),
            leading: Radio<String>(
              value: 'en',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
            ),
            onTap: () {
              setState(() {
                _selectedLanguage = 'en';
              });
            },
          ),
          ListTile(
            title: Text(context.l10n.spanish),
            leading: Radio<String>(
              value: 'es',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
            ),
            onTap: () {
              setState(() {
                _selectedLanguage = 'es';
              });
            },
          ),
          // Agrega más idiomas aquí si es necesario
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            context.l10n.cancel,
            style: AppTextStyle()
                .textButton
                .copyWith(color: colorScheme.onSurface),
          ),
        ),
        GenericButton(
          widget: Text(
            context.l10n.accept,
            style: AppTextStyle().body.copyWith(color: Colors.white),
          ),
          onPressed: () {
            settingsCubit.changeLanguage(_selectedLanguage);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}