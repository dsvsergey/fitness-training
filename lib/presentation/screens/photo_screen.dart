import 'package:auto_route/auto_route.dart';
import 'package:fitness_training/core/resources/resources.dart';
import 'package:fitness_training/core/router/router.dart';
import 'package:fitness_training/data/repositories/preferences_repository.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

@RoutePage()
class PhotoScreen extends StatefulWidget {
  const PhotoScreen({super.key});

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
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
      AutoRouter.of(context).push(const HomeRoute());
    } else {
      AutoRouter.of(context).push(const LoginRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colors.background,
      body: Container(
          color: context.theme.colors.background,
          child: Center(
            child: Image.asset(
              AppPngs.photo,
            ),
          )

          //  Image.network(
          //   'https://sportishka.com/uploads/posts/2022-03/1648510065_1-sportishka-com-p-vidi-pressa-u-muzhchin-sport-krasivie-foto-1.jpg',
          //   height: double.infinity,
          // ),
          ),
    );
  }
}
   //  Image.network(
          //   'https://sportishka.com/uploads/posts/2023-12/1701593850_sportishka-com-p-personalnie-trenirovki-krossfit-krasivo-63.jpg,
          //   height: double.infinity,
          // ),