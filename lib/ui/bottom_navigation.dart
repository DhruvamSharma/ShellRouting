import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigationWidget extends StatelessWidget {
  const BottomNavigationWidget({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: navigationShell.currentIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'UniKonnect',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'UniGen',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.verified_user),
          label: 'UniProfile',
        ),
      ],
      onTap: _goBranch,
    );
  }

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // A common pattern when using bottom navigation bars is to support
      // navigating to the initial location when tapping the item that is
      // already active. This example demonstrates how to support this behavior,
      // using the initialLocation parameter of goBranch.
      initialLocation: index == navigationShell.currentIndex,
    );

    /// if you want to refresh the branch when the same item is tapped
    /// you can use the your router wrapper (AppRouter, in our case) and
    /// call context.go with the name or path of the branch's [initialLocation]
    /// with maintainState: false
  }
}
