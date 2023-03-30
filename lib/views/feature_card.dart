import 'package:flutter/material.dart';
import 'package:myassistant/my_colors.dart';

class FeatureCard extends StatelessWidget {
  final Color color;
  final String headerText;
  final String descText;
  const FeatureCard(
      {super.key,
      required this.color,
      required this.headerText,
      required this.descText});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        color: color,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                headerText,
                style: const TextStyle(
                    fontFamily: 'Cera Pro',
                    color: MyColors.blackColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              descText,
              style: const TextStyle(
                  fontFamily: 'Cera Pro',
                  color: MyColors.blackColor),
            ),
          ],
        ),
      ),
    );
  }
}
