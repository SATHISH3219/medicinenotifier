import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import 'addmedicine.dart';

class AddMedicineScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicine Reminder',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _selectedDate = DateTime.now();
  String? username;
  String? color;
  String? compartment;
  DateTime? endDate;
  String? frequency;
  String? quantity;
  DateTime? startDate;
  String? timesPerDay;
  String? type;
  String? medecininame;
  String? beforeFood;
  String? afterFood;
  String? beforeSleep;
  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    getUsername();
    getuserdetails();
    initializeNotifications();
  }

  void initializeNotifications() {
    // Define settings for Android notifications
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // Define settings for iOS notifications (not used in this example)
  }

  // Function to schedule medication reminder notifications
  void scheduleNotifications() {
    // Example: Schedule a notification for 8:00 AM every day
    _scheduleNotification(
        0, 'Morning Medication Reminder', 'Take your morning medication', 8, 0);
    // Example: Schedule a notification for 2:00 PM every day
    _scheduleNotification(1, 'Afternoon Medication Reminder',
        'Take your afternoon medication', 14, 0);
    // Example: Schedule a notification for 9:00 PM every day
    _scheduleNotification(
        2, 'Night Medication Reminder', 'Take your night medication', 21, 0);
  }

  // Function to schedule a single notification
  Future<void> _scheduleNotification(
      int id, String title, String body, int hour, int minute) async {
    // Define Android notification details
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'medication_channel_$id',
      'Medication Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    // Define NotificationDetails for the specified platform (Android in this case)
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Calculate the next occurrence of the scheduled time
    final DateTime now = DateTime.now();
    DateTime scheduledDate =
        DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }

    // Schedule the notification
  }

  Future<void> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      showNoInternetDialog();
    }
  }

  Future<void> getUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('user details')
          .doc(user.uid)
          .get();
      setState(() {
        username = snapshot['name'] as String?;
      });
    }
  }

  Future<void> getuserdetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        setState(() {
          color = snapshot.data()?['color'] as String?;
          compartment = snapshot.data()?['compartment'] as String?;
          endDate = (snapshot.data()?['endDate'] as Timestamp?)?.toDate();
          frequency = snapshot.data()?['frequency'] as String?;
          quantity = data['quantity'].toString();
          startDate = (snapshot.data()?['startDate'] as Timestamp?)?.toDate();
          timesPerDay = snapshot.data()?['timesPerDay'] as String?;
          medecininame = snapshot.data()?['medecininame'] as String?;
          beforeFood = snapshot.data()?['beforeFood'] as String?;
          afterFood = snapshot.data()?['afterFood'] as String?;
          beforeSleep = snapshot.data()?['beforeSleep'] as String?;
          print("Successfully retrieved");
        });
      } else {
        print("Document does not exist");
      }
    }
  }

  void showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("No Internet Connection"),
          content: const Text("Please turn on your internet connection."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String getDayAndDate(DateTime date) {
    final DateFormat formatter = DateFormat('EEEE: MMMM d');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medicine Reminder',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        "Hi ${username ?? "Loading..."} !",
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      const Text('5 Medicines Left',
                          style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Container(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const SizedBox(
                            width: 10), // Empty container to center content
                        for (int i = 0; i < 7; i++)
                          dayContainer(
                            DateFormat('EEEE')
                                .format(_selectedDate.add(Duration(days: i))),
                            i == 0, // Check if it's today
                          ),
                        const SizedBox(
                            width: 50), // Empty container to center content
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        getDayAndDate(_selectedDate),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () => _selectDate(context),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromARGB(255, 0, 42, 77)),
                          elevation: MaterialStateProperty.all<double>(15.0),
                        ),
                        child: const Text(
                          'Select Date',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color.fromARGB(255, 234, 234, 234)),
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                child: Text("Morning 08:00 am",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Text(
                                  "${medecininame ?? "Loading..."}  BeforeFood :$beforeFood  AfterFood : $afterFood",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Icon(Icons.notification_add_outlined)
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color.fromARGB(255, 234, 234, 234)),
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                child: Text("Afternoon 02:00 pm",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Text(
                                  "${medecininame ?? "Loading..."}  BeforeFood :$beforeFood  AfterFood : $afterFood",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Icon(Icons.notification_add_outlined)
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color.fromARGB(255, 234, 234, 234)),
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                child: Text("Night 09:00 pm",
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Text(
                                  "${medecininame ?? "Loading..."}  BeforeFood :$beforeFood  AfterFood : $afterFood",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Icon(Icons.notification_add_outlined)
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddMedicinePage()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Container dayContainer(String day, bool isToday) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: isToday ? const Color.fromARGB(255, 255, 191, 0) : null,
        boxShadow: [],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        day,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
