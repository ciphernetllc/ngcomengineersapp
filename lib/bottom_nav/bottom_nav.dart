// // custom_tab_bar.dart
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';

// import '../home/home.dart';
// import '../profile_settings/profile_settings.dart';
// import '../routes/installations.dart';
// import '../routes/surveys.dart';
// import '../routes/tickets.dart';

// class MainNavScreen extends StatefulWidget {
//   const MainNavScreen({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _MainNavScreenState createState() => _MainNavScreenState();
// }

// class _MainNavScreenState extends State<MainNavScreen> {
//   int _selectedIndex = 0;

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     switch (index) {
//       case 0:
//         // Navigator.pushNamed(context, '/home');
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const MainNavScreen()),
//         );
//         break;
//       case 1:
//         // Navigator.pushNamed(context, '/surveys');
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const Surveys()),
//         );
//         break;
//       case 2:
//         // Navigator.pushNamed(context, '/installations');
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const Installations()),
//         );
//         break;
//       case 3:
//         // Navigator.pushNamed(context, '/tickets');
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const Tickets()),
//         );
//         break;
//       case 4:
//         // Navigator.pushNamed(context, '/tickets');
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const ProfileSettingsPage()),
//         );
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FlashyTabBar(
//       selectedIndex: _selectedIndex,
//       showElevation: true,
//       onItemSelected: _onItemTapped,
//       items: [
//         FlashyTabBarItem(
//           icon: const Icon(
//             CupertinoIcons.home,
//             size: 25,
//           ),
//           title: const Text('Home'),
//         ),
//         FlashyTabBarItem(
//           icon: const Icon(
//             CupertinoIcons.square_stack,
//             size: 25,
//           ),
//           title: const Text('Surveys'),
//         ),
//         FlashyTabBarItem(
//           icon: const Icon(
//             CupertinoIcons.wrench,
//             size: 25,
//           ),
//           title: const Text('installs'),
//         ),
//         FlashyTabBarItem(
//           icon: const Icon(
//             CupertinoIcons.tickets,
//             size: 25,
//           ),
//           title: const Text('Tickets'),
//         ),
//         FlashyTabBarItem(
//           icon: const Icon(
//             CupertinoIcons.person,
//             size: 25,
//           ),
//           title: const Text('Profile'),
//         ),
//       ],
//     );
//   }
// }

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
// import '../home/home.dart';
// import '../profile_settings/profile_settings.dart';
// import '../routes/installations.dart';
// import '../routes/surveys.dart';
// import '../routes/tickets.dart';

// class MainNavScreen extends StatefulWidget {
//   const MainNavScreen({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _MainNavScreenState createState() => _MainNavScreenState();
// }

// class _MainNavScreenState extends State<MainNavScreen> {
//   int _selectedIndex = 0;

//   final List<Widget> _pages = [
//     const MainNavScreen(),
//     // const Surveys(),
//     // const Installations(),
//     // const Tickets(),
//     // const ProfileSettingsPage(),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _selectedIndex,
//         children: _pages,
//       ),
//       bottomNavigationBar: FlashyTabBar(
//         selectedIndex: _selectedIndex,
//         showElevation: true,
//         onItemSelected: _onItemTapped,
//         items: [
//           FlashyTabBarItem(
//             icon: const Icon(
//               CupertinoIcons.home,
//               size: 25,
//             ),
//             title: const Text('Home'),
//           ),
//           FlashyTabBarItem(
//             icon: const Icon(
//               CupertinoIcons.square_stack,
//               size: 25,
//             ),
//             title: const Text('Surveys'),
//           ),
//           FlashyTabBarItem(
//             icon: const Icon(
//               CupertinoIcons.wrench,
//               size: 25,
//             ),
//             title: const Text('Installations'),
//           ),
//           FlashyTabBarItem(
//             icon: const Icon(
//               CupertinoIcons.tickets,
//               size: 25,
//             ),
//             title: const Text('Tickets'),
//           ),
//           FlashyTabBarItem(
//             icon: const Icon(
//               CupertinoIcons.person,
//               size: 25,
//             ),
//             title: const Text('Profile'),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import '../home/home.dart';
import '../profile_settings/profile_settings.dart';
import '../routes/installations.dart';
import '../routes/surveys.dart';
import '../routes/tickets.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainNavScreenState createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const NavigatorTab(child: MainScreen()),
    const NavigatorTab(child: Surveys()),
    const NavigatorTab(child: Installations()),
    const NavigatorTab(child: Tickets()),
    const NavigatorTab(child: ProfileSettingsPage()),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: FlashyTabBar(
        selectedIndex: _selectedIndex,
        showElevation: true,
        onItemSelected: _onItemTapped,
        items: [
          FlashyTabBarItem(
            icon: const Icon(
              CupertinoIcons.home,
              size: 25,
            ),
            title: const Text('Home'),
          ),
          FlashyTabBarItem(
            icon: const Icon(
              CupertinoIcons.square_stack,
              size: 25,
            ),
            title: const Text('Surveys'),
          ),
          FlashyTabBarItem(
            icon: const Icon(
              CupertinoIcons.wrench,
              size: 25,
            ),
            title: const Text('Install'),
          ),
          FlashyTabBarItem(
            icon: const Icon(
              CupertinoIcons.tickets,
              size: 25,
            ),
            title: const Text('Tickets'),
          ),
          FlashyTabBarItem(
            icon: const Icon(
              CupertinoIcons.person,
              size: 25,
            ),
            title: const Text('Profile'),
          ),
        ],
      ),
    );
  }
}

class NavigatorTab extends StatelessWidget {
  final Widget child;

  const NavigatorTab({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => child,
        );
      },
    );
  }
}

// class MainNavScreen extends StatefulWidget {
//   const MainNavScreen({super.key});

//   @override
//   _MainNavScreenState createState() => _MainNavScreenState();
// }

// class _MainNavScreenState extends State<MainNavScreen> {
//   int _selectedIndex = 0;

//   final List<GlobalKey<NavigatorState>> _navigatorKeys = [
//     GlobalKey<NavigatorState>(),
//     GlobalKey<NavigatorState>(),
//     GlobalKey<NavigatorState>(),
//     GlobalKey<NavigatorState>(),
//     GlobalKey<NavigatorState>(),
//   ];

//   final List<Widget> _pages = [
//     const MainScreen(),
//     const Surveys(),
//     const Installations(),
//     const Tickets(),
//     const ProfileSettingsPage(),
//   ];

//   void _onItemTapped(int index) {
//     if (index == _selectedIndex) {
//       _navigatorKeys[index].currentState!.popUntil((route) => route.isFirst);
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _selectedIndex,
//         children: _pages
//             .asMap()
//             .map((index, page) => MapEntry(
//                   index,
//                   Navigator(
//                     key: _navigatorKeys[index],
//                     onGenerateRoute: (routeSettings) {
//                       return MaterialPageRoute(
//                         builder: (context) => page,
//                       );
//                     },
//                   ),
//                 ))
//             .values
//             .toList(),
//       ),
//       bottomNavigationBar: FlashyTabBar(
//         selectedIndex: _selectedIndex,
//         showElevation: true,
//         onItemSelected: _onItemTapped,
//         items: [
//           FlashyTabBarItem(
//             icon: const Icon(
//               CupertinoIcons.home,
//               size: 25,
//             ),
//             title: const Text('Home'),
//           ),
//           FlashyTabBarItem(
//             icon: const Icon(
//               CupertinoIcons.square_stack,
//               size: 25,
//             ),
//             title: const Text('Surveys'),
//           ),
//           FlashyTabBarItem(
//             icon: const Icon(
//               CupertinoIcons.wrench,
//               size: 25,
//             ),
//             title: const Text('Installations'),
//           ),
//           FlashyTabBarItem(
//             icon: const Icon(
//               CupertinoIcons.tickets,
//               size: 25,
//             ),
//             title: const Text('Tickets'),
//           ),
//           FlashyTabBarItem(
//             icon: const Icon(
//               CupertinoIcons.person,
//               size: 25,
//             ),
//             title: const Text('Profile'),
//           ),
//         ],
//       ),
//     );
//   }
// }
