import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:othtix_app/src/blocs/auth/auth_bloc.dart';
import 'package:othtix_app/src/blocs/login/login_bloc.dart';
import 'package:othtix_app/src/config/routes/route_names.dart';
import 'package:othtix_app/src/data/services/remote/google_auth_service.dart';
import 'package:othtix_app/src/presentations/extensions/extensions.dart';
import 'package:othtix_app/src/presentations/utils/utils.dart';
import 'package:othtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:validatorless/validatorless.dart';

import 'package:othtix_app/src/config/constant.dart';
import 'package:othtix_app/src/presentations/pages/webview_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key, this.initialUsername});

  final String? initialUsername;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        actions: const [
          ThemeToggleIconButton(),
        ],
      ),
      body: ResponsivePadding(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.height / 8),
              child: Text(
                'Enter your details to continue',
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            BlocProvider(
              create: (_) => GetIt.I<LoginBloc>(),
              child: Builder(
                builder: (context) {
                  return BlocListener<LoginBloc, LoginState>(
                    listener: (context, state) {
                      state.whenOrNull(
                        success: (auth) => context
                            .read<AuthBloc>()
                            .add(AuthEvent.authenticate(newAuth: auth)),
                        error: (error) => ErrorDialog.show(context, error),
                      );
                    },
                    child: _LoginForm(
                      initialUsername: initialUsername,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Don\'t have an account?'),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => context.goNamed(RouteNames.register),
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({this.initialUsername});

  final String? initialUsername;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _obscurePassword = ValueNotifier(true);
  final _debouncer = Debouncer();

  bool _isTocChecked = false;
  bool _isPrivacyChecked = false;

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.initialUsername ?? '';
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _obscurePassword.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...formWidgets,
          const SizedBox(height: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _isTocChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isTocChecked = value ?? false;
                      });
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'I accept the ',
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: 'Terms and Conditions',
                          style: TextStyle(
                            color: context.colorScheme.primary,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              WebViewPage.showAsBottomSheet(
                                context,
                                url: Constant.termAndConditionUrl,
                                title: 'Term and Condition',
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _isPrivacyChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isPrivacyChecked = value ?? false;
                      });
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'I accept the ',
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: context.colorScheme.primary,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              WebViewPage.showAsBottomSheet(
                                context,
                                url: Constant.privacyAndPolicyUrl,
                                title: 'Privacy Policy',
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              final bloc = context.read<LoginBloc>();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    onPressed: state.maybeWhen(
                      loading: null,
                      success: null,
                      orElse: () => () {
                        if (!_isTocChecked || !_isPrivacyChecked) {
                          context.showSimpleTextSnackBar(
                            'You must accept both the Terms and Conditions and Privacy Policy to continue.',
                          );
                          return;
                        }
                        if (_formKey.currentState?.validate() ?? false) {
                          bloc.add(
                            LoginEvent.usernamelogin(
                              username: _usernameController.value.text,
                              password: _passwordController.value.text,
                            ),
                          );
                        }
                      },
                    ),
                    icon: const Icon(Icons.login_outlined),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: state.maybeWhen(
                        loading: () => const Text('Loading...'),
                        orElse: () => const Text('Login'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: state.maybeWhen(
                      loading: null,
                      success: null,
                      orElse: () => () {
                        if (GoogleAuthService.supported) {
                          return bloc.add(const LoginEvent.googleSignIn());
                        }
                        context.showSimpleTextSnackBar(
                          'Google sign in not supported on ${Platform.operatingSystem}',
                        );
                      },
                    ),
                    icon: const FaIcon(FontAwesomeIcons.google),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Sign in with Google'),
                    ),
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  late final formWidgets = [
    CustomTextFormField(
      controller: _usernameController,
      debounce: true,
      debouncer: _debouncer,
      validator: Validatorless.multiple([
        Validatorless.between(3, 16, 'Must have between 3 and 16 characters'),
        Validatorless.required('Username required'),
      ]),
      decoration: const InputDecoration(
        labelText: 'Enter your username',
        helperText: '',
      ),
    ),
    const SizedBox(height: 8),
    ValueListenableBuilder<bool>(
      valueListenable: _obscurePassword,
      builder: (context, value, widget) {
        return CustomTextFormField(
          controller: _passwordController,
          obscureText: value,
          debounce: true,
          debouncer: _debouncer,
          validator: Validatorless.multiple([
            Validatorless.between(8, 64, 'Must have a minimum of 8 characters'),
            Validatorless.required('Password required'),
          ]),
          decoration: InputDecoration(
            labelText: 'Enter your password',
            helperText: '',
            suffixIcon: IconButton(
              onPressed: () {
                _obscurePassword.value = !_obscurePassword.value;
              },
              icon: Icon(
                value
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
        );
      },
    ),
  ];
}

