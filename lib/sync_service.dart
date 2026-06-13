import 'dart:typed_data';
import 'dart:convert';
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Thing {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String? imageUrl;
  final String? imageBase64;
  final String? url;
  final DateTime createdAt;

  Thing({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.imageUrl,
    this.imageBase64,
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
      imageBase64: data['imageBase64'],
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
      'imageBase64': imageBase64,
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
      'imageBase64': null,
      'url': url,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> uploadImageAndAddThing(String title, String subtitle, String category, Uint8List imageBytes, String mimeType) async {
    if (title.isEmpty) title = 'Screenshot';

    String? base64String;
    try {
      base64String = base64Encode(imageBytes);
    } catch (e) {
      print('Error encoding image: $e');
    }

    await _userCollection.add({
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'imageUrl': null,
      'imageBase64': base64String,
      'url': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateThing(String id, String title, String subtitle, String category) async {
    await _userCollection.doc(id).update({
      'title': title,
      'subtitle': subtitle,
      'category': category,
    });
  }

  Future<void> deleteThing(String id) async {
    await _userCollection.doc(id).delete();
  }

  Future<void> exportData() async {
    final snapshot = await _userCollection.orderBy('createdAt', descending: true).get();
    final things = snapshot.docs.map((doc) => Thing.fromFirestore(doc)).toList();
    
    final List<Map<String, dynamic>> jsonList = things.map((t) => t.toMap()).toList();
    // Convert Timestamps to ISO strings for export
    for (var item in jsonList) {
      if (item['createdAt'] is Timestamp) {
        item['createdAt'] = (item['createdAt'] as Timestamp).toDate().toIso8601String();
      }
    }
    
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);
    final blob = html.Blob([jsonString], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'my_things_backup.json')
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
