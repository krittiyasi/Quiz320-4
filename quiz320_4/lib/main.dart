import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quiz320_4/screen/singin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const SigninScreen(),
    );
  }
}

class IncomeExpenseApp extends StatefulWidget {
  const IncomeExpenseApp({super.key});

  @override
  State<IncomeExpenseApp> createState() => _IncomeExpenseAppState();
}

class _IncomeExpenseAppState extends State<IncomeExpenseApp> {
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  late TextEditingController _noteController;

  String _selectedType = 'Income'; // Default type
  List<String> _types = ['Income', 'Expense'];

  double totalIncome = 0;
  double totalExpense = 0;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _dateController = TextEditingController();
    _noteController = TextEditingController();
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SigninScreen()),
    );
  }

  void calculateTotals(List<DocumentSnapshot> documents) {
    totalIncome = 0;
    totalExpense = 0;

    for (var doc in documents) {
      if (doc['type'] == 'Income') {
        totalIncome += doc['amount'];
      } else if (doc['type'] == 'Expense') {
        totalExpense += doc['amount'];
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.toLocal()}".split(' ')[0]; // Format the date as needed
      });
    }
  }

  void addOrEditRecordHandle(BuildContext context, [DocumentSnapshot? document]) {
    if (document != null) {
      _amountController.text = document['amount'].toString();
      _dateController.text = document['date'];
      _selectedType = document['type'];
      _noteController.text = document['note'] ?? "";
    } else {
      _amountController.clear();
      _dateController.clear();
      _selectedType = 'Income'; // Reset to default
      _noteController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(document != null ? "Edit Record" : "Add New Record"),
          content: SizedBox(
            width: 300,
            height: 300,
            child: Column(
              children: [
                TextField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Amount"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectDate(context), // Call date picker on tap
                  child: AbsorbPointer( // Prevent keyboard from appearing
                    child: TextField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: "Date"),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Dropdown for Type
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Type",
                  ),
                  items: _types.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedType = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Notes"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String userEmail = FirebaseAuth.instance.currentUser!.email!;
                CollectionReference records =
                    FirebaseFirestore.instance.collection(userEmail);
                
                if (document != null) {
                  records.doc(document.id).update({
                    'amount': double.parse(_amountController.text),
                    'date': _dateController.text,
                    'type': _selectedType, // Use selected type
                    'note': _noteController.text,
                  }).then((res) {
                    print("Record updated");
                  }).catchError((onError) {
                    print("Failed to update record");
                  });
                } else {
                  records.add({
                    'amount': double.parse(_amountController.text),
                    'date': _dateController.text,
                    'type': _selectedType, // Use selected type
                    'note': _noteController.text,
                  }).then((res) {
                    print("Record added");
                  }).catchError((onError) {
                    print("Failed to add new Record");
                  });
                }
                
                _amountController.clear();
                _dateController.clear();
                _noteController.clear();
                _selectedType = 'Income'; // Reset to default
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void deleteRecord(DocumentSnapshot document) {
    String userEmail = FirebaseAuth.instance.currentUser!.email!;
    FirebaseFirestore.instance.collection(userEmail).doc(document.id).delete().then((res) {
      print("Record deleted");
    }).catchError((onError) {
      print("Failed to delete record");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Income/Expense Tracker"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection(FirebaseAuth.instance.currentUser!.email!).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            calculateTotals(snapshot.data!.docs);
            return Column(
              children: [
                // Display totals
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Total Income: \$${totalIncome.toStringAsFixed(2)}\nTotal Expense: \$${totalExpense.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = snapshot.data!.docs[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Amount: ${document['amount']}",
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  Text("Date: ${document['date']}"),
                                  Text("Type: ${document['type']}"),
                                  if (document['note'] != null && document['note'] != "")
                                    Text("Notes: ${document['note']}"),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                addOrEditRecordHandle(context, document);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                deleteRecord(document);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addOrEditRecordHandle(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
