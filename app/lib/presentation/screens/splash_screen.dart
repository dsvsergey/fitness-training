import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:fitness_training/core/bloc/bloc_application/application_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/router/router.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _routing();
  }

  Future<void> _routing() async {
    final bloc = context.read<ApplicationBloc>();
    bloc.add(RestoreSessionEvent());

    final settledState = bloc.stream.firstWhere(
      (s) => s is AuthSucces || s is AuthLogout || s is ApplicationError,
    );
    final results = await Future.wait([
      settledState,
      Future.delayed(const Duration(seconds: 2)),
    ]);
    if (!mounted) return;

    final state = results[0] as ApplicationState;
    if (state is AuthSucces) {
      AutoRouter.of(context).replace(const HomeRoute());
    } else {
      AutoRouter.of(context).replace(const LoginRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NEW ELEMENT',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
            Text(
              'TRAINING',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFFC8CE37),
                letterSpacing: 3,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'TRAINER APP',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9E9E9E),
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
