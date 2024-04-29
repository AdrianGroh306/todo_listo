import 'package:TodoListo/util/myButton.dart';
import 'package:flutter/material.dart';

class DialogBox extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String?) onSave;
  final VoidCallback onCancel;
  final void Function(String?) onSubmitted;

  const DialogBox({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.background,
      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Center(
        child: Text(
          "Add Todo",
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: TextField(
        style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            decoration: TextDecoration.none),
        autofocus: true,
        controller: controller,
        cursorColor: Theme.of(context).colorScheme.secondary,
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
          hintText: "Todo...",
        ),
        onSubmitted: onSubmitted,
        maxLines: 2,
        textInputAction: TextInputAction.done,
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20),
      actions: <Widget>[
        const SizedBox(
          height: 20,
        ),
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
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
