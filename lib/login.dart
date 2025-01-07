import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class loggedin extends StatefulWidget {
  final String texts;
  const loggedin({super.key,required this.texts});

  @override
  State<loggedin> createState() => _loggedinState();
}

class _loggedinState extends State<loggedin> {
  TextEditingController date_control=TextEditingController();
  CalendarFormat _calendarFormat=CalendarFormat.month;

  Map<DateTime, String> _attendance = {};
  void markAttendance(DateTime date, String status) {
    setState(() {
      _attendance[date] = status;
    });
  }
  BoxDecoration _getAttendanceDecoration(DateTime date,) {

      if (_attendance[date] == 'Present') {
        return BoxDecoration(color: Colors.green, shape: BoxShape.circle);
      } else if (_attendance[date] == 'Absent') {
        return BoxDecoration(color: Colors.red, shape: BoxShape.circle);
      }
    return BoxDecoration(); // Default decoration if no attendance marked
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            TableCalendar(

              focusedDay: DateTime.now(),
                firstDay: DateTime(2021),
                lastDay: DateTime(2027),
                rowHeight: 40,
                calendarFormat: _calendarFormat,
                headerStyle: HeaderStyle(
                  leftChevronIcon: Icon(Icons.arrow_back_ios,color: Colors.green,),
                  rightChevronIcon: Icon(Icons.arrow_forward_ios,
                    color: Colors.green),
                  titleTextStyle: TextStyle(color: Colors.green),
                ),daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color:Colors.grey)
            ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color:Colors.blueGrey,
                  shape: BoxShape.circle,

                )
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: date_control,
                  decoration: InputDecoration(
                    filled: true,
                    labelText: 'DATE',
                    prefixIcon: GestureDetector(
                        onTap: (){
                          setState(() {
                            selectDate(context);
                          });
                        },
                        child: Icon(Icons.calendar_today_outlined,)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue
                    )
                  )
                  ),
                  readOnly: true,
                ),
              ),
            ),
            TextButton(onPressed: (){
              setState(() {
                showDialog(context: context, builder: (context){
                  return AlertDialog(
                    scrollable: true,
                    content: Column(
                      children: [
                        Text('${widget.texts.substring(0,10)} Mark Your Attendance'),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(onPressed: (){
                                markAttendance(DateTime.parse(date_control.text), 'Present');
                                Navigator.pop(context);
                              }, child: Text('Present')),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(onPressed: (){
                                markAttendance(DateTime.parse(date_control.text), 'Absent');
                                Navigator.pop(context);
                              }, child: Text('Absent')),
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                });
              });
            }, child: Text("Mark Attendance"))
          ],
        ),
      ),
    );
  }
  Future selectDate(context) async{
    DateTime? _picked =await showDatePicker(
        context:context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now());
    if(_picked!=null){
      setState((){
        date_control.text=_picked.toString().split(" ")[0];
      });
    }
  }
}

