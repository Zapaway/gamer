import 'package:flutter/material.dart';
import 'package:gamer/screens/app/home.dart';
import 'package:gamer/screens/app/search.dart';
import 'package:gamer/shared/consts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

/// Screen containing both home and search pages.
class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final _controller = PersistentTabController(initialIndex: 0);

  @override
  Widget build(BuildContext context) {
    PersistentBottomNavBarItem createBottomNavBarItem(Icon icon) {
      return PersistentBottomNavBarItem(
        icon: icon,
        iconSize: 35,
        activeColorPrimary: AppColors.lightTurquoise,
        inactiveColorPrimary: AppColors.turquoise,
      );
    }

    return PersistentTabView(
      context,
      controller: _controller,
      screens: const [
        Home(),
        Search(),
      ],
      items: [
        createBottomNavBarItem(const Icon(Icons.home)),
        createBottomNavBarItem(const Icon(Icons.search)),
      ],
      navBarStyle: NavBarStyle.style5,
      confineInSafeArea: true,
      navBarHeight: 100,
      bottomScreenMargin: 0,
      backgroundColor: Colors.transparent,
    );

    // return StreamProvider<UserDataModel?>.value(
    //   initialData: null,
    //   value: userModel != null
    //     ? DatabaseService(userModel: userModel).userDataStream
    //     : null,
    //   child: PersistentTabView(
    //     context,
    //     controller: _controller,
    //     screens: const [
    //       Home(),
    //       Search(),
    //     ],
    //     items: [
    //       createBottomNavBarItem(const Icon(Icons.home)),
    //       createBottomNavBarItem(const Icon(Icons.search)),
    //     ],
    //     navBarStyle: NavBarStyle.style5,
    //     confineInSafeArea: true,
    //     navBarHeight: 100,
    //     bottomScreenMargin: 0,
    //     backgroundColor: Colors.transparent,
    //   ),
    // );
  }
}

