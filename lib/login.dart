import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_maxzen/main.dart';

class LoggedIn extends StatefulWidget {
  final String email; // Pass the user's email
  final String texts;

  const LoggedIn({super.key, required this.email, required this.texts});

  @override
  State<LoggedIn> createState() => _LoggedInState();
}

class _LoggedInState extends State<LoggedIn> {
  TextEditingController dateController = TextEditingController();
  bool isAttendanceMarked = false;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      print("Firebase initialized successfully");
    } catch (e) {
      print("Error initializing Firebase: $e");
    }
  }



  Future<void> checkAttendanceMarked(String date) async {
    try {
      final snapshot = await db
          .collection('Attendance')
          .where('Date', isEqualTo: date)
          .where('Email', isEqualTo: widget.email)
          .get();
      setState(() {
        isAttendanceMarked = snapshot.docs.isNotEmpty;
      });
      print("Attendance checked: Marked = $isAttendanceMarked");
    } catch (e) {
      print("Error checking attendance: $e");
    }
  }



  Future<void> markAttendance(String status) async {
    try {
      await db.collection('Attendance').add({
        'Date': dateController.text,
        'Email': widget.email,
        'Attendance': status,
      });
      print("Attendance marked successfully for ${widget.email} on ${dateController.text}.");
      setState(() {
        isAttendanceMarked = true;
      });
    } catch (e) {
      print("Error marking attendance: $e");
    }
  }



  Future<void> addToData(String date, String email, String attendance) async {
    try {
      await db.collection('Attendance').add({
        "Date": date,
        "Email": email,
        "Attendance": attendance,
      });
      print("Data added successfully");
    } catch (e) {
      print("Error adding data: $e");
    }
  }



  Future Logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove("emails");
    Fluttertoast.showToast(
        msg: "Logout successful",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16);
    Navigator.push(context, MaterialPageRoute(builder: (context) => log()));
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF2C3E50),
        actions: [
          IconButton(onPressed: (){
            setState(() {
              Logout();
            });
          }, icon: Icon(Icons.logout),color: Colors.white,)
        ],
        title: Text('ATTENDANCE APP',style: TextStyle(color: Colors.white,fontSize: 24,fontFamily: 'Roboto'),),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                      if (dateController.text.isNotEmpty) {
                        await checkAttendanceMarked(dateController.text);
                      }
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2C3E50),
                  minimumSize: Size(200, 60)
              ),
              onPressed: isAttendanceMarked || dateController.text.isEmpty
                  ? null
                  : () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      title: Text("${widget.texts.substring(0,10)} Mark your Attendance"
                        ,style: TextStyle(color: Color(0xFF2C3E50),fontSize: 19,fontFamily: 'Roboto',fontWeight: FontWeight.bold),
                      ),
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF2C3E50),
                                minimumSize: Size(90, 60),
                                foregroundColor: Colors.white
                            ),
                            onPressed: () {
                              markAttendance('Present');
                              Navigator.of(context).pop();
                            },
                            child: Text("Present",style: TextStyle(fontFamily: 'Roboto',fontSize: 18)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF2C3E50),
                                minimumSize: Size(90, 60),
                                foregroundColor: Colors.white
                            ),
                            onPressed: () {
                              markAttendance('Absent');
                              Navigator.of(context).pop();
                            },
                            child: Text("Absent",style: TextStyle(fontFamily: 'Roboto',fontSize: 18),),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Text(isAttendanceMarked
                  ? 'Attendance Already Marked'
                  : 'Mark Attendance',style: TextStyle(color: Colors.white,fontFamily: 'Roboto',fontSize: 18),),
            ),
            SizedBox(
              height: 60,
            ),
            Divider(),
            SizedBox(
              height: 30,
            ),
            Text(
              'ATTENDANCE HISTORY',
              style: TextStyle(fontFamily: 'Roboto',color: Color(0xFF2C3E50),fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 30,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: db
                  .collection("Attendance")
                  .where("Email", isEqualTo: widget.email) // Filter by logged-in user's email
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No attendance records found.'));
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListTile(

                          title: Text('Date: ${data['Date']}'),
                          subtitle: Text('Attendance: ${data['Attendance']}'),
                          tileColor: data['Attendance'] == 'Present'
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                        ),
                      );
                    },
                  );
                }
              },
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
