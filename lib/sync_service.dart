import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Thing {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String? imageUrl;
  final String? url;
  final DateTime createdAt;

  Thing({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.imageUrl,
    this.url,
    required this.createdAt,
  });

  factory Thing.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Thing(
      id: doc.id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      category: data['category'] ?? 'Notes',
      imageUrl: data['imageUrl'],
      url: data['url'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'imageUrl': imageUrl,
      'url': url,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class SyncService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in!");
    return user.uid;
  }

  CollectionReference get _userCollection {
    return _db.collection('users').doc(_userId).collection('things');
  }

  Stream<List<Thing>> getThingsStream() {
    return _userCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Thing.fromFirestore(doc))
            .toList());
  }

  Future<void> addThing(String title, String subtitle, String category) async {
    String? imageUrl;
    String? url;

    // Detect if text contains a URL
    final urlRegex = RegExp(r'(https?:\/\/[^\s]+)');
    final match = urlRegex.firstMatch(subtitle) ?? urlRegex.firstMatch(title);
    
    if (match != null) {
      url = match.group(0);
      try {
        final document = await MetadataFetch.extract(url!);
        if (document != null) {
          if (title.isEmpty) title = document.title ?? 'Link';
          if (subtitle.isEmpty || subtitle == url) subtitle = document.description ?? url!;
          imageUrl = document.image;
          category = 'Links'; // Auto-categorize as Link
        }
      } catch (e) {
        // Ignore fetch errors
      }
    }

    if (title.isEmpty) title = 'Untitled Thing';

    await _userCollection.add({
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'imageUrl': imageUrl,
      'url': url,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> uploadImageAndAddThing(String title, String subtitle, String category, Uint8List imageBytes, String mimeType) async {
    String? imageUrl;
    
    if (title.isEmpty) title = 'Screenshot';

    try {
      final extension = mimeType.split('/').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
      final ref = FirebaseStorage.instance.ref().child('users/$_userId/things/$fileName');
      
      final uploadTask = await ref.putData(imageBytes, SettableMetadata(contentType: mimeType));
      imageUrl = await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
    }

    await _userCollection.add({
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'imageUrl': imageUrl,
      'url': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteThing(String id) async {
    await _userCollection.doc(id).delete();
  }
}
