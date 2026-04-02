import 'dart:async';
import 'package:fitness_training/core/resources/resources.dart';
import 'package:flutter/material.dart';

class AutoChangingImages extends StatefulWidget {
  const AutoChangingImages({super.key});

  @override
  _AutoChangingImagesState createState() => _AutoChangingImagesState();
}

class _AutoChangingImagesState extends State<AutoChangingImages> {
  late PageController _controller;
  int _currentPage = 0;
  late Timer _timer;

  final List<Widget> _images = [
    Image.asset(AppPngs.photos01, fit: BoxFit.cover),
    Image.asset(AppPngs.photos02, fit: BoxFit.cover),
    Image.asset(AppPngs.photos03, fit: BoxFit.cover),
    Image.asset(AppPngs.photos04, fit: BoxFit.cover),
    Image.asset(AppPngs.photos05, fit: BoxFit.cover),
    Image.asset(AppPngs.photos06, fit: BoxFit.cover),
    
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: _currentPage);
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < _images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _controller.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    return SizedBox(
      height: screenWidth > 600
          ? MediaQuery.of(context).size.height / 2.0
          : MediaQuery.of(context).size.height / 2.3,
      child: PageView.builder(
        controller: _controller,
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return _images[index];
        },
      ),
    );
  }
}
