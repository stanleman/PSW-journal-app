import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:psw_journal_app/pages/editjournal/editjournal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  @override
  _homeState createState() => _homeState();
}

class _homeState extends State<Home> {
  StreamController<String> search = StreamController<String>.broadcast();
  StreamController<String> filter = StreamController<String>.broadcast();
  @override
  void initState() {
    super.initState();
  }

  String filterString = "All";
  ValueNotifier<DateTime?> dateAfterString = ValueNotifier<DateTime?>(null);
  ValueNotifier<DateTime?> dateBeforeString = ValueNotifier<DateTime?>(null);

  StreamController<bool> isSearching = StreamController<bool>.broadcast();

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
      return const Scaffold(
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
              StreamBuilder<bool>(
                  stream: isSearching.stream,
                  initialData: false,
                  builder: (context, snapshot) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!snapshot.data!)
                          IconButton(
                            iconSize: 24,
                            icon: const Icon(
                              Icons.search,
                            ),
                            onPressed: () {
                              isSearching.sink.add(true);
                            },
                          )
                        else ...[
                          IconButton(
                            iconSize: 24,
                            icon: const Icon(
                              Icons.search_off,
                            ),
                            onPressed: () {
                              isSearching.sink.add(false);
                              search.sink.add("");
                              filter.sink.add('All');
                            },
                          ),
                          Flexible(
                            child: searchContent(),
                          )
                        ],
                        IconButton(
                          iconSize: 24,
                          icon: dateAfterString.value != null ||
                                  dateBeforeString.value != null
                              ? const Badge(
                                  child: Icon(
                                    Icons.calendar_month,
                                  ),
                                )
                              : const Icon(
                                  Icons.calendar_month,
                                ),
                          // the method which is called
                          // when button is pressed
                          onPressed: () {
                            showModalBottomSheet(
                                backgroundColor: Color(0xffCBF1F5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20))),
                                isScrollControlled: true,
                                context: context,
                                builder: ((context) => searchByDateRange()));
                          },
                        ),
                      ],
                    );
                  }),
              const SizedBox(height: 16),
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
          return const SizedBox(
            height: 800,
            child: Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No journal entries found.'),
                ],
              ),
            ),
          );
        }

        return StreamBuilder(
          stream: search.stream,
          builder: (searchContext, searchSnapshot) {
            return StreamBuilder(
                stream: filter.stream,
                builder: (filterContext, filterSnapshot) {
                  final journalDocs = snapshot.data!.docs.where((doc) {
                    // if (dateAfterSnapshot.data != null &&
                    //     doc['datetime']
                    //         .toDate()
                    //         .isBefore(dateAfterSnapshot.data)) {
                    //   return false;
                    // }
                    // if (dateBeforeSnapshot.data != null &&
                    //     doc['datetime']
                    //         .toDate()
                    //         .isAfter(dateBeforeSnapshot.data)) {
                    //   return false;
                    // }
                    if (dateAfterString.value != null &&
                        doc['datetime']
                            .toDate()
                            .isBefore(dateAfterString.value)) {
                      return false;
                    }
                    if (dateBeforeString.value != null &&
                        doc['datetime']
                            .toDate()
                            .isAfter(dateBeforeString.value)) {
                      return false;
                    }

                    if (searchSnapshot.data != null ||
                        searchSnapshot.data != "") {
                      final tempSearch = searchSnapshot.data?.toLowerCase();
                      if (filterSnapshot.data == "All" ||
                          filterSnapshot.data == null) {
                        String content = doc['content'].toLowerCase();
                        String title = doc['title'].toLowerCase();
                        List<String>? searchTags = tempSearch
                            ?.split(',')
                            .map((tag) => tag.trim())
                            .toList();
                        List<String> tags = List<String>.from(doc['tags']);
                        bool match = searchTags?.any((searchTag) => tags.any(
                                (docTag) => docTag
                                    .toLowerCase()
                                    .contains(searchTag))) ??
                            false;
                        String location = doc['location'].toLowerCase();
                        return content.contains(tempSearch ?? "") ||
                            title.contains(tempSearch ?? "") ||
                            match ||
                            location.contains(tempSearch ?? "");
                      }
                      if (filterSnapshot.data == "Content\n/Title") {
                        String content = doc['content'].toLowerCase();
                        String title = doc['title'].toLowerCase();
                        return content.contains(tempSearch ?? "") ||
                            title.contains(tempSearch ?? "");
                      }
                      if (filterSnapshot.data == "Tags") {
                        List<String>? searchTags = tempSearch
                            ?.split(',')
                            .map((tag) => tag.trim())
                            .toList();
                        List<String> tags = List<String>.from(doc['tags']);
                        bool match = searchTags?.any((searchTag) => tags.any(
                                (docTag) => docTag
                                    .toLowerCase()
                                    .contains(searchTag))) ??
                            true;
                        return match;
                      }
                      if (filterSnapshot.data == "Location") {
                        String location = doc['location'].toLowerCase();
                        return location.contains(tempSearch ?? "");
                      }
                    }
                    return searchSnapshot.data!.isEmpty;
                  }).toList();
                  if (journalDocs.isEmpty) {
                    return const SizedBox(
                      height: 300,
                      child: Center(
                        child: Text('No journal entries found.'),
                      ),
                    );
                  }
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: journalDocs.length,
                    itemBuilder: (context, index) {
                      var entry = journalDocs[index];
                      var entryData = entry.data() as Map<String, dynamic>;

                      String title = entryData['title'] ?? '(No Title)';
                      String content = entryData['content'] ?? '(No Content)';
                      Timestamp? timestamp =
                          entryData['datetime'] as Timestamp?;
                      String formattedDate = timestamp != null
                          ?
                          // DateFormat.yMd().add_jm().format(timestamp.toDate())
                          DateFormat('EEE d').format(timestamp.toDate())
                          : '(No Date)';
                      String location =
                          entryData['location'] ?? '(No Location)';
                      List<dynamic> tags = entryData['tags'] ?? [];

                      bool isSameDate = true;
                      final monthString =
                          DateFormat('MMMM yyyy').format(timestamp!.toDate());

                      if (index == 0) {
                        isSameDate = false;
                      } else {
                        final prevEntry = journalDocs[index - 1].data()
                            as Map<String, dynamic>;
                        Timestamp? prevEntryDate =
                            prevEntry['datetime'] ?? "" as Timestamp?;
                        final prevDate = DateFormat('MMMM yyyy')
                            .format(prevEntryDate!.toDate());
                        isSameDate = monthString == prevDate;
                      }

                      bool isContinued = true;

                      if (index == journalDocs.length - 1) {
                        isContinued = false;
                      } else {
                        final nextEntry = journalDocs[index + 1].data()
                            as Map<String, dynamic>;
                        Timestamp? prevEntryDate =
                            nextEntry['datetime'] ?? "" as Timestamp?;
                        final prevDate = DateFormat('MMMM yyyy')
                            .format(prevEntryDate!.toDate());
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
                                journalEntry(
                                    title,
                                    entry,
                                    formattedDate,
                                    location,
                                    content,
                                    tags,
                                    entryData,
                                    isContinued,
                                    isSameDate),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                });
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
    List<dynamic> visibleTags = tags.sublist(
        0, min(MediaQuery.of(context).size.width <= 330 ? 2 : 3, tags.length));
    int remainingTags = tags.length - visibleTags.length;
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
                        icon: Icon(Icons.edit, color: Colors.black),
                        onPressed: () {
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
                      // IconButton(
                      //   icon: Icon(Icons.delete, color: Colors.red),
                      //   onPressed: () async {
                      //     // Show a confirmation dialog before deleting
                      //     bool? confirmDelete = await showDialog<bool>(
                      //       context: context,
                      //       builder: (context) {
                      //         return AlertDialog(
                      //           title: const Text('Delete Journal Entry'),
                      //           content: const Text(
                      //               'Are you sure you want to delete this journal entry?'),
                      //           actions: [
                      //             TextButton(
                      //               onPressed: () {
                      //                 Navigator.pop(context, false);
                      //               },
                      //               child: const Text('Cancel'),
                      //             ),
                      //             TextButton(
                      //               onPressed: () {
                      //                 const snackBar = SnackBar(
                      //                   content: Text('Journal entry deleted.'),
                      //                   showCloseIcon: true,
                      //                   behavior: SnackBarBehavior.floating,
                      //                 );
                      //                 ScaffoldMessenger.of(context)
                      //                     .showSnackBar(snackBar);
                      //                 Navigator.pop(context, true);
                      //               },
                      //               child: const Text('Delete'),
                      //             ),
                      //           ],
                      //         );
                      //       },
                      //     );

                      //     if (confirmDelete == true) {
                      //       // Delete the journal entry from Firestore
                      //       await FirebaseFirestore.instance
                      //           .collection('journals')
                      //           .doc(entry.id)
                      //           .delete();
                      //     }
                      //   },
                      // ),
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
    return Stack(
      children: [
        StreamBuilder<String>(
            stream: search.stream,
            initialData: "",
            builder: (context, snapshot) {
              return Container(
                height: 40,
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    hintText: "Search...",
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                  onChanged: (value) => {search.sink.add(value)},
                ),
              );
            }),
        StreamBuilder<String>(
          stream: filter.stream,
          builder: (context, snapshot) {
            return Positioned(
              right: 10,
              child: SizedBox(
                height: 40,
                child: DropdownButton<String>(
                  // value: "",
                  focusColor: Colors.transparent,
                  icon: (snapshot.data == "All" || snapshot.data == null)
                      ? Icon(Icons.filter_alt)
                      : const Badge(
                          child: Icon(Icons.filter_alt),
                        ),
                  items: <String>['All', 'Content\n/Title', 'Tags', 'Location']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: SizedBox(
                        width: 400,
                        child: Row(
                          children: [
                            Text(
                              value,
                              overflow: TextOverflow.fade,
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            if ((value == "All" && snapshot.data == null) ||
                                snapshot.data == value)
                              const Icon(
                                Icons.check,
                                size: 20,
                              )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    filter.sink.add(newValue ?? "All");
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return <String>['laaaa', 'laaaa', 'laaaa', 'laaaa']
                        .map((String value) {
                      return Text(
                          value); // Replace with an empty container or icon to hide
                    }).toList();
                  },
                  // itemHeight: 48,
                  underline: const SizedBox(),
                  // padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            );
          },
        )
      ],
    );
  }

  Widget searchByDateRange() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Select a date range",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              const Text("From:"),
              const SizedBox(
                width: 15,
              ),
              ValueListenableBuilder<dynamic>(
                  // stream: dateAfter.stream,
                  valueListenable: dateAfterString,
                  builder: (context, value, widget) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () async {
                              await _pickDateTime(
                                onDatePicked: (date) {
                                  // dateAfter.sink.add(date!);
                                  setState(() {
                                    dateAfterString.value = date;
                                  });
                                },
                              );
                            },
                            child: Text(
                              dateAfterString.value != null
                                  ? DateFormat.yMd()
                                      .format(dateAfterString.value!)
                                  : "Select a date",
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          if (dateAfterString.value != null)
                            FittedBox(
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    dateAfterString.value = null;
                                  });
                                  // dateAfter.sink.add(null);
                                },
                                icon: const Icon(Icons.close),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const Text("To:"),
              const SizedBox(
                width: 33,
              ),
              ValueListenableBuilder<dynamic>(
                  valueListenable: dateBeforeString,
                  builder: (context, value, widget) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () async {
                              await _pickDateTime(
                                onDatePicked: (date) {
                                  setState(() {
                                    dateBeforeString.value = date;
                                  });
                                },
                              );
                            },
                            child: Text(
                                dateBeforeString.value != null
                                    ? DateFormat.yMd()
                                        .format(dateBeforeString.value!)
                                    : "Select a date",
                                style: TextStyle(
                                  color: Colors.black,
                                )),
                          ),
                          if (dateBeforeString.value != null)
                            FittedBox(
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    dateBeforeString.value = null;
                                  });
                                },
                                icon: const Icon(Icons.close),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
            ],
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff0D6EFD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              minimumSize: const Size(double.infinity, 50),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "Close",
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }
}
