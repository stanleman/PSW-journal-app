import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:psw_journal_app/services/auth_service.dart';
import 'package:toast/toast.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    // getUser();
    super.initState();
  }

  final User? user = AuthService().loggedInUser();

  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 60, horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                  'assets/images/guest.jpg',
                  width: 100,
                  height: 100,
                ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  user?.email != null ? "SIGNED IN AS": "",
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
                Text(
                  user?.email ?? "NOT SIGNED IN",
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w600),
                ),
                // FutureBuilder<User?>(
                //   future: AuthService().loggedInUser(),
                //   builder: (context, snapshot) {
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return CircularProgressIndicator(); // Show a loading spinner
                //     } else if (snapshot.hasError) {
                //       return Text(
                //           'Error retrieving data: ${snapshot.error}'); // Show error message
                //     } else if (snapshot.hasData && snapshot.data != null) {
                //       return Text(
                //         '${snapshot.data!.email}',
                //         style: const TextStyle(
                //             color: Colors.black,
                //             fontSize: 24,
                //             fontWeight: FontWeight.w600),
                //       );
                //     } else {
                //       return const Text('Anonymous',
                //           style: TextStyle(
                //               color: Colors.black,
                //               fontSize: 24,
                //               fontWeight: FontWeight.w600));
                //     }
                //   },
                // ),
              ],
            ),
            _logout(context),
          ],
        ),
      ),
    );
  }

  // Widget _profileDetails() {
  //   return
  // }

  Widget _logout(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 253, 13, 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        minimumSize: const Size(150, 60),
        elevation: 0,
      ),
      onPressed: () async {
        await AuthService().signout(context: context);
        final snackBar = SnackBar(
          content: const Text('Logged out successfully.'),
          showCloseIcon: true,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      child: const Text(
        "Sign Out",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
