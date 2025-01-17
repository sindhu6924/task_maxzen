import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_maxzen/main.dart';


class AdminAttendance extends StatefulWidget {
  final String emails;
  const AdminAttendance({super.key,required this.emails});

  @override

  State<AdminAttendance> createState() => _AdminAttendanceState();
}

class _AdminAttendanceState extends State<AdminAttendance> {

  final FirebaseFirestore db = FirebaseFirestore.instance;
  String mail='';
  Future getEmail() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      mail = preferences.getString("emails") ?? '';
    });
  }

  Future Logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('email');
    Fluttertoast.showToast(
        msg: "Logout successful",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16);
   Navigator.push(context, MaterialPageRoute(builder: (context)=>ui()));

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
  void initState() {
    super.initState();
    getEmail();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SharedPreferences.getInstance().then((prefs) {
        final isLoggedIn = prefs.getString("emails") != null;
        if (!isLoggedIn) {
          Navigator.pushReplacementNamed(context, "/ui"); // Redirect to login
        }
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(onPressed: (){
              Logout();
            }, icon:Icon(Icons.logout),color: Colors.white,)
          ],
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blueGrey,
          title: const Text('Admin Attendance',style: TextStyle(
              fontSize: 18,
              color: Colors.white,fontFamily: 'Roboto',
              fontWeight:FontWeight.bold),),),


        body: StreamBuilder<QuerySnapshot>(
          stream: db.collection('Attendance').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No attendance records found.'),
              );
            }

            // Extract documents from the snapshot
            final attendanceDocs = snapshot.data!.docs;

            return ListView.builder(
              itemCount: attendanceDocs.length,
              itemBuilder: (context, index) {
                final doc = attendanceDocs[index];
                final data = doc.data() as Map<String, dynamic>;

                final date = data['Date'] ?? 'Unknown Date';
                final attendanceStatus = data['Attendance'] ?? 'Unknown';
                final imagePath = data['imagepath'];
                final mail=data['Email'];

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    child: ListTile(
                      leading: imagePath != null
                          ? Image.network(
                        imagePath,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported),
                      )
                          : const Icon(Icons.image_not_supported),
                      title: Column(
                        children: [
                          Text('Date: $date'),
                          Text(mail.toString().substring(0,10)),
                        ],
                      ),
                      subtitle: Center(child: Text('Attendance: $attendanceStatus')),
                      tileColor: attendanceStatus == 'Check_In'
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
