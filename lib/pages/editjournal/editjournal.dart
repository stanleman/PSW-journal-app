import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      Navigator.pop(context); // Go back to the previous page
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Journal Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: 'Content'),
                maxLines: 5, // Allow multi-line input for content
              ),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: tagsController,
                decoration:
                    InputDecoration(labelText: 'Tags (comma-separated)'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
