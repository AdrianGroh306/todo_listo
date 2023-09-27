import 'package:flutter/material.dart';
import 'package:todo/util/myButton.dart';

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
    return AlertDialog(backgroundColor: Theme.of(context).colorScheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: SizedBox(
        width: 250,
        height: 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "Add Todo",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.secondary),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: TextField(style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                autofocus: true,
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary, width: 2),
                  ),
                  hintText: "Add Task",
                ),
                onSubmitted: onSubmitted,
                cursorColor: Theme.of(context).colorScheme.primary,
                maxLines: 2,
                textInputAction:
                    TextInputAction.done, // Set TextInputAction to done
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyButton(
                  text: "Back",
                  onPressed: onCancel,
                  color: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).colorScheme.secondary,
                  borderRadius: 15,
                ),
                const SizedBox(width: 70),
                MyButton(
                  text: "Add",
                  onPressed: () => onSave(controller.text),
                  color: Theme.of(context).colorScheme.secondary,
                  textColor: Theme.of(context).colorScheme.primary,
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
