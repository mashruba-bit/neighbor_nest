import 'dart:async';
import 'package:flutter/material.dart';
import 'services/firestore_service.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});
  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  List<Map<String, dynamic>> _posts = [];
  StreamSubscription? _postsSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _postsSubscription = _firestoreService.getPostsStream().listen((snapshot) {
      if (mounted) {
        setState(() {
          _posts = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        });
      }
    });
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    super.dispose();
  }
  void _showReportDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final contactController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Donate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Item Name')),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
              TextField(controller: contactController, decoration: const InputDecoration(labelText: 'Contact Phone Number'), keyboardType: TextInputType.phone),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Cancel")
            ),
            ElevatedButton(
              onPressed: () {
                _firestoreService.addPost({
                  'title': titleController.text,
                  'description': descController.text,
                  'contact': contactController.text.isEmpty ? 'Anonymous' : contactController.text,
                  'module': 'Donation',
                });
                Navigator.pop(context);
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPosts = _posts.where((post) => post['module'] == 'Donation').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Donation"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // The list of posts
          Expanded(
            child: ListView.builder(
              itemCount: filteredPosts.length,
              itemBuilder: (context, index) {
                final post = filteredPosts[index];
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.volunteer_activism)),
                    title: Text(post['title'] ?? 'No title', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post['description'] ?? 'No description'),
                        const SizedBox(height: 4),
                        // Here is the contact info for the person who posted!
                        Text(
                          "Phone: ${post['contact'] ?? 'Not provided'}", 
                          style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showReportDialog,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
