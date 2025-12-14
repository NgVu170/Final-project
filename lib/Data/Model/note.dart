import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  //=============== Attribute & Constructor ===============
  //Configuration for note
  final String? id;
  final String userId;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? parentFolderId;

  //Content of the note
  final List<String> tags;
  final String title;
  final String content;
  final List<String>? imageUrls;
  final List<String>? urlLinks;

  //Constructor
  const Note({
    this.id,
    required this.userId,
    this.title = "Untitled", // Default value
    this.content = "",
    this.isCompleted = false,
    this.parentFolderId = "Storage", // Default là inbox
    required this.createdAt,
    this.updatedAt,
    this.tags = const [],
    this.imageUrls = const [],
    this.urlLinks = const [],
  });

  //=============== Fucntion ===============
  //Copy with techniques
  Note copyWith({
    //Configuration for note
    String? id,
    bool? isCompleted,
    String? parentFolderId,
    DateTime? updatedAt,
    //Content of the note
    String? title,
    String? content,
    List<String>? tags,
    List<String>? imageUrls,
    List<String>? urlLinks,
  }){
    return Note(
      //Configuration for note
      id: id ?? this.id,
      userId: this.userId,
      isCompleted: isCompleted ?? this.isCompleted,
      parentFolderId: parentFolderId ?? this.parentFolderId,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      //Content of the note
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      imageUrls: imageUrls ?? this.imageUrls,
      urlLinks: urlLinks ?? this.urlLinks,
    );
  }
  //From JSON: Firestore -> Dart
  factory Note.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Note(
      //Configuration for note
      id: doc.id,
      userId: data['userId'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      parentFolderId: data['parentFolderId'] ?? 'Storage',
      createdAt: (data['dateCreated'] as Timestamp).toDate(),
      updatedAt: data['dateModified'] != null
          ? (data['dateModified'] as Timestamp).toDate()
          : null,
      //Content of the note
      title: data['title'] ?? 'Untitled',
      content: data['content'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      urlLinks: List<String>.from(data['urlLinks'] ?? []),
    );
  }
  //To JSON Dart -> Firestore
  Map<String, dynamic> toFirestore(){
    return{
      "userId": userId,
      "title": title,
      "content": content,
      "isCompleted": isCompleted,
      "parentFolderId": parentFolderId,
      "tags": tags,
      "imageUrls": imageUrls,
      "urlLinks": urlLinks,
      "dateCreated": Timestamp.fromDate(createdAt),
      "dateModified": updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}