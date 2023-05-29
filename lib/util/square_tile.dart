import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;
  final Function()? onTap;

  const SquareTile({
    super.key,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(border: Border.all(color: Colors.white30,width: 3),
          borderRadius: BorderRadius.circular(20),
          color: Colors.white30),
        child: Image.asset(imagePath,height: 50,),
      ),
    );
  }
}
