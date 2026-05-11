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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          body: child,
          bottomNavigationBar: FBottomNavigationBar(
            index: tabRouter.activeIndex,
            onChange: tabRouter.setActiveIndex,
            // In dark mode, lift the nav bar above the page background so it
            // doesn't blend in. Light mode keeps forui's default surface.
            style: isDark
                ? FBottomNavigationBarStyleDelta.delta(
                    decoration: DecorationDelta.boxDelta(
                      color: context.theme.colors.secondary,
                    ),
                  )
                : const FBottomNavigationBarStyleDelta.context(),
            children: const [
              FBottomNavigationBarItem(
                icon: Icon(FIcons.history),
                label: Text('History'),
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
