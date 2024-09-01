import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddJournalEntryPage extends StatefulWidget {
  @override
  _AddJournalEntryPageState createState() => _AddJournalEntryPageState();
}

class _AddJournalEntryPageState extends State<AddJournalEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _pickDateTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveJournalEntry() async {
    if (_formKey.currentState!.validate()) {
      List<String> tags =
          _tagsController.text.split(',').map((tag) => tag.trim()).toList();

      await FirebaseFirestore.instance.collection('journals').add({
        'title': _textController.text,
        'content': _contentController.text,
        'datetime': _selectedDate == null ? DateTime.now() : _selectedDate,
        'location': _locationController.text,
        'tags': tags,
        'userId': FirebaseAuth.instance.currentUser!.uid
      });

      final snackBar = SnackBar(
          content: const Text('Journal entry added.'),
          action: SnackBarAction(
            label: 'Close',
            onPressed: () {},
          ),
          behavior: SnackBarBehavior.floating,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // var now = DateTime.now();
    // String formattedDate = DateFormat('EEEE, MMMM d').format(now).toUpperCase();
    return Scaffold(
      backgroundColor: Color(0xffCBF1F5),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    iconSize: 24,
                    icon: const Icon(
                      Icons.arrow_back_sharp,
                    ),
                    // the method which is called
                    // when button is pressed
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  // Text(formattedDate)
                  const Text("NEW JOURNAL")
                ],
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _textController,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: "Title"),
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Title can\'t be empty';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _contentController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      minLines: 12,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Start writing down your thoughts..."),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Content can\'t be empty';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    Wrap(
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(_selectedDate == null
                            ? 'No date selected'
                            : DateFormat.yMd().add_jm().format(_selectedDate!)),
                        TextButton(
                          onPressed: _pickDateTime,
                          child: Text('Select Date & Time'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Location',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          controller: _locationController,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10))),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a location';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tags (comma separated)',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          controller: _tagsController,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10))),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter at least a tag';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 40.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0D6EFD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        minimumSize: const Size(double.infinity, 60),
                        elevation: 0,
                      ),
                      onPressed: _saveJournalEntry,
                      child: const Text(
                        "Save entry",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 30.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
