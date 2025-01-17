import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_maxzen/main.dart';
import 'package:task_maxzen/second.dart';

class first_page extends StatefulWidget {
  final String email;
  final String texts;
  const first_page({super.key,required this.email,required this.texts});


  @override
  State<first_page> createState() => _first_pageState();
}

class _first_pageState extends State<first_page> {
  TextEditingController dateController=TextEditingController();
  String mail='';
  String textss='';
  Future getEmail() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      mail = preferences.getString("email").toString();
      textss=preferences.getString("texts").toString();
    });
  }
  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Exit"),
        content: const Text("Do you want to exit the app?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => exit(0),
            child: const Text("Yes"),
          ),
        ],
      ),
    ) ?? false;
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.blueGrey,
        body: Column(
          mainAxisAlignment:MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 90,
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Center(
                child: Container(

                  height: 300,
                  width: 300,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius:BorderRadius.all(Radius.circular(40.0))
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text('     Welcome ${widget.email.toString().substring(0,10)}\n Please mark your attendance.',style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,fontFamily: 'Robo++to',
                          fontWeight:FontWeight.bold),),
                      Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: TextField(
                          controller: dateController,
                          decoration: InputDecoration(
                            filled: true,
                            labelText: 'Select Date',
                            prefixIcon: GestureDetector(
                              onTap: () async {
                                await selectDate(context);
                              },
                              child: Icon(Icons.calendar_today_outlined),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                          ),
                          readOnly: true,
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Center(child: ElevatedButton(style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                    ),onPressed:
                      dateController.text.isEmpty?null:(){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>LoggedIn(emails: widget.email,
                          textsss: widget.texts,selectedDate: dateController.text,
                        )));
                      }, child: Text("Mark Your Attendance",style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto',
                          fontSize: 16
                      ),))),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });

    }
  }
}