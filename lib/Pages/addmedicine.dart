import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddMedicinePage extends StatefulWidget {
  @override
  _AddMedicinePageState createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  int _quantity = 1;
  String _compartment = '1';
  String _color = 'Pink';
  String _type = 'Tablet';
  String _frequency = 'Everyday';
  String _timesPerDay = 'Three Times';
  List<String> _doseTimes = ['', '', ''];
  bool _beforeFood = false;
  bool _afterFood = false;
  bool _beforeSleep = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _medecininame = TextEditingController();
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, int doseIndex) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _doseTimes[doseIndex] = picked.format(context);
      });
    }
  }

  Widget buildCompartmentButton(String number) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _compartment = number;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _compartment == number ? Colors.blueAccent : Colors.white,
          border: Border.all(
            color: _compartment == number ? Colors.blueAccent : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              color: _compartment == number ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildColorCircle(String color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _color = color;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color == 'Pink'
              ? Colors.pink
              : color == 'Purple'
                  ? Colors.purple
                  : color == 'Red'
                      ? Colors.red
                      : color == 'Green'
                          ? Colors.green
                          : color == 'Orange'
                              ? Colors.orange
                              : Colors.blue,
          border: Border.all(
            color: _color == color
                ? const Color.fromARGB(122, 0, 0, 0)
                : Colors.transparent,
            width: 4,
          ),
        ),
      ),
    );
  }

  Widget buildMedicineType(String type, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _type = type;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _type == type ? Colors.blueAccent : Colors.white,
          border: Border.all(
            color: _type == type ? Colors.blueAccent : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: _type == type ? Colors.white : Colors.black),
            const SizedBox(height: 5),
            Text(
              type,
              style: TextStyle(
                color: _type == type ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addMedicine() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'compartment': _compartment,
        'color': _color,
        'type': _type,
        'quantity': _quantity,
        'startDate': _startDate,
        'endDate': _endDate,
        'frequency': _frequency,
        'timesPerDay': _timesPerDay,
        'doseTimes': _doseTimes,
        'beforeFood': _beforeFood,
        'afterFood': _afterFood,
        'beforeSleep': _beforeSleep,
        'medecininame': _medecininame.text, // Extract text here
        // Consider storing email too
      });

      print("Medicine added for user: ${user.uid}");
    } else {
      print("No user is logged in.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicines'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _medecininame,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.medical_services_outlined),
                  hintText: 'Enter Medicine Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Compartment'),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(6, (index) {
                    return buildCompartmentButton((index + 1).toString());
                  }),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Colour'),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    buildColorCircle('Pink'),
                    buildColorCircle('Purple'),
                    buildColorCircle('Red'),
                    buildColorCircle('Green'),
                    buildColorCircle('Orange'),
                    buildColorCircle('Blue'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Type'),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    buildMedicineType('Tablet', Icons.tablet),
                    buildMedicineType('Capsule', Icons.medication),
                    buildMedicineType('Cream', Icons.palette),
                    buildMedicineType('Liquid', Icons.liquor),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Quantity'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Take 1/2 Pill', style: TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (_quantity > 1) {
                            setState(() {
                              _quantity--;
                            });
                          }
                        },
                      ),
                      Text('$_quantity', style: const TextStyle(fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            _quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Total Count'),
              Slider(
                value: _quantity.toDouble(),
                min: 1,
                max: 100,
                divisions: 100,
                label: _quantity.toString(),
                onChanged: (double value) {
                  setState(() {
                    _quantity = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _selectDate(context, true),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Set Date', style: TextStyle(fontSize: 16)),
                        Text(
                          DateFormat.yMMMd().format(_startDate),
                          style:
                              const TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _selectDate(context, false),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('End Date', style: TextStyle(fontSize: 16)),
                        Text(
                          DateFormat.yMMMd().format(_endDate),
                          style:
                              const TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Frequency of Days'),
              DropdownButton<String>(
                value: _frequency,
                isExpanded: true,
                onChanged: (String? newValue) {
                  setState(() {
                    _frequency = newValue!;
                  });
                },
                items: <String>['Everyday', 'Alternate Days', 'Weekly']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text('How many times a Day'),
              DropdownButton<String>(
                value: _timesPerDay,
                isExpanded: true,
                onChanged: (String? newValue) {
                  setState(() {
                    _timesPerDay = newValue!;
                  });
                },
                items: <String>['Once', 'Twice', 'Three Times']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text('Doses'),
              Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Dose 1'),
                    trailing: TextButton(
                      onPressed: () => _selectTime(context, 0),
                      child: Text(
                        _doseTimes[0].isEmpty ? 'Set Time' : _doseTimes[0],
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Dose 2'),
                    trailing: TextButton(
                      onPressed: () => _selectTime(context, 1),
                      child: Text(
                        _doseTimes[1].isEmpty ? 'Set Time' : _doseTimes[1],
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Dose 3'),
                    trailing: TextButton(
                      onPressed: () => _selectTime(context, 2),
                      child: Text(
                        _doseTimes[2].isEmpty ? 'Set Time' : _doseTimes[2],
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Intake Timings'),
              CheckboxListTile(
                title: const Text('Before Food'),
                value: _beforeFood,
                onChanged: (bool? value) {
                  setState(() {
                    _beforeFood = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('After Food'),
                value: _afterFood,
                onChanged: (bool? value) {
                  setState(() {
                    _afterFood = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Before Sleep'),
                value: _beforeSleep,
                onChanged: (bool? value) {
                  setState(() {
                    _beforeSleep = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _addMedicine,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                  ),
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
