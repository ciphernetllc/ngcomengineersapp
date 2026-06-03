import 'package:flutter/material.dart';

import '../components/listcards.dart';
import 'surveys.dart';

class MyNotification extends StatelessWidget {
  const MyNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 30),
        child: Container(
          padding: const EdgeInsets.all(15),
          child: AppBar(
            leading: const CircleAvatar(
              backgroundImage: AssetImage('lib/images/apple.png'),
            ),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning,',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'John Doe',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            // actions: [
            //   Stack(
            //     children: [
            //       IconButton(
            //         icon: const Icon(Icons.notifications),
            //         onPressed: () {
            //           // Handle notification icon tap
            //         },
            //       ),
            //       Positioned(
            //         right: 8,
            //         top: 8,
            //         child: Container(
            //           padding: const EdgeInsets.all(4),
            //           decoration: BoxDecoration(
            //             color: Colors.red,
            //             borderRadius: BorderRadius.circular(10),
            //           ),
            //           constraints: const BoxConstraints(
            //             minWidth: 16,
            //             minHeight: 16,
            //           ),
            //           child: const Text(
            //             '5',
            //             style: TextStyle(
            //               color: Colors.white,
            //               fontSize: 12,
            //             ),
            //             textAlign: TextAlign.center,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Navigator.pushNamed(context, '/remiderdetails');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Surveys()),
                      );
                    },
                    child: const MyCards(
                      icon: Icons.timer,
                      exerciseName: 'Fuel purchase successful',
                      numberOfExercise: 'Fuel Purchase ',
                      color: Colors.grey,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/remiderdetails');
                    },
                    child: const MyCards(
                      icon: Icons.build_rounded,
                      exerciseName: 'Vehicle Maintenance',
                      numberOfExercise: 'Reminder ',
                      color: Colors.grey,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/remiderdetails');
                    },
                    child: const MyCards(
                      icon: Icons.confirmation_number,
                      exerciseName: 'Canceled Reminder',
                      numberOfExercise: '13',
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
