// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';

import 'hoverbtn.dart';

class MyCards extends StatelessWidget {
  final icon;
  final color;
  final String exerciseName;
  final String numberOfExercise;

  const MyCards(
      {super.key,
      required this.icon,
      required this.color,
      required this.exerciseName,
      required this.numberOfExercise});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    color: color,
                    child: Icon(
                      Icons.favorite,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    //title
                    Text(
                      exerciseName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    SizedBox(
                      height: 5,
                    ),

                    //subtitle
                    Text(
                      numberOfExercise.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            HoverBtn(),
          ],
        ),
      ),
    );
  }
}
