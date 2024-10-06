import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/src/core/ui/colors.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/features/auth/cubit/auth_cubit.dart';
import 'package:my_app/src/features/settings/cubit/settings_cubit.dart';
import 'package:my_app/src/features/settings/widgets/change_language_dialog.dart';
import 'package:my_app/src/features/settings/widgets/change_profile_image_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settings),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return Column(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(context.l10n.profileImage,
                    style: AppTextStyle()
                        .body
                        .copyWith(color: colorScheme.onSurface),),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) {
                    return const ChangeProfileImageDialog();
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(context.l10n.language,
                    style: AppTextStyle()
                        .body
                        .copyWith(color: colorScheme.onSurface),),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) {
                    return const ChangeLanguageDialog();
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: Text(context.l10n.darkMode,
                    style: AppTextStyle()
                        .body
                        .copyWith(color: colorScheme.onSurface),),
                trailing: SwitchTheme(
                  data: Theme.of(context).switchTheme.copyWith(),
                  child: Switch(
                    value: state.theme == ThemeMode.dark,
                    onChanged: (value) =>
                        context.read<SettingsCubit>().changeTheme(),
                  ),
                ),
              ),
              ListTile(
                onTap: () => _showLogoutConfirmationDialog(context),
                leading: const Icon(
                  Icons.logout,
                  color: AppColor.fail,
                ),
                title: Text(
                  context.l10n.logout,
                  style: AppTextStyle().body.copyWith(color: AppColor.fail),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.l10n.confirmLogout),
          content: Text(context.l10n.logoutConfirmation),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                context.l10n.cancel,
                style: AppTextStyle().textButton.copyWith(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthCubit>().logout();
              },
              child: Text(
                context.l10n.logout,
                style: AppTextStyle()
                    .textButton
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }
}
