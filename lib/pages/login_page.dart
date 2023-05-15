import 'package:flutter/material.dart';
import 'package:todo/util/my_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blueAccent, Colors.tealAccent])),
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 120,
                ),

                //logo
                const Icon(
                  Icons.edit_note,
                  size: 150,
                ),

                const SizedBox(
                  height: 20,
                ),

                //welcome message
                const Text(
                  "Welcome back, u have been missed <3",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),

                //password textfield

                // sign in button

              //ElevatedButton(onPressed: onPressed, child: child)

                //go to register page
              ],
            ),
          ),
        ),
      ),
    );
  }
}
