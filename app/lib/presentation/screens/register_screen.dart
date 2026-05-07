import 'package:auto_route/auto_route.dart';
import 'package:fitness_training/core/bloc/bloc_application/application_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';

import '../widgets/text_field_widget.dart';

@RoutePage()
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  String? _validationError;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmPasswordCtrl.text;

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _validationError = 'Please fill in all fields');
      return;
    }
    if (password != confirm) {
      setState(() => _validationError = 'Passwords do not match');
      return;
    }
    if (password.length < 6) {
      setState(() => _validationError = 'Password must be at least 6 characters');
      return;
    }

    setState(() => _validationError = null);
    context.read<ApplicationBloc>().add(
          RegisterEvent(
            email: email,
            firstName: firstName,
            lastName: lastName,
            password: password,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return BlocListener<ApplicationBloc, ApplicationState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          showFToast(
            context: context,
            title: const Text('Account created! You can now sign in.'),
            variant: FToastVariant.primary,
          );
          context.router.pop();
        }
        if (state is ApplicationError) {
          showFToast(
            context: context,
            title: Text(state.error),
            variant: FToastVariant.destructive,
          );
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(FIcons.arrowLeft, color: colors.foreground),
            onPressed: () => context.router.pop(),
          ),
          title: Text(
            'Create Account',
            style: typography.lg.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: BlocBuilder<ApplicationBloc, ApplicationState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Join us today',
                      style: typography.xl2.copyWith(
                        color: colors.foreground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Create your trainer account',
                      style: typography.sm.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextFieldWidget(
                      controller: _firstNameCtrl,
                      hintText: 'First Name',
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 16),
                    TextFieldWidget(
                      controller: _lastNameCtrl,
                      hintText: 'Last Name',
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 16),
                    TextFieldWidget(
                      controller: _emailCtrl,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFieldWidget(
                      controller: _passwordCtrl,
                      hintText: 'Password',
                      isPassword: true,
                    ),
                    const SizedBox(height: 16),
                    TextFieldWidget(
                      controller: _confirmPasswordCtrl,
                      hintText: 'Confirm Password',
                      isPassword: true,
                      errorText: _validationError,
                    ),
                    const SizedBox(height: 28),
                    FButton(
                      onPress: isLoading ? null : _submit,
                      child: isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.theme.colors.primaryForeground,
                              ),
                            )
                          : const Text('Create Account'),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: typography.sm.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.router.pop(),
                          child: Text(
                            'Sign In',
                            style: typography.sm.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
