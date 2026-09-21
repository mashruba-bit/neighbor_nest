import 'dart:async';
import 'package:flutter/material.dart';
import 'services/firestore_service.dart';

class LostAndFoundScreen extends StatefulWidget {
  const LostAndFoundScreen({super.key});

  @override
  State<LostAndFoundScreen> createState() => _LostAndFoundScreenState();
}

class _LostAndFoundScreenState extends State<LostAndFoundScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  List<Map<String, dynamic>> _posts = [];
  String _activeTab = 'Lost Items';
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
          title: Text('Report $_activeTab'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
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
                  'type': _activeTab,
                  'title': titleController.text,
                  'description': descController.text,
                  'contact': contactController.text.isEmpty ? 'Anonymous' : contactController.text,
                  'module': 'Lost & Found',
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
    final filteredPosts = _posts.where((post) => post['module'] == 'Lost & Found' && post['type'] == _activeTab).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lost & Found"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => _activeTab = 'Lost Items'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _activeTab == 'Lost Items' ? Colors.blue : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Lost Items"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => setState(() => _activeTab = 'Found Items'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _activeTab == 'Found Items' ? Colors.blue : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Found Items"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPosts.length,
              itemBuilder: (context, index) {
                final post = filteredPosts[index];
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.search)),
                    title: Text(post['title'] ?? 'No title', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post['description'] ?? 'No description'),
                        const SizedBox(height: 4),
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
