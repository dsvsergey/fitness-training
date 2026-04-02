import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/resources/resources.dart';
import '../../core/resources/themes/app_colors.dart';
import '../../core/router/router.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _selectedPageIndex = 0;
  final Color _inactiveColor = AppColors.black;
  final Color _activeColor = AppColors.lightBlue;

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        CalendarRoute(),
        ContactsRoute(),
        SettingsRoute(),
      ],
      builder: (context, child) {
        final tabRouter = AutoTabsRouter.of(context);
        final mediaQuery = MediaQuery.of(context);
        final screenWidth = mediaQuery.size.width;
        final double width = screenWidth > 600 ? 60 : 30;
        final double height = screenWidth > 600 ? 60 : 30;
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            selectedFontSize: screenWidth > 600 ? 28 : 16,
            currentIndex: tabRouter.activeIndex,
            onTap: (index) => _openPage(index, tabRouter),
            backgroundColor: AppColors.white,
            unselectedItemColor: _inactiveColor,
            selectedItemColor: _activeColor,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  AppSvgs.calendar,
                  width: width,
                  height: height,
                  colorFilter: ColorFilter.mode(
                      _selectedPageIndex == 0 ? _activeColor : _inactiveColor,
                      BlendMode.srcIn),
                ),
                label: "Calendar",
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  AppSvgs.contacts,
                  width: width,
                  height: height,
                  colorFilter: ColorFilter.mode(
                      _selectedPageIndex == 1 ? _activeColor : _inactiveColor,
                      BlendMode.srcIn),
                ),
                label: "Contacts",
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  AppSvgs.settings,
                  width: width,
                  height: height,
                  colorFilter: ColorFilter.mode(
                      _selectedPageIndex == 2 ? _activeColor : _inactiveColor,
                      BlendMode.srcIn),
                ),
                label: "Settings",
              ),
            ],
          ),
        );
      },
    );
  }

  void _openPage(int index, TabsRouter tabsRouter) {
    setState(() => _selectedPageIndex = index);
    tabsRouter.setActiveIndex(index);
  }
}
