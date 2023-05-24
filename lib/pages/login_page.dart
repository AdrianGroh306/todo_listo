import 'package:flutter/material.dart';
import 'package:todo/pages/homepage.dart';
import 'package:todo/util/square_tile.dart';

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
                  height: 100,
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
                    fontSize: 16,color: Colors.white70
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

                //email textfield
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "email",
                      hintStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),

                //password textfield
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "password",
                      hintStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),


                ),
                //forget password text
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                // sign in button
                SizedBox(
                  height: 60,
                  width: 360,
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
                ),

                const SizedBox(
                  height: 30,
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
                        child: Text("Or continue with",style: TextStyle(color: Colors.white70),),
                      ),
                      Expanded(
                          child: Divider(
                        thickness: 0.8,
                        color: Colors.white70,
                      )),
                    ],
                  ),
                ),

                const SizedBox(height: 30,),

                //google/apple tile
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(imagePath: "images/google_logo.png"),
                    SizedBox(width: 50,),
                    SquareTile(imagePath: "images/apple_logo.png"),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
