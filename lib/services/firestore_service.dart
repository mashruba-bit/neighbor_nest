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

  // Delete all posts (debug feature)
  Future<void> deleteAllPosts() async {
    final snapshot = await _postsCollection.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
