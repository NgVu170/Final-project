import 'package:cloud_firestore/cloud_firestore.dart';

class Folder{
  //=============== Attribute & Constructor ===============
  //Configuration for folder
  final String? id;
  final String userId;
  final String? parentFolderId;
  final String name;
  final String type;
  final bool? isSystem;
  final DateTime createdAt;
  final DateTime? updatedAt;
  //Configuration for UI
  final String? icon;
  final String? color;

  //Constructor
  const Folder({
    this.id,
    required this.userId,
    this.parentFolderId,
      required this.name,
    this.type = 'storage', // Default
    this.icon,
    this.color,
    this.isSystem = false,
    required this.createdAt,
    this.updatedAt,
  });

  //=============== Methods ===============
  //Copy with techniques
  Folder copyWith({
    String? id,
    String? userId,
    String? parentFolderId,
    String? name,
    String? type,
    bool? isSystem,
    DateTime? updatedAt,
    String? icon,
    String? color,
  }){
    return Folder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      parentFolderId: parentFolderId ?? this.parentFolderId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isSystem: isSystem ?? this.isSystem,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  //From JSON: Firestore -> Dart
  factory Folder.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Folder(
      id: doc.id,
      userId: data['userId'],
      parentFolderId: data['parentFolderId'], //Default is storage
      name: data['name'] ?? 'New Folder',
      type: data['type'] ?? 'Storage',
      isSystem: data['isSystem'] ?? false,
      createdAt: (data['dateCreated'] as Timestamp).toDate(),
      updatedAt: data['dateModified'] != null
          ? (data['dateModified'] as Timestamp).toDate()
          : null,
      icon: data['icon'],
      color: data['color'],
    );
  }

  //To JSON Dart -> Firestore
  Map<String,dynamic> toFireStore(){
    return{
      "userId": userId,
      "parentFolderId": parentFolderId,
      "name": name,
      "type": type,
      "isSystem": isSystem ?? false,
      "createdAt": Timestamp.fromDate(createdAt),
      "updatedAt": updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      "icon": icon,
      "color": color,
    };
  }
}