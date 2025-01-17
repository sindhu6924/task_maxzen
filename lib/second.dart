import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_maxzen/main.dart';

class LoggedIn extends StatefulWidget {
  final String emails;
  final String textsss;
  final String selectedDate;
  const LoggedIn({super.key, required this.emails, required this.textsss,required this.selectedDate});

  @override
  State<LoggedIn> createState() => _LoggedInState();
}

class _LoggedInState extends State<LoggedIn> {
  String mail='';
  String textss='';
  String dates='';
  Future getEmail() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      mail = preferences.getString("emails").toString();
      textss=preferences.getString("textsss").toString();
    });
  }
  TextEditingController dateController = TextEditingController();
  bool isAttendanceMarkedin = false;
  bool isAttendanceMarkedout=false;

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    dates=widget.selectedDate;
    _initializeFirebase();
    checkAttendanceMarkedin(dates);
    checkAttendanceMarkedout(dates);
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      print("Firebase initialized successfully");
    } catch (e) {
      print("Error initializing Firebase: $e");
    }
  }



  Future<void> checkAttendanceMarkedin(String date) async {
    try {
      final snapshot = await db
          .collection('Attendance')
          .where('Date', isEqualTo: date)
          .where('Email', isEqualTo: widget.emails)
          .where('Attendance', isEqualTo: 'Check_In')
          .get();
      setState(() {
        isAttendanceMarkedin = snapshot.docs.isNotEmpty;
        _isImageSelected = _selectedImage != null;
      });
      print("Attendance checked: Marked = $isAttendanceMarkedin");
    } catch (e) {
      print("Error checking attendance: $e");
    }
  }
  Future<void> checkAttendanceMarkedout(String date) async {
    try {
      final snapshot = await db
          .collection('Attendance')
          .where('Date', isEqualTo: date)
          .where('Email', isEqualTo: widget.emails).
      where('Attendance', isEqualTo: 'Check_Out')
          .get();
      setState(() {
        isAttendanceMarkedout = snapshot.docs.isNotEmpty;
        _isImageSelected = _selectedImage != null;
      });
      print("Attendance checked: Marked = $isAttendanceMarkedout");
    } catch (e) {
      print("Error checking attendance: $e");
    }
  }


  Future<void> markAttendance(String status, String attendanceType) async {
    try {
      final snapshot = await db
          .collection('Attendance')
          .where('Date', isEqualTo: dates)
          .where('Email', isEqualTo: widget.emails)
          .where('Attendance', isEqualTo: status)
          .get();

      if (snapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$attendanceType already marked for today')),
        );
        return;
      }
      String currentTime = DateFormat('hh:mm a').format(DateTime.now());
      await db.collection('Attendance').add({
        'Date': dates,
        'Email': widget.emails,
        'Attendance': status,
        'Time':currentTime,
        'imagepath':_uploadedImageUrl,
      });

      setState(() {
        if (attendanceType == 'Check_In') isAttendanceMarkedin = true;
        if (attendanceType == 'Check_Out') isAttendanceMarkedout = true;
        _selectedImage = null;
        _uploadedImageUrl = null;
        _isImageSelected = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$attendanceType marked successfully!')),
      );
      print("$attendanceType marked successfully for ${widget.emails} on $dates.");
    } catch (e) {
      print("Error marking $attendanceType: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking $attendanceType')),
      );
    }
  }



  Future Logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove("email");
    Fluttertoast.showToast(
        msg: "Logout successful",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16);
    Navigator.push(context, MaterialPageRoute(builder: (context) => ui()));
  }



  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isImageSelected = false;
  bool isCheckInButtonDisabled = false;
  bool isCheckOutButtonDiaabled=false;




  @override
  Widget build(BuildContext context) {
    double Width = MediaQuery.of(context).size.width;
    double Height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blueGrey,
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
        child:
        Column(
          children: [
            const SizedBox(
              height: 90.0,
            ),
            Center(

              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(40.0)),
                      color: Colors.white
                  ),
                  height: Height/1.5,
                  width: Width/1.09,
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,

                      child: Column(
                        children: [
                          SizedBox(height: 60,),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF2C3E50),
                                minimumSize: Size(30, 35)
                            ),
                            onPressed: () {
                              if (!isAttendanceMarkedin) {
                                pickImageFromCamerain();
                              } else if (!isAttendanceMarkedout && isAttendanceMarkedin) {
                                pickImageFromCameraout();
                              } else {

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Attendance already marked for today')),
                                );
                              }
                            },
                            child: const Text('Upload from Camera',style: TextStyle(color: Colors.white,fontFamily: 'Roboto',fontSize: 14),),
                          ),
                          const SizedBox(height: 20),
                          if (_selectedImage != null)
                            Image.file(
                              _selectedImage!,
                              width: 200,
                              height: 200,
                            ),
                          Center(

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF2C3E50),
                                      minimumSize: Size(40, 35)
                                  ),
                                  onPressed: isAttendanceMarkedin || isCheckInButtonDisabled
                                      ||!_isImageSelected
                                      ? null // Disable button if already marked or within 5 seconds
                                      : () async {
                                    setState(() {
                                      isCheckInButtonDisabled = true;
                                    });

                                    await markAttendance('Check_In', 'Check_In');


                                    Future.delayed(Duration(seconds: 5), () {
                                      setState(() {
                                        isCheckInButtonDisabled = false;
                                      });
                                    });
                                  },
                                  child: Text(isAttendanceMarkedin
                                      ? 'Already Marked'
                                      : 'Check_In',style: TextStyle(color: Colors.white,fontFamily: 'Roboto',fontSize: 14),),
                                ),
                                SizedBox(width: 10,),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF2C3E50),
                                      minimumSize: Size(30, 35)
                                  ),
                                  onPressed: isAttendanceMarkedout ||!_isImageSelected
                                      || !isAttendanceMarkedin ||isCheckOutButtonDiaabled
                                      ? null
                                      : () async{
                                    setState(() {
                                      isCheckOutButtonDiaabled = true; // Disable the button
                                    });
                                    await markAttendance('Check_Out','Check_Out');
                                    Future.delayed(Duration(seconds: 5), () {
                                      setState(() {
                                        isCheckOutButtonDiaabled = false;
                                      });
                                    });
                                  },
                                  child: Text(isAttendanceMarkedout
                                      ? 'Already Marked'
                                      : 'Check_Out',style: TextStyle(color: Colors.white,fontFamily: 'Roboto',fontSize: 14),),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: 30,
                          ),
                          ElevatedButton(style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF2C3E50),
                              minimumSize: Size(40, 35)
                          ),onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>attendance(mail: widget.emails)));

                          }, child: Text("Attendance Dasboard",style: TextStyle(color: Colors.white,fontFamily: 'Roboto',fontSize: 14),)),
                          SizedBox(
                            height: 30,
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> pickImageFromCamerain() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage == null) return  ;

    setState(() {
      _selectedImage = File(pickedImage.path);
      _isImageSelected = true;
    });

    await uploadImageToSupabase();
  }
  Future<void> pickImageFromCameraout() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage == null) return  ;

    setState(() {
      _selectedImage = File(pickedImage.path);
      _isImageSelected = true;
    });

    await uploadImageToSupabase();
  }
  Future<void> uploadImageToSupabase() async {
    if (_selectedImage == null) return;

    try {
      final filename = DateTime.now().millisecondsSinceEpoch.toString();
      final path = 'uploads/$filename.jpg';
      await Supabase.instance.client.storage.from('image').upload(path, _selectedImage!);
      final publicURL = Supabase.instance.client.storage.from('image').getPublicUrl(path);

      setState(() {
        _uploadedImageUrl = publicURL;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image uploaded successfully!")),
      );
      print("Image uploaded to Supabase: $publicURL");
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image.")),
      );
    }
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



class attendance extends StatefulWidget {
  final String mail;
  const attendance({super.key,required this.mail});

  @override

  State<attendance> createState() => _attendanceState();
}

class _attendanceState extends State<attendance> {

  @override
  final FirebaseFirestore db = FirebaseFirestore.instance;
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: db
                  .collection("Attendance")
                  .where("Email", isEqualTo: widget.mail)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No attendance records found.'));
                } else {
                  final filteredDocs = snapshot.data!.docs.where((doc) {
                    final date = doc['Date'] as String?;
                    final attendanceStatus = doc['Attendance'] as String?;
                    return date != null && attendanceStatus != null;}).toList();
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListTile(
                          leading: Image.network("${data['imagepath']}"),
                          title: Column(
                            children: [
                              Text('Date: ${data['Date']}'),
                              Text('Time:${data['Time']}')
                            ],
                          ),
                          subtitle: Center(child: Text('Attendance: ${data['Attendance']}')),
                          tileColor: data['Attendance'] == 'Check_In'
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
}