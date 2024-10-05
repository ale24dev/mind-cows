import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/core/utils/widgets/cache_widget.dart';
import 'package:my_app/src/core/utils/widgets/generic_button.dart';
import 'package:my_app/src/features/game/cubit/game_cubit.dart';
import 'package:my_app/src/features/player/cubit/player_cubit.dart';
import 'package:my_app/src/features/settings/cubit/settings_cubit.dart';
import 'package:my_app/src/features/settings/data/profile_images.dart';
import 'package:sized_context/sized_context.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ChangeProfileImageDialog extends HookWidget {
  const ChangeProfileImageDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final indexSelected = useState<int>(-1);
    const imageSize = Size(20, 20);

    final borderRadius = BorderRadius.circular(5);

    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(
        context.l10n.changeProfileImage,
        style:
            AppTextStyle().dialogTitle.copyWith(color: colorScheme.onSurface),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: context.heightPx * .35,
            width: 300,
            child: GridView.builder(
              itemCount: profileImagesUrl.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final profileImage = profileImagesUrl[index];
                return GestureDetector(
                  onTap: () => indexSelected.value = index,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      border: Border.all(
                        color: indexSelected.value == index
                            ? colorScheme.primary
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: CacheWidget(
                      borderRadius: borderRadius,
                      imageUrl: profileImage,
                      size: imageSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
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
        BlocConsumer<PlayerCubit, PlayerState>(
          listener: (context, state) {
            if (state.isError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: colorScheme.error,
                  content: Text(context.l10n.anErrorOccurred),
                ),
              );
            }
            if (state.isSuccess) {
              context.read<GameCubit>().setUserPlayer(state.player!);
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            return GenericButton(
              loading: state.isLoading,
              widget: Text(
                context.l10n.accept,
                style: AppTextStyle().body.copyWith(color: Colors.white),
              ),
              onPressed: indexSelected.value != -1
                  ? () => context
                      .read<PlayerCubit>()
                      .setProfileImage(profileImagesUrl[indexSelected.value])
                  : null,
            );
          },
        ),
      ],
    );
  }
}
