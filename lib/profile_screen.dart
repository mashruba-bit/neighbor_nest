import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // Get the currently logged-in user
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("User Profile"),
      ),

      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .get(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Get the data from Firestore
          var data = snapshot.data!.data() as Map<String, dynamic>;

          String name = data["name"];
          String email = data["email"];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [

                  // Profile picture
                  Image.asset(
                    "assets/images/pfp.jpg",
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),

                  const SizedBox(height: 20),

                  // Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Community Member",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Full Name
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),

                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        const Text(
                          "Full Name",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Email
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),

                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        const Text(
                          "Email",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Log Out
                  InkWell(
                    onTap: () async {

                      // Log out from Firebase
                      await FirebaseAuth.instance.signOut();

                      // Go back to Login
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginView(),
                        ),
                            (route) => false,
                      );
                    },

                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),

                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),

                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          Text(
                            "Log Out",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            "Sign out from your account",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}