import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fitness_training/core/bloc/bloc_application/application_bloc.dart';
import 'package:fitness_training/core/router/router.dart';
import 'package:fitness_training/domain/usecases/fitness/auth_usecase.dart';
import 'package:fitness_training/presentation/screens/auto_changing_images.dart';
import 'package:fitness_training/presentation/widgets/button_widget.dart';
import 'package:fitness_training/presentation/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _googleLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onGoogleSignIn() async {
    setState(() => _googleLoading = true);
    try {
      final authUrl = await GetIt.I<AuthUsecase>().getGoogleAuthUrl();
      if (!mounted) return;
      final token = await context.router.push<String?>(
        GoogleOAuthRoute(authUrl: authUrl),
      );
      if (token != null && mounted) {
        context.read<ApplicationBloc>().add(GoogleLoginEvent(token: token));
      }
    } catch (e) {
      if (mounted) {
        showFToast(
          context: context,
          title: const Text('Failed to open Google Sign-In'),
          variant: FToastVariant.destructive,
        );
      }
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocListener<ApplicationBloc, ApplicationState>(
        listener: (context, state) {
          if (state is AuthSucces) {
            context.router.replace(const HomeRoute());
          }
          if (state is ApplicationError) {
            showFToast(
              context: context,
              title: Text(state.error),
              variant: FToastVariant.destructive,
            );
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AutoChangingImages(),
              const SizedBox(height: 10),
              AnimatedTextKit(
                animatedTexts: [
                  ColorizeAnimatedText(
                    'Log In',
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth > 750 ? 20 : 25,
                      fontFamily: 'Lobster',
                    ),
                    colors: [
                      const Color(0xFF0abab5),
                      Colors.black,
                      Colors.green,
                      Colors.white,
                      Colors.amber,
                      Colors.black,
                    ],
                  ),
                ],
                repeatForever: true,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFieldWidget(
                      controller: _emailCtrl,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),
                    TextFieldWidget(
                      isPassword: true,
                      controller: _passwordCtrl,
                      hintText: 'Password',
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {}, // TODO: password reset flow
                        child: Text(
                          'Forgot password?',
                          style: typography.sm.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              BlocBuilder<ApplicationBloc, ApplicationState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ButtonWidget(
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.read<ApplicationBloc>().add(
                                        LoginEvent(
                                          email: _emailCtrl.text.trim(),
                                          password: _passwordCtrl.text,
                                        ),
                                      );
                                },
                          title: isLoading ? 'Signing in…' : 'Log In',
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: colors.border),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'or',
                                style: typography.sm.copyWith(
                                  color: colors.mutedForeground,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: colors.border),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FButton(
                          variant: FButtonVariant.outline,
                          onPress: (isLoading || _googleLoading)
                              ? null
                              : _onGoogleSignIn,
                          prefix: _googleLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const _GoogleLogo(),
                          child: const Text('Continue with Google'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: typography.sm.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.router.push(const RegisterRoute()),
                    child: Text(
                      'Register',
                      style: typography.sm.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) => const Text(
        'G',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4285F4),
        ),
      );
}
