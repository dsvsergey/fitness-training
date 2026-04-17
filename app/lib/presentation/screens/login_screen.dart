import 'package:auto_route/auto_route.dart';
import 'package:fitness_training/core/bloc/bloc_application/application_bloc.dart';
import 'package:fitness_training/core/resources/resources.dart';
import 'package:fitness_training/core/router/router.dart';
import 'package:fitness_training/domain/usecases/fitness/auth_usecase.dart';
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
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colors.background,
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroSection(isTablet: isTablet, screenHeight: size.height - 8),
              // const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Welcome back',
                      style: typography.xl2.copyWith(
                        color: colors.foreground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // const SizedBox(height: 4),
                    Text(
                      'Sign in to your trainer account',
                      style: typography.sm.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFieldWidget(
                      controller: _emailCtrl,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    TextFieldWidget(
                      isPassword: true,
                      controller: _passwordCtrl,
                      hintText: 'Password',
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Forgot password?',
                          style: typography.sm.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<ApplicationBloc, ApplicationState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return Column(
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
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(child: Divider(color: colors.border)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    'or',
                                    style: typography.sm.copyWith(
                                      color: colors.mutedForeground,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: colors.border)),
                              ],
                            ),
                            const SizedBox(height: 14),
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
                        );
                      },
                    ),
                    const SizedBox(height: 28),
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
                          onTap: () =>
                              context.router.push(const RegisterRoute()),
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
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isTablet, required this.screenHeight});

  final bool isTablet;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    final heroHeight = screenHeight * 0.42;

    return SizedBox(
      height: heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            isTablet ? AppPngs.loginPhotoTable : AppPngs.loginPhoto,
            fit: BoxFit.cover,
          ),
          // Gradient overlay — dark at bottom for text legibility
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.72),
                ],
                stops: const [0.3, 1.0],
              ),
            ),
          ),
          // Content overlay
          Positioned(
            left: 24,
            right: 24,
            bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8CE37),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'TRAINER APP',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1E1E),
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'New Element\nTraining',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Manage your athletes. Track every rep.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
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
