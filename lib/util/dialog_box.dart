import 'package:flutter/material.dart';
import 'package:todo/util/my_button.dart';

class DialogBox extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String?) onSave;
  final VoidCallback onCancel;
  final void Function(String?) onSubmitted;

  DialogBox({
    required this.controller,
    required this.onSave,
    required this.onCancel,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: SizedBox(
        width: 250,
        height: 140,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: TextField(
                autofocus: true,
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.indigo[700]!, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.indigo[700]!, width: 2),
                  ),
                  hintText: "Add Task",
                ),
                onSubmitted: onSubmitted,
                cursorColor: Colors.indigo[700],
                maxLines: 3,
                textInputAction: TextInputAction.done, // Set TextInputAction to done
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyButton(
                  text: "Back",
                  onPressed: onCancel,
                  color: Colors.white,
                  textColor: Colors.indigo[700],
                  borderRadius: 15,
                ),
                const SizedBox(width: 70),
                MyButton(
                  text: "Add",
                  onPressed: () => onSave(controller.text),
                  color: Colors.indigo[700],
                  textColor: Colors.white,
                  borderRadius: 15,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
