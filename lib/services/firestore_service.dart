import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference _postsCollection =
      FirebaseFirestore.instance.collection('posts');

  // Fetch posts stream
  Stream<QuerySnapshot> getPostsStream() {
    return _postsCollection.orderBy('timestamp', descending: true).snapshots();
  }

  // Add a new post
  Future<void> addPost(Map<String, dynamic> postData) async {
    postData['timestamp'] = FieldValue.serverTimestamp();
    await _postsCollection.add(postData);
  }

  // --- CHAT METHODS ---
  final CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('messages');

  // Fetch messages for a specific post stream
  Stream<QuerySnapshot> getChatStream(String postTitle) {
    return _messagesCollection
        .where('postTitle', isEqualTo: postTitle)
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Send a new message
  Future<void> sendMessage(String postTitle, String text) async {
    await _messagesCollection.add({
      'postTitle': postTitle,
      'text': text,
      'sender': 'Me', // hardcoded sender since no auth is implemented
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
