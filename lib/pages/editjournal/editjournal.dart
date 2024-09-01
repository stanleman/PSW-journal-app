import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditJournalEntryPage extends StatefulWidget {
  final String entryId;
  final Map<String, dynamic> entryData;

  const EditJournalEntryPage({required this.entryId, required this.entryData});

  @override
  _EditJournalEntryPageState createState() => _EditJournalEntryPageState();
}

class _EditJournalEntryPageState extends State<EditJournalEntryPage> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  late TextEditingController locationController;
  late TextEditingController tagsController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.entryData['title']);
    contentController =
        TextEditingController(text: widget.entryData['content']);
    locationController =
        TextEditingController(text: widget.entryData['location']);
    tagsController = TextEditingController(
        text: (widget.entryData['tags'] as List<dynamic>).join(', '));
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    locationController.dispose();
    tagsController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // Convert tagsController text to a list of strings
    List<String> tags =
        tagsController.text.split(',').map((tag) => tag.trim()).toList();

    // Update the journal entry in Firestore
    FirebaseFirestore.instance
        .collection('journals')
        .doc(widget.entryId)
        .update({
      'title': titleController.text,
      'content': contentController.text,
      'location': locationController.text,
      'tags': tags,
    }).then((_) {
      final snackBar = SnackBar(
        content: const Text('Journal entry edited.'),
        showCloseIcon: true,
        behavior: SnackBarBehavior.floating,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.pop(context); // Go back to the previous page
    });
  }

  @override
  Widget build(BuildContext context) {
    var now = widget.entryData['datetime'];
    String formattedDate = now != null
        ?
        // DateFormat.yMd().add_jm().format(timestamp.toDate())
        DateFormat('EEEE, MMMM d').format(now.toDate()).toUpperCase()
        : '(No Date)';
    ;
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
                  Text(formattedDate),
                ],
              ),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: titleController,
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
                      controller: contentController,
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
                    // SizedBox(height: 16.0),
                    // Row(
                    //   children: [
                    //     Text(_selectedDate == null
                    //         ? 'No date selected'
                    //         : DateFormat.yMd().add_jm().format(_selectedDate!)),
                    //     Spacer(),
                    //     TextButton(
                    //       onPressed: pickDateTime,
                    //       child: Text('Select Date & Time'),
                    //     ),
                    //   ],
                    // ),
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
                          controller: locationController,
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
                          controller: tagsController,
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
                      onPressed: _saveChanges,
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
