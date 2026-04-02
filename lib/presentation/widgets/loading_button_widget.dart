// import 'package:fitness_training/core/resources/themes/app_colors.dart';
// import 'package:fitness_training/core/resources/themes/app_fonts.dart';
// import 'package:flutter/material.dart';
// import 'package:rounded_loading_button/rounded_loading_button.dart';

// class LoadingButtonWidget extends StatelessWidget {
//   const LoadingButtonWidget({
//     super.key,
//     required this.onPressed,
//     required this.title,
//     required this.btnController,
//     required this.errorColor,
//   });
//   final Function()? onPressed;
//   final Color errorColor;
//   final String title;
//   final RoundedLoadingButtonController btnController;

//   @override
//   Widget build(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     final screenWidth = mediaQuery.size.width;
//     return RoundedLoadingButton(
//       height: screenWidth > 600 ? 70 : 50,
//       width: screenWidth > 600 ? 548 : 390,
//       color: AppColors.colorMain,
//       controller: btnController,
//       errorColor: errorColor,
//       onPressed: onPressed,
//       child: Text(
//         'Log In',
//         textAlign: TextAlign.center,
//         style: screenWidth > 600 ? AppFonts.w700s25 : AppFonts.w700s18,
//       ),
//     );
//   }
// }
