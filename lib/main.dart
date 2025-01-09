import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:task_maxzen/login.dart';

void main() {

  Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyAkc9lwXXJs39QJoI31nGwLbBeBbSjbFYA",
      appId: "1:628793479106:web:cf39c247c3738442f5905b",
      messagingSenderId: "628793479106",
      projectId: "task-maxzen"));
  WidgetsFlutterBinding.ensureInitialized();
   Firebase.initializeApp();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: log(),
    );
  }
}


class log extends StatefulWidget {
  const log({super.key});

  @override
  State<log> createState() => _logState();
}

class _logState extends State<log> {
  TextEditingController emails = TextEditingController();
  TextEditingController passwords = TextEditingController();

  final _formkey = GlobalKey<FormState>();
  var _obscure = true;

  Future login(String Email,String Password)async{
    final FirebaseAuth auth=FirebaseAuth.instance;
    try{
      auth.signInWithEmailAndPassword(email: Email, password: Password).then((value){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>LoggedIn(email: emails.text.trim(),texts:emails.text.trim().toString()
             )));
      }).onError((error, stackTrace) {Util().toast("Invalid Credentials");});
    }catch(err) {
      throw Exception(err);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2C3E50),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 180,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Stack(
                children: [
                  ClipPath(
                    child: Container(
                      height: 400,
                      padding: const EdgeInsets.all(10.0),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(40.0)),
                        color: Colors.white,
                      ),
                      child: Form(
                        key: _formkey,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const SizedBox(
                                height: 90.0,
                              ),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: TextFormField(
                                    style: const TextStyle(color: Colors.black),
                                    controller: emails,
                                    validator: (val) => val!.length == 0
                                        ? "Enter the email"
                                        : null,
                                    decoration: InputDecoration(
                                        hintText: "Email address",
                                        hintStyle: TextStyle(
                                          color: Colors.black,
                                        ),
                                        icon: const Icon(
                                          Icons.email,
                                          color:
                                          Color(0xFF2C3E50),
                                        )),
                                  )),
                              Container(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20.0, bottom: 10.0),
                              ),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: TextFormField(
                                    controller: passwords,
                                    validator: (val) => val!.length == 0
                                        ? "Enter the password"
                                        : null,
                                    obscureText: _obscure,
                                    style: const TextStyle(color: Colors.black),
                                    obscuringCharacter: ".",
                                    decoration: InputDecoration(
                                        hintText: "Password",
                                        suffixIcon: IconButton(
                                          icon: _obscure
                                              ? const Icon(Icons.visibility_off)
                                              : const Icon(Icons.visibility),
                                          onPressed: () {
                                            setState(() {
                                              _obscure = !_obscure;
                                            });
                                          },
                                        ),
                                        hintStyle: TextStyle(
                                          color: Colors.black,
                                        ),
                                        icon: const Icon(
                                          Icons.lock,
                                          color:
                                          Color(0xFF2C3E50),
                                        )),
                                  )),
                              Container(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20.0, bottom: 10.0),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      padding:
                                      const EdgeInsets.only(right: 20.0),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                            ]),
                      ),
                    ),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 38.0,
                        backgroundColor: Color(0xFF2C3E50),
                        child: Icon(
                          size: 32,
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 420,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(26, 48),
                          shape: RoundedRectangleBorder(

                              borderRadius: BorderRadius.circular(32.0)),
                          backgroundColor: Color(0xFFECF0F1),
                        ),
                        onPressed: () {

                          if (_formkey.currentState!.validate()){
                            setState(() {
                              login(emails.text.trim(), passwords.text.trim());

                            });
                          }
                            },
                        child: const Text("Login",
                            style: TextStyle(color:Color(0xFF2C3E50),fontSize: 18,fontWeight: FontWeight.bold,fontFamily: 'Roboto')),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),

    );
  }
}
class Util {
  void toast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }
}