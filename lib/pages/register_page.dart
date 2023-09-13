import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo/util/MyTextField.dart';
import 'package:todo/util/square_tile.dart';

import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordconfirmController = TextEditingController();

// sign up method
  void signUserUp() async {
    //show loading circle
    showDialog(
        context: (context),
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
    //try creating the user
    try {
      //check if password is confirmed
      if (passwordController.text == passwordconfirmController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      } else {
        // show error password NOT confirmed
        showErrorMessage("Password does not match");
      }
      //pop the loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //pop the loading circle
      Navigator.pop(context);
      showErrorMessage(e.code);
    }
  }

  // error message to user
  void showErrorMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(
              child: Text(
                message,
              ),
            ),
          );
        });
  }

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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 50,
                  ),

                  //logo
                  const Icon(
                    Icons.notes_rounded,
                    color: Colors.indigo,
                    shadows: <Shadow>[
                      Shadow(color: Colors.black45, blurRadius: 30.0)
                    ],
                    size: 150,
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  //welcome message
                  const Text(
                    "Let's create an account for you :D",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  //email textfield
                  MyTextField(
                    controller: emailController,
                    hintText: "Email",
                    obscureText: false,
                  ),

                  //password textfield
                  MyTextField(
                    controller: passwordController,
                    hintText: "Password",
                    obscureText: true,
                  ),
                  //password confirm textfield
                  MyTextField(
                    controller: passwordconfirmController,
                    hintText: "Confirm Password",
                    obscureText: true,
                  ),
                  //forget password text

                  const SizedBox(
                    height: 25,
                  ),

                  // sign up button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              )),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.indigo)),
                          onPressed: () {
                            signUserUp();
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                    ),
                  ),

                  const SizedBox(
                    height: 35,
                  ),

                  //divder or text
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      children: [
                        Expanded(
                            child: Divider(
                          thickness: 0.8,
                          color: Colors.white70,
                        )),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Or continue with",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        Expanded(
                            child: Divider(
                          thickness: 0.8,
                          color: Colors.white70,
                        )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  //google/apple tile
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SquareTile(
                        imagePath: "images/google_logo.png",
                        onTap: () => AuthService().signInWithGoogle(),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      SquareTile(
                        imagePath: "images/apple_logo.png",
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 45,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 60,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            "Login now",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
