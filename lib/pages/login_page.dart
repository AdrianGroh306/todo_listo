import 'package:flutter/material.dart';
import 'package:todo/pages/homepage.dart';

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
                  Icons.notes_rounded,
                  size: 150,
                ),

                const SizedBox(
                  height: 10,
                ),

                //welcome message
                const Text(
                  "Welcome back, u have been missed <3",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

                //email textfield
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "email",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),

                //password textfield
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "password",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                // sign in button
                SizedBox(
                  height: 50,
                  width: 250,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          )),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.black)),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyHomePage()));
                      },
                      child: const Text("Sign In")),
                )
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
