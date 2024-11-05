import 'package:TodoListo/util/myButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class DialogBox {
  final TextEditingController controller;
  final void Function(String?) onSave;
  final VoidCallback onCancel;
  final void Function(String?) onSubmitted;
  final FocusNode _focusNode = FocusNode();

  DialogBox({
    required this.controller,
    required this.onSave,
    required this.onCancel,
    required this.onSubmitted,
  });

  void show(BuildContext context) {
    SmartDialog.show(
      alignment: Alignment.center,
      useAnimation: false,
      builder: (context) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {

            bool isKeyboardOpen = constraints.maxHeight <
                MediaQuery.of(context).size.height * 0.8;

            return Padding(
              padding: EdgeInsets.only(
                bottom: isKeyboardOpen ? 400 : 0,
              ),
              child: SafeArea(
                child: _buildCustomDialog(context),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCustomDialog(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
            width: 2,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add Todo",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                focusNode: _focusNode,
                autofocus: true,
                cursorColor: Theme.of(context).colorScheme.secondary,
                style: TextStyle(
                  decoration: TextDecoration.none,
                  decorationThickness: 0,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                  hintText: "Todo...",
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                onSubmitted: (value) {
                  onSubmitted(value);
                  SmartDialog.dismiss();
                },
                maxLines: 2,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MyButton(
                    text: "Back",
                    onPressed: () {
                      onCancel();
                      SmartDialog.dismiss();
                    },
                    color: Theme.of(context).colorScheme.primary,
                    textColor: Theme.of(context).colorScheme.secondary,
                    borderRadius: 15,
                  ),
                  const SizedBox(width: 70),
                  MyButton(
                    text: "Add",
                    onPressed: () {
                      onSave(controller.text);
                      SmartDialog.dismiss();
                    },
                    color: Theme.of(context).colorScheme.secondary,
                    textColor: Theme.of(context).colorScheme.primary,
                    borderRadius: 15,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void dispose() {
    _focusNode.dispose();
  }
}
