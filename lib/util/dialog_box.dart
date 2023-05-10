import 'package:flutter/material.dart';
import 'package:todo/util/my_button.dart';

class DialogBox extends StatelessWidget {
  final controller;
  VoidCallback onSave;
  VoidCallback onCancel;
  DialogBox({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: 200,
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //Get user input
            Expanded(
              child: TextField(
                autofocus: true,
                controller: controller,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: "Add Task"),
                maxLines: 3,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // cancel button
                MyButton(text: "Cancel", onPressed: onCancel),
                // save button
                MyButton(text: "Save", onPressed: onSave),
              ],
            )
            //button - save + cancel
          ],
        ),
      ),
    );
  }
}
