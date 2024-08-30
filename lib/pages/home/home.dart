import 'package:psw_journal_app/pages/editjournal/editjournal.dart';
import 'package:psw_journal_app/pages/newjournal/newjournal.dart';
import 'package:psw_journal_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  @override
  _homeState createState() => _homeState();
}

class _homeState extends State<Home> {
  String search = "";
  String filter = "All";
  DateTime? dateAfter;
  DateTime? dateBefore;

  Future<void> _pickDateTime(
      {required ValueChanged<DateTime?> onDatePicked}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      onDatePicked(DateTime(
        picked.year,
        picked.month,
        picked.day,
        0,
        0,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // If the user is not available, show a loading indicator or an error message
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Text('User not authenticated. Please log in.'),
          ),
        ),
      );
    }

    final String userId = user.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: "Search",
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      onChanged: (value) => {
                        setState(() {
                          search = value;
                        })
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  DropdownButton<String>(
                    value: filter,
                    items: <String>['All', 'Content/Title', 'Tags', 'Location']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        filter = newValue!;
                      });
                    },
                    itemHeight: 48,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    underline: SizedBox(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text("From:"),
                  TextButton(
                    onPressed: () async {
                      await _pickDateTime(
                        onDatePicked: (date) {
                          setState(() {
                            dateAfter = date;
                          });
                        },
                      );
                    },
                    child: Text(dateAfter != null
                        ? DateFormat.yMd().format(dateAfter!)
                        : "No date selected"),
                  ),
                  FittedBox(
                    child: TextButton(
                        onPressed: () {
                          setState(() {
                            dateAfter = null;
                          });
                        },
                        child: Text("X")),
                  ),
                  const SizedBox(width: 14),
                  const Text("To:"),
                  TextButton(
                    onPressed: () async {
                      await _pickDateTime(
                        onDatePicked: (date) {
                          setState(() {
                            dateBefore = date;
                          });
                        },
                      );
                    },
                    child: Text(dateBefore != null
                        ? DateFormat.yMd().format(dateBefore!)
                        : "No date selected"),
                  ),
                  FittedBox(
                    child: TextButton(
                        onPressed: () {
                          setState(() {
                            dateBefore = null;
                          });
                        },
                        child: Text("X")),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                  overlayColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.hovered))
                        return Colors.blue.withOpacity(0.04);
                      if (states.contains(MaterialState.focused) ||
                          states.contains(MaterialState.pressed))
                        return Colors.blue.withOpacity(0.12);
                      return null; // Defer to the widget's default.
                    },
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddJournalEntryPage()),
                  );
                },
                child: Text('Add New Journal'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildJournalList(userId),
              ),
              const SizedBox(height: 16),
              _logout(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJournalList(String userId) {
    CollectionReference journals =
        FirebaseFirestore.instance.collection('journals');

    Query query = journals.where('userId', isEqualTo: userId);

    return StreamBuilder<QuerySnapshot>(
      stream: query.orderBy('datetime', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No journal entries found.'));
        }

        final journalDocs = snapshot.data!.docs.where((doc) {
          if (dateAfter != null &&
              doc['datetime'].toDate().isBefore(dateAfter)) {
            return false;
          }
          if (dateBefore != null &&
              doc['datetime'].toDate().isAfter(dateBefore)) {
            return false;
          }

          if (search.isNotEmpty) {
            if (filter == "All") {
              String content = doc['content'];
              String title = doc['title'];
              List<String> searchTags =
                  search.split(',').map((tag) => tag.trim()).toList();
              List<String> tags = List<String>.from(doc['tags']);
              bool match = searchTags.any((searchTag) =>
                  tags.any((docTag) => docTag.contains(searchTag)));
              String location = doc['location'];
              return content.contains(search) ||
                  title.contains(search) ||
                  match ||
                  location.contains(search);
            }
            if (filter == "Content/Title") {
              String content = doc['content'];
              String title = doc['title'];
              return content.contains(search) || title.contains(search);
            }
            if (filter == "Tags") {
              List<String> searchTags =
                  search.split(',').map((tag) => tag.trim()).toList();
              List<String> tags = List<String>.from(doc['tags']);
              bool match = searchTags.any((searchTag) =>
                  tags.any((docTag) => docTag.contains(searchTag)));
              return match;
            }
            if (filter == "Location") {
              String location = doc['location'];
              return location.contains(search);
            }
          }
          return search.isEmpty;
        }).toList();

        return ListView.builder(
          itemCount: journalDocs.length,
          itemBuilder: (context, index) {
            var entry = journalDocs[index];
            var entryData = entry.data() as Map<String, dynamic>;

            String title = entryData['title'] ?? 'No Title';
            String content = entryData['content'] ?? 'No Content';
            Timestamp? timestamp = entryData['datetime'] as Timestamp?;
            String formattedDate = timestamp != null
                ? DateFormat.yMd().add_jm().format(timestamp.toDate())
                : 'No Date';
            String location = entryData['location'] ?? 'No Location';
            List<dynamic> tags = entryData['tags'] ?? [];

            return ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Show a confirmation dialog before deleting
                      bool? confirmDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Delete Journal Entry'),
                            content: Text(
                                'Are you sure you want to delete this journal entry?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmDelete == true) {
                        // Delete the journal entry from Firestore
                        await FirebaseFirestore.instance
                            .collection('journals')
                            .doc(entry.id)
                            .delete();
                      }
                    },
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formattedDate),
                  Text(location),
                  SizedBox(height: 4.0),
                  Text(content, maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4.0),
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 2.0,
                    children: tags
                        .map((tag) => Chip(label: Text(tag.toString())))
                        .toList(),
                  ),
                ],
              ),
              isThreeLine: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditJournalEntryPage(
                      entryId: entry.id, // Pass the document ID
                      entryData: entryData, // Pass the entry data
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _logout(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff0D6EFD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        minimumSize: const Size(double.infinity, 60),
        elevation: 0,
      ),
      onPressed: () async {
        await AuthService().signout(context: context);
      },
      child: const Text(
        "Sign Out",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
