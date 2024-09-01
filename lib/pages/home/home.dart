import 'dart:math';

import 'package:collection/collection.dart';
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
    bool isSearching = false;

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
    final String username =
        user.email?.substring(0, user.email?.indexOf("@")) ?? "User";
    var now = DateTime.now();
    String formattedDate = DateFormat('EEEE, MMMM d').format(now).toUpperCase();
    String greeting = "Good morning";
    dynamic hoursNow = int.parse(DateFormat('H').format(now));
    if (hoursNow < 6) {
      greeting = "Good evening";
    } else if (hoursNow < 12) {
      greeting = "Good morning";
    } else if (hoursNow < 17) {
      greeting = "Good afternoon";
    } else if (hoursNow < 24) {
      greeting = "Good evening";
    }
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    iconSize: 24,
                    icon: const Icon(
                      Icons.calendar_month,
                    ),
                    // the method which is called
                    // when button is pressed
                    onPressed: () {},
                  ),
                  IconButton(
                    iconSize: 24,
                    icon: const Icon(
                      Icons.search,
                    ),
                    // the method which is called
                    // when button is pressed
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(fontSize: 12, letterSpacing: 2),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$greeting, $username!",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w500),
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),
              // Expanded(
              //   child:
              _buildJournalList(userId),
              // ),
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

        // final journalDocsData =
        //     journalDocs.map((doc) => doc.data()).toList() as List<dynamic>;

        // var groupByDate = groupBy(
        //     journalDocsData,
        //     (obj) =>
        //         {DateFormat('MMMM yyyy').format(obj!['datetime'].toDate())});
        // var groups = [] ;
        // groupByDate.forEach((date, list) {
        //   // Header
        //   print('${date}:');
        //   if(groups.contains(date)){
        //     groups.add(date);
        //   }
        //   // Group
        //   // list.forEach((listItem) {
        //   //   // List item
        //   //   return
        //   //   print('${listItem["time"]}, ${listItem["message"]}');
        //   // });
        //   // // day section divider
        //   // print('\n');
        // });
        // print(groups);
        // return ListView.builder(
        //   itemBuilder: (context, index) {
        //     print(index);
        //   },
        // );
        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: journalDocs.length,
          itemBuilder: (context, index) {
            var entry = journalDocs[index];
            var entryData = entry.data() as Map<String, dynamic>;

            String title = entryData['title'] ?? '(No Title)';
            String content = entryData['content'] ?? '(No Content)';
            Timestamp? timestamp = entryData['datetime'] as Timestamp?;
            String formattedDate = timestamp != null
                ?
                // DateFormat.yMd().add_jm().format(timestamp.toDate())
                DateFormat('EEE d').format(timestamp.toDate())
                : '(No Date)';
            String location = entryData['location'] ?? '(No Location)';
            List<dynamic> tags = entryData['tags'] ?? [];

            bool isSameDate = true;
            final monthString =
                DateFormat('MMMM yyyy').format(timestamp!.toDate());

            if (index == 0) {
              isSameDate = false;
            } else {
              final prevEntry =
                  journalDocs[index - 1].data() as Map<String, dynamic>;
              Timestamp? prevEntryDate =
                  prevEntry['datetime'] ?? "" as Timestamp?;
              final prevDate =
                  DateFormat('MMMM yyyy').format(prevEntryDate!.toDate());
              isSameDate = monthString == prevDate;
            }

            bool isContinued = true;

            if (index == journalDocs.length - 1) {
              isContinued = false;
            } else {
              final nextEntry =
                  journalDocs[index + 1].data() as Map<String, dynamic>;
              Timestamp? prevEntryDate =
                  nextEntry['datetime'] ?? "" as Timestamp?;
              final prevDate =
                  DateFormat('MMMM yyyy').format(prevEntryDate!.toDate());
              isContinued = monthString == prevDate;
            }

            return Column(
              children: [
                if (index == 0 || !isSameDate) ...[
                  const SizedBox(
                    height: 20,
                  ),
                ],
                Container(
                  padding: (index == 0 || !isSameDate)
                      ? EdgeInsets.fromLTRB(20, 15, 10, 0)
                      : EdgeInsets.fromLTRB(20, 0, 10, 0),
                  decoration: BoxDecoration(
                      color: Color(0xffE3FDFD),
                      borderRadius: isSameDate
                          ? isContinued
                              ? BorderRadius.only()
                              : BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                )
                          : isContinued
                              ? BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                )
                              : BorderRadius.circular(15)),
                  child: Column(
                    children: [
                      if (index == 0 || !isSameDate) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              monthString,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                      journalEntry(title, entry, formattedDate, location,
                          content, tags, entryData, isContinued, isSameDate),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget journalEntry(
      String title,
      DocumentSnapshot entry,
      String formattedDate,
      String location,
      String content,
      List<dynamic> tags,
      Map<String, dynamic> entryData,
      bool isContinued,
      bool isSameDate) {
    List<dynamic> visibleTags = tags.sublist(0, min(MediaQuery.of(context).size.width <= 330? 2 : 3, tags.length));
    int remainingTags = tags.length - visibleTags.length;
    print(visibleTags);
    return Column(
      children: [
        Container(
          color: Color(0xffE3FDFD),
          constraints: BoxConstraints(maxHeight: 280),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                child: Column(
                  children: [
                    if (isSameDate) ...[
                      Container(
                        width: 1,
                        height: 15,
                        decoration: BoxDecoration(
                          border: Border(left: BorderSide(color: Colors.grey)),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                    ] else ...[
                      SizedBox(
                        height: 20,
                      ),
                    ],
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 113, 201, 206),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: EdgeInsets.all(5),
                      child: Column(
                        children: [
                          Text(
                            formattedDate
                                .substring(0, formattedDate.indexOf(" "))
                                .toUpperCase(),
                            style: const TextStyle(
                                color: Color.fromARGB(255, 235, 235, 235),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                height: 1.5),
                          ),
                          Text(
                            formattedDate
                                .substring(formattedDate.indexOf(" ") + 1),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height: 1),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    if (isContinued) ...[
                      Expanded(
                        child: Container(
                          width: 1,
                          height: 100,
                          decoration: BoxDecoration(
                            border:
                                Border(left: BorderSide(color: Colors.grey)),
                          ),
                        ),
                      )
                    ]
                  ],
                ),
              ),
              Expanded(
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title.toUpperCase(),
                          style: TextStyle(
                              height: 1,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600]),
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
                                title: const Text('Delete Journal Entry'),
                                content: const Text(
                                    'Are you sure you want to delete this journal entry?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      const snackBar = SnackBar(
                                        content: Text('Journal entry deleted.'),
                                        showCloseIcon: true,
                                        behavior: SnackBarBehavior.floating,
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                      Navigator.pop(context, true);
                                    },
                                    child: const Text('Delete'),
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
                      Text(
                        content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 25.0),
                      Text(
                        "in $location",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      SizedBox(height: 10.0),
                      Wrap(
                        spacing: 4.0,
                        runSpacing: 3.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ...visibleTags
                              .map((tag) => Chip(
                                    label: Text(
                                      tag.toString(),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ))
                              .toList(),
                          remainingTags > 0
                              ? remainingTags > 1
                                  ? Text("+$remainingTags more tags")
                                  : Text("+$remainingTags more tag")
                              : Text("")
                        ],
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
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget searchContent() {
    return Row(
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
    );
  }

  Widget searchByDateRange() {
    return Row(
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
    );
  }
}
