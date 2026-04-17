import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;
import '../../core/router/router.dart';
import '../../data/repositories/preferences_repository.dart';

// ignore_for_file: use_build_context_synchronously
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
    routing();
  }

  void routing() async {
    final prefsRepo = PreferencesRepository();
    final token = await prefsRepo.getToken();

    await Future.delayed(const Duration(seconds: 2));

    if (token?.accessToken != null &&
        !(token?.expires?.isBefore(DateTime.now()) ?? true)) {
      AutoRouter.of(context).replace(const HomeRoute());
    } else {
      AutoRouter.of(context).replace(const LoginRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFECF25F), Color(0xFFC8CE37)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 250,
                width: 250,
                child: rive.RiveAnimation.asset(
                  'assets/rive/coin_fitness.riv',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 50),
              AnimatedTextKit(
                animatedTexts: [
                  ColorizeAnimatedText(
                    'NEW ELEMENT\nTRAINING',
                    textAlign: TextAlign.center,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      fontFamily: 'Lobster',
                    ),
                    colors: [
                      const Color(0xFF0abab5),
                      Colors.black,
                      Colors.green,
                      Colors.white,
                      Colors.amber,
                      Colors.black
                    ],
                  )
                ],
                repeatForever: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
