import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fitness_training/core/bloc/bloc_application/application_bloc.dart';
import 'package:fitness_training/core/router/router.dart';
import 'package:fitness_training/presentation/screens/auto_changing_images.dart';
import 'package:fitness_training/presentation/widgets/button_widget.dart';
import 'package:fitness_training/presentation/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final controlerEmail = TextEditingController();
  final controlerPassword = TextEditingController();

  late VideoPlayerController _controller;
  String? errorText;
  @override
  void initState() {
    super.initState();
    video();
    // if (kDebugMode) {
    controlerEmail.text = 'Dmitriy.mironyuk@gmail.com';
    controlerPassword.text = 'Sonik@9751';
    // }
  }

  void video() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video/lsec.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AutoChangingImages(),
            SizedBox(height: 10.h),
            AnimatedTextKit(
              animatedTexts: [
                ColorizeAnimatedText(
                  'Log In',
                  textAlign: TextAlign.center,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth > 750 ? 15.w : 25.w,
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
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFieldWidget(
                    errorText: errorText,
                    controller: controlerEmail,
                    hintText: "Email or Phone Number",
                    onChanged: (val) {},
                  ),
                  SizedBox(height: 15.h),
                  TextFieldWidget(
                    isPassword: true,
                    errorText: errorText,
                    controller: controlerPassword,
                    hintText: "Password",
                    onChanged: (val) {},
                  ),
                ],
              ),
            ),
            // const Spacer(),
            SizedBox(height: 20.h),
            BlocListener<ApplicationBloc, ApplicationState>(
              listener: (context, state) {
                if (state is AuthSucces) {
                  AutoRouter.of(context).replace(const HomeRoute());
                }
                if (state is ApplicationError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Center(child: Text(state.error)),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ButtonWidget(
                  onPressed: () async {
                    BlocProvider.of<ApplicationBloc>(context).add(
                      LoginEvent(
                        login: controlerEmail.text,
                        password: controlerPassword.text,
                      ),
                    );
                    // EasyLoading.show(status: 'loading...');
                    //_doSomething();
                  },
                  title: 'Log In',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
