import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser{
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime? joinedAt;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.joinedAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    if (data == null) return AppUser(id: doc.id, email: '', displayName: 'Error');
    return AppUser(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? 'No Name',
      photoUrl: data['photoUrl'],
      joinedAt: data['joinedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['joinedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'joinedAt': joinedAt?.millisecondsSinceEpoch,
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
  }){
   return AppUser(
     id: id ?? this.id,
     email: email ?? this.email,
     displayName: displayName ?? this.displayName,
     photoUrl: photoUrl ?? this.photoUrl,
   );
  }
}