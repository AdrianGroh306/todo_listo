import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;
  const SquareTile({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(border: Border.all(color: Colors.white30,width: 3),
        borderRadius: BorderRadius.circular(20),
        color: Colors.white30),
      child: Image.asset(imagePath,height: 50,),
    );
  }
}
