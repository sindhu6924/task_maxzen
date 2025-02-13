import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_maxzen/first.dart';
import 'package:task_maxzen/third.dart';

void main() async{
  Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyAkc9lwXXJs39QJoI31nGwLbBeBbSjbFYA",
          appId: "1:628793479106:web:cf39c247c3738442f5905b",
          messagingSenderId: "628793479106",
          projectId: "task-maxzen"));
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences=await SharedPreferences.getInstance();
  String? email=preferences.getString('email');

  await Supabase.initialize(
    url: "https://sthnbpntcbacbynulilq.supabase.co",
    anonKey:
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN0aG5icG50Y2JhY2J5bnVsaWxxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY1MTc3NTAsImV4cCI6MjA1MjA5Mzc1MH0.yiVcH2Jei0v85IFv-7uqcJHdXFYEm94PpsCF1iaKus4",
  );



  runApp(MyApp(email:email));
}


class MyApp extends StatelessWidget {
  final String? email;
  const MyApp({super.key,required this.email});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Digital_Attendance_Log',
      debugShowCheckedModeBanner: false,
      home: (email==null)?
      ui():(email=='admin@gmail.com')
          ?AdminAttendance(emails: email!):first_page(email: email!, texts: email!.substring(10)),

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

  Future<void> login(String email, String password) async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    if (email == 'admin@gmail.com') {
      Util().toast("Invalid Credentials");
      return;
    }

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setString("email", email);


        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                first_page(
                  email: emails.text.trim(),
                  texts: emails.text.trim()
                      .toString(),
                ),
          ),
        );

    } catch (err) {
      Util().toast("Invalid Credentials");
    }
  }
  @override
  void initState(){
    super.initState();

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

class ui extends StatefulWidget {

  const ui({super.key});

  @override
  State<ui> createState() => _uiState();
}

class _uiState extends State<ui> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(

        child: Container(

            height: 300,
            width: 400,
            padding: const EdgeInsets.all(10.0),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(40.0)),
              color: Colors.white,
            ),
            child:Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                ElevatedButton(style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2C3E50),
                    minimumSize: Size(190, 55),
                    shadowColor: Colors.grey,elevation: 12
                ),onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>log()));
                }, child: Text("Employee_Login",style: TextStyle(color: Colors.white,fontSize: 20,
                    fontFamily: 'Roboto'),)),
                SizedBox(
                  height: 80,
                ),
                ElevatedButton(style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2C3E50),
                    minimumSize: Size(210, 55),
                    shadowColor: Colors.grey,elevation: 12
                ),onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>adminlog()));

                }, child: Text("Admin_Login",style: TextStyle(color: Colors.white,fontSize: 20,
                    fontFamily: 'Roboto'),)),
              ],
            )
        ),
      ),
    );
  }
}


class adminlog extends StatefulWidget {
  const adminlog({super.key});

  @override
  State<adminlog> createState() => _adminlogState();
}

class _adminlogState extends State<adminlog> {
  @override
  TextEditingController emails = TextEditingController();
  TextEditingController passwords = TextEditingController();

  final _formkey = GlobalKey<FormState>();
  var _obscure = true;

  Future<void> login(String email, String password) async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );


      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setString("email", email);

      if(email=='admin@gmail.com'&& password=='Employee') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AdminAttendance(emails: email)
          ),
        );
      }else{
        Util().toast("Invalid Credentials");
      }
    } catch (err) {
      Util().toast("Invalid Credentials");
    }
  }
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