import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../core/router/router.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
        return Scaffold(
          body: child,
          bottomNavigationBar: FBottomNavigationBar(
            index: tabRouter.activeIndex,
            onChange: tabRouter.setActiveIndex,
            children: const [
              FBottomNavigationBarItem(
                icon: Icon(FIcons.calendar),
                label: Text('Calendar'),
              ),
              FBottomNavigationBarItem(
                icon: Icon(FIcons.users),
                label: Text('Contacts'),
              ),
              FBottomNavigationBarItem(
                icon: Icon(FIcons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
        );
      },
    );
  }
}
