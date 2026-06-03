import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class CustomListTile extends StatelessWidget {
  final String tileicons;
  final String maintext;
  final String subtext;
  const CustomListTile({
    super.key,
    required this.tileicons,
    required this.maintext,
    required this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
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
                            color: Colors.deepOrange, shape: BoxShape.circle),
                      ),
                      const Icon(
                        CupertinoIcons.cube_box,
                        color: Colors.white,
                      )
                    ],
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        maintext,
                        style: TextStyle(
                            fontSize: 18,
                            color: primaryColor,
                            fontWeight: FontWeight.w700),
                      ),
                      Text(
                        subtext,
                        style: const TextStyle(
                            fontSize: 14,
                            // color: primaryColor,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ],
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    CupertinoIcons.greaterthan_circle,
                    color: Colors.grey,
                    size: 20,
                    weight: 20,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
