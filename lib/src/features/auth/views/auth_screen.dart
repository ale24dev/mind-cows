import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/src/core/extensions/string.dart';
import 'package:my_app/src/core/ui/device.dart';
import 'package:my_app/src/core/ui/typography.dart';
import 'package:my_app/src/core/utils/widgets/generic_button.dart';
import 'package:my_app/src/core/utils/widgets/generic_text_field.dart';
import 'package:my_app/src/features/auth/cubit/auth_cubit.dart';
import 'package:my_app/src/router/router.dart';
import 'package:sized_context/sized_context.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool enableButton = false;

  @override
  void initState() {
    _usernameController.addListener(() {
      setState(() {
        enableButton = _usernameController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty;
      });
    });
    _passwordController.addListener(() {
      setState(() {
        enableButton = _usernameController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: context.responsiveContentPadding,
        child: SizedBox(
          width: context.widthPx,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SignIn',
                style: AppTextStyle().body.copyWith(
                      fontFamily: AppTextStyle.secondaryFontFamily,
                      fontSize: 30,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const GutterLarge(),
              GenericTextField(
                labelText: 'Username',
                controller: _usernameController,
              ),
              const GutterTiny(),
              GenericTextField(
                obscureText: true,
                labelText: 'Password',
                controller: _passwordController,
              ),
              const Gutter(),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state.authStatus.isAuthenticated) {
                    WidgetsFlutterBinding.ensureInitialized()
                        .addPostFrameCallback(
                      (_) {
                        context.goNamed(AppRoute.initProfileData.name);
                      },
                    );
                  }
                  if (state.authStatus.isError) {
                    WidgetsFlutterBinding.ensureInitialized()
                        .addPostFrameCallback(
                      (_) {
                        context.read<AuthCubit>().refresh();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text(state.errorMessage ?? 'An error occurred'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                    );
                  }
                  return GenericButton(
                    onPressed: !enableButton
                        ? null
                        : () {
                            context.read<AuthCubit>().signIn(
                                  email: _usernameController
                                      .text.parseStringToEmail,
                                  password: _passwordController.text,
                                );
                          },
                    width: context.widthPx,
                    widget: state.authStatus.isLoading
                        ? const CircularProgressIndicator.adaptive()
                        : Text(
                            'SignIn',
                            style: AppTextStyle()
                                .textButton
                                .copyWith(color: Colors.white),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
