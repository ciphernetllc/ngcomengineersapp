import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/login_screen.dart';
import '../bottom_nav/bottom_nav.dart';
import '../models/userdata.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller!, curve: Curves.easeOut);

    _controller?.forward();
    _checkLoginState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _checkLoginState() async {
    await Future.delayed(const Duration(seconds: 6));
    _controller?.reverse();

    await Future.delayed(
        const Duration(milliseconds: 1000)); // wait for fade-out to complete

    // ignore: use_build_context_synchronously
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // Wait for user data to be loaded
    await Future.delayed(const Duration(seconds: 1));
    // Debug print to check login status
    // print('Is user logged in? ${userProvider.isLoggedIn}');
    // Check if the user is logged in using the isLoggedIn property
    if (userProvider.isLoggedIn) {
      // Navigator.pushNamed(context, '/home');
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const MainNavScreen()),
      );
    } else {
      // Navigator.pushNamed(context, '/login');
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _animation!,
        child: Center(
          child: Image.asset(
            'lib/images/ngcom.png',
            height: 200,
            width: 300,
          ),
        ),
      ),
    );
  }
}
