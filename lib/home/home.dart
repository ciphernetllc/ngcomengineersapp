// import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bottom_nav/bottom_nav.dart';
import '../components/hoverbtn.dart';
import '../constants.dart';
import '../models/userdata.dart';
import '../profile_settings/profile_settings.dart';
import '../routes/installations.dart';
import '../routes/surveys.dart';
import '../routes/tickets.dart';

// import '../../../data/data.dart';

// class MainScreen extends StatelessWidget {
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

// const MainScreen({super.key});
class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: Consumer<UserProvider>(builder: (context, userProvider, child) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.deepOrange),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ProfileSettingsPage()));
                              },
                              child: const Icon(
                                CupertinoIcons.person_fill,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome!",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor),
                            ),
                            Text(
                              "${userProvider.firstname}",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor),
                            )
                          ],
                        ),
                      ],
                    ),
                    const HoverBtn(),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width / 2,
                  decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 4,
                            color: Colors.grey.shade200,
                            offset: const Offset(5, 5))
                      ]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Total Activities',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                      // const SizedBox(height: 4),
                      const Text(
                        '57',
                        style: TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 25,
                                  height: 25,
                                  decoration: const BoxDecoration(
                                      color: Colors.white30,
                                      shape: BoxShape.circle),
                                  child: const Center(
                                      child: Icon(
                                    CupertinoIcons.arrow_down,
                                    size: 12,
                                    color: Colors.greenAccent,
                                  )),
                                ),
                                const SizedBox(width: 8),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Executed',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      '20',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 25,
                                  height: 25,
                                  decoration: const BoxDecoration(
                                      color: Colors.white30,
                                      shape: BoxShape.circle),
                                  child: const Center(
                                      child: Icon(
                                    CupertinoIcons.arrow_up,
                                    size: 12,
                                    color: Colors.red,
                                  )),
                                ),
                                const SizedBox(width: 8),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pending',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      '37',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Activities',
                      style: TextStyle(
                          fontSize: 18,
                          color: primaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Surveys()),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: const BoxDecoration(
                                                color: Colors.deepOrange,
                                                shape: BoxShape.circle),
                                          ),
                                          const Icon(
                                            CupertinoIcons.square_stack,
                                            color: Colors.white,
                                          )
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Site Surveys',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: primaryColor,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '57',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Pending',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: primaryColor,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Installations()),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: const BoxDecoration(
                                                color: Colors.deepOrange,
                                                shape: BoxShape.circle),
                                          ),
                                          const Icon(
                                            CupertinoIcons.wrench,
                                            color: Colors.white,
                                          )
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Installation Report',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: primaryColor,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '0',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Pending',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: primaryColor,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Tickets()),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: const BoxDecoration(
                                                color: Colors.deepOrange,
                                                shape: BoxShape.circle),
                                          ),
                                          const Icon(
                                            CupertinoIcons.ticket,
                                            color: Colors.white,
                                          )
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Tickets',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: primaryColor,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '0',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Pending',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: primaryColor,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
