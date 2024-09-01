import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:psw_journal_app/pages/home/home.dart';
import 'package:psw_journal_app/pages/login/login.dart';
import 'package:psw_journal_app/pages/profile/profile.dart';

import '../services/auth_service.dart';
import 'authentication/authentication.dart';
import 'newjournal/newjournal.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key, credential = ''});

  final dynamic credential = null;

  @override
  State<RootPage> createState() => RootPageState();
}

class RootPageState extends State<RootPage> {
  RootPageState({credential = ''});
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  late final List<Widget> _widgetOptions = <Widget>[Home(), ProfilePage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser == null) {
        setState(() {
          _selectedIndex = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              backgroundColor: Color(0xffCBF1F5),
              // appBar: AppBar(
              //   title: const Text('BottomNavigationBar Sample'),
              // ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddJournalEntryPage()),
                  );
                },
                child: Icon(Icons.add),
                elevation: 2.0,
              ),
              body: Center(
                child: _widgetOptions.elementAt(_selectedIndex),
              ),
              bottomNavigationBar: BottomNavigationBar(
                backgroundColor: Color.fromARGB(255, 166, 227, 233),
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  // BottomNavigationBarItem(
                  //   icon: Icon(Icons.business),
                  //   label: '',
                  // ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: Color.fromARGB(255, 35, 166, 173),
                onTap: _onItemTapped,
              ),
            );
          } else {
            return Authentication();
          }
        }); // If user is logge
    // return FutureBuilder<User?>(
    //   future: FirebaseAuth.instance.authStateChanges().first,
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return Center(child: CircularProgressIndicator());
    //     } else if (snapshot.hasData && snapshot.data != null) {
    //       return Scaffold(
    //         // appBar: AppBar(
    //         //   title: const Text('BottomNavigationBar Sample'),
    //         // ),
    //         floatingActionButtonLocation:
    //             FloatingActionButtonLocation.centerDocked,
    //         floatingActionButton: FloatingActionButton(
    //           onPressed: () {
    //             Navigator.push(
    //               context,
    //               MaterialPageRoute(
    //                   builder: (context) => AddJournalEntryPage()),
    //             );
    //           },
    //           child: Icon(Icons.add),
    //           elevation: 2.0,
    //         ),
    //         body: Center(
    //           child: _widgetOptions.elementAt(_selectedIndex),
    //         ),
    //         bottomNavigationBar: BottomNavigationBar(
    //           items: const <BottomNavigationBarItem>[
    //             BottomNavigationBarItem(
    //               icon: Icon(Icons.home),
    //               label: 'Home',
    //             ),
    //             // BottomNavigationBarItem(
    //             //   icon: Icon(Icons.business),
    //             //   label: '',
    //             // ),
    //             BottomNavigationBarItem(
    //               icon: Icon(Icons.person),
    //               label: 'Profile',
    //             ),
    //           ],
    //           currentIndex: _selectedIndex,
    //           selectedItemColor: Colors.amber[800],
    //           onTap: _onItemTapped,
    //         ),
    //       ); // If user is logged in
    //     } else {
    //       return Login(); // If user is not logged in
    //     }
    //   },
    // );
  }
}
